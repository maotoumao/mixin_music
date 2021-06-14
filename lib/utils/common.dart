import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommonUtil{
  static copyToClipboard(String? string) async {
    if(string == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: string));
    Fluttertoast.showToast(msg: '已复制到剪切板');
  }

  // 获取下载文件

}