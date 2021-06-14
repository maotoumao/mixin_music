import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mixinmusic/api/api.dart';
import 'package:mixinmusic/utils/shared_pref_helper.dart';
import 'package:mixinmusic/entity/media_resource.dart';

// 拖动框
class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this.player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  start() async {
    _running = true;
    while (_running) {
      Duration newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration!) newPosition = mediaItem.duration!;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  stop() {
    _running = false;
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  List<MediaItem> queue = [];
  AudioPlayer _player = AudioPlayer();
  AudioProcessingState? _skipState;
  Seeker? _seeker;
  late StreamSubscription<PlaybackEvent> _eventSubscription;
  int index = -1;

  AudioServiceShuffleMode _shuffleMode = AudioServiceShuffleMode.none;
  int _step = 1;

  MediaItem? get mediaItem => index == -1 ? null : queue[index];

  get currentRepeatMode {
    if (_player.loopMode == LoopMode.off) {
      return AudioServiceRepeatMode.none; // 顺序播放，不设置
    } else {
      return AudioServiceRepeatMode.one; //否则设置
    }
  }

  Future<void> setResource() async {
    if (queue.isEmpty || index == -1) {
      return;
    }
    final data = queue[index];
    Duration? realDuration;

    print('getResource');
    MediaResource mediaResource = await API.getAudioResource(data);
    print('url-data');
    print(mediaResource.url);
    print(mediaResource.headers);
    if (mediaResource.headers?['#localFile'] != null) {
      realDuration = await _player.setFilePath(mediaResource.url);
    } else {
      try {
        realDuration = await _player.setUrl(mediaResource.url,
            headers: mediaResource.headers);
      } catch (e) {
        if (mediaResource.backupUrl != null) {
          realDuration = await _player.setUrl(mediaResource.backupUrl![0],
              headers: mediaResource.headers);
        }
      }
    }

    if (data.duration == null ||
        (realDuration != null && realDuration < data.duration!)) {
      queue[index] = data.copyWith(duration: realDuration);
    }

    if (data.extras?['clip'] != null) {
      _player.setClip(
          start: Duration(seconds: data.extras!['clip'][0]),
          end: Duration(seconds: data.extras![1]));
    }
  }

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // Broadcast media item changes.
//    _player.currentIndexStream.listen((index) {
//      if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
//    });

    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          onSkipToNext();
          // 播放结束
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    print('readytoplay');
    try {
      // 加载播放状态以及播放列表
      queue = List<MediaItem>.from(
          params?['playQueue'] ?? []); //如果改了一个东西，然后热更新错误依然存在，有可能因为这是一个后台应用

//      progress = params!['playProgress'];
      index = params?['playIndex'] ?? -1;
      print(index);

      setResource();
    } catch (e) {
      print("Error: $e");
      onStop();
    }

    // Load and broadcast the queue
    AudioServiceBackground.setQueue(queue);
  }

  @override
  Future<void> onSetRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // 单曲循环
    if (repeatMode == AudioServiceRepeatMode.one) {
      _shuffleMode = AudioServiceShuffleMode.none;
      await _player.setLoopMode(LoopMode.one);
    }
    if (repeatMode == AudioServiceRepeatMode.none) {
      await _player.setLoopMode(LoopMode.off);
    }
    _broadcastState();
  }

  @override
  Future<void> onSetShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.all) {
      await _player.setLoopMode(LoopMode.off);
      _shuffleMode = shuffleMode;
    } else {
      _shuffleMode = AudioServiceShuffleMode.none;
    }
    _broadcastState();
  }

  @override
  Future<void> onRemoveQueueItem(MediaItem mediaItem) async {
    int ind = queue.indexWhere((element) => element.id == mediaItem.id);
    queue.removeAt(ind);
    if (index == -1 || index < ind) {
      // 没在播放 或者正在播放的序列在后边，不影响
    } else if (index == ind) {
      onSkipToNext();
    } else {
      index -= 1;
    }
    AudioServiceBackground.setQueue([...queue]); // 通知
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    // 点击播放
    int ind = queue.indexWhere((element) => element.id == mediaItem.id);
    // 如果在当前序列中
    if (ind != -1) {
      index = ind;
      await setResource();
      onPlay();
    } else {
      // 插入当前队列
      queue.insert(++index, mediaItem);
      AudioServiceBackground.setQueue([...queue]);
      await setResource();
      onPlay();
    }
  }

  // 下一首
  @override
  Future<void> onAddQueueItem(MediaItem mediaItem) async {
    if (!queue.contains(mediaItem)) {
      queue.insert(index + 1, mediaItem);
      AudioServiceBackground.setQueue([...queue]); // 增加歌曲要重新设置的
    }
    // 如果加了之后只有一首歌就立刻开始播
    if (queue.length == 1) {
      onPlayMediaItem(mediaItem);
    }
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    // Then default implementations of onSkipToNext and onSkipToPrevious will
    // delegate to this method.
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    // During a skip, the player may enter the buffering state. We could just
    // propagate that state directly to AudioService clients but AudioService
    // has some more specific states we could use for skipping to next and
    // previous. This variable holds the preferred state to send instead of
    // buffering during a skip, and it is cleared as soon as the player exits
    // buffering (see the listener in onStart).
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    // This jumps to the beginning of the queue item at newIndex.
    index = newIndex;
    await setResource();
    _player.seek(Duration.zero);
    // Demonstrate custom events.
    AudioServiceBackground.sendCustomEvent('skip to $newIndex');
  }

  @override
  Future<void> onSkipToNext() async {
    if (queue.isNotEmpty) {
      _step = _shuffleMode == AudioServiceShuffleMode.all
          ? Random().nextInt(queue.length - 1)
          : 0;
      index = (index + 1 + _step) % queue.length;
      await setResource();
      await onPlay();
    } else {
      index = -1;
      _player.stop();
    }
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> q) async {
    if (q.isNotEmpty) {
      index = 0;
      queue = q;
      AudioServiceBackground.setQueue(queue); // 修改播放列表
    } else {
      queue = [];
      index = -1;
      AudioServiceBackground.setQueue([]); //清空
    }
  }

  @override
  Future<void> onSkipToPrevious() async {
    if (queue.isNotEmpty) {
      index = (index - 1 - _step) % queue.length;
      await setResource();
      await onPlay();
    } else {
      index = -1;
      _player.stop();
    }
  }

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.setMediaItem(queue[index]);
    _player.play();
  }

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onStop() async {
    await SharedPrefHelper.saveSongStatus(index, queue);
    print('dieeeee'); // 之后再做吧 应该让它停止的时候记录一下当前的状态的
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// 滑动
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem!.duration!) newPosition = mediaItem!.duration!;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.
  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          Duration(seconds: 1), mediaItem!)
        ..start();
    }
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: [
          MediaAction.seekTo,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        ],
        androidCompactActions: [
          0,
          1,
          2
        ],
        processingState: _getProcessingState(),
        playing: _player.playing,
        position: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        repeatMode: currentRepeatMode,
        shuffleMode: _shuffleMode);
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState!;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}
