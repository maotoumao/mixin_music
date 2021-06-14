import 'package:flutter/material.dart';

import 'package:mixinmusic/utils/adaption.dart';

class Header extends StatelessWidget {
  final String? cover;
  final String name;
  final int songNum;

  Header({Key? key, this.cover, required this.name, required this.songNum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.rpx, 40.rpx, 24.rpx, 16.rpx),
      child: Row(
        children: [
          GestureDetector(
            child: Icon(
              Icons.arrow_back,
              size: 48.rpx,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 24.rpx,),
          Text(
            name,
            style: TextStyle(fontSize: 30.rpx),
          ),
        ],
      ),
    );
  }

}