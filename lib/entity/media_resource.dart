class MediaResource {
  final String url;
  final List<String>? backupUrl;
  final Map<String, String>? headers;

  MediaResource({required this.url, this.headers, this.backupUrl});

}