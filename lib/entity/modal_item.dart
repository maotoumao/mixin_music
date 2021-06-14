import 'package:flutter/material.dart';

class ModalItem {
  // 开头图标
  final IconData? leading;
  // 内容
  final String content;
  // 结尾
  final IconData? tail;


  // 点击事件
  Function? onTap;
  // 点击尾部
  Function? onTailTap;

  ModalItem({this.leading, required this.content, this.tail, this.onTap, this.onTailTap});

}