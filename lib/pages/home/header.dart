import 'package:flutter/material.dart';
import 'package:mixinmusic/pages/home/search_bar.dart';



class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (Row(
      children: [
        // 打开抽屉的按钮
        IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            }),
        // 按钮
        Expanded(
          child: GestureDetector(
              onTap: () {
                showSearch(context: context, delegate: SearchBar());
              },
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      color: Color(0x99666666),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Color(0xcc333333)),
                          Text(
                            '输入歌曲名或B站BV号搜索',
                            style: TextStyle(color: Color(0xcc333333)),
                          )
                        ],
                      )))),
        ),
        // 占位
        SizedBox(
          width: 10,
        )
      ],
    ));
  }
}
