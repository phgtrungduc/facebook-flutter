import 'dart:math';

import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/chat/home_page_chat.dart';
import 'package:facebook/components/qrCode/qrcode.dart';
import 'package:facebook/components/search/view/baseSearch.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/test/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class SingleTab extends StatefulWidget {
  final IconData icon;
  final int index;

  SingleTab({Key key, this.icon, this.index}) : super(key: key);
  @override
  _SingleTabState createState() => _SingleTabState();
}

class _SingleTabState extends State<SingleTab> {
  int numberNotify;
  @override
  void initState() {
    super.initState();
    numberNotify = Random().nextInt(20);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (numberNotify != 0) {
          setState(() {
            numberNotify = 0;
          });
        }
      },
      child: Tab(
        child: Container(
          height: 20,
          width: 33,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                child: FaIcon(
                  widget.icon,
                  size: 25,
                ),
              ),
              ((numberNotify != 0) &&
                      (widget.index == 1 ||
                          widget.index == 2 ||
                          widget.index == 4 ||
                          widget.index == 0))
                  ? Container(
                      // padding: EdgeInsets.all( 10),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 13,
                          height: 13,
                          // margin: EdgeInsets.only(bottom: 10),
                          // padding: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: Center(
                            child: Text(
                              (numberNotify < 9) ? '$numberNotify' : '9+',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class TabTab {
  IconData icon;
  int index;
  TabTab({this.icon, this.index});
}

List<TabTab> tab = <TabTab>[
  TabTab(icon: FontAwesomeIcons.home, index: 0),
  TabTab(icon: FontAwesomeIcons.userFriends, index: 1),
  TabTab(icon: FontAwesomeIcons.youtube, index: 2),
  TabTab(icon: FontAwesomeIcons.userCircle, index: 3),
  TabTab(icon: FontAwesomeIcons.bell, index: 4),
  TabTab(icon: FontAwesomeIcons.bars, index: 5),
];

SliverAppBar myAppbar(context) {
  return SliverAppBar(
    // titleSpacing: 20,
    elevation: 1.0,
    title: Text("facebook",
        style: TextStyle(
          color: BlueColor,
          fontSize: 31,
          fontWeight: FontWeight.w800,
        )),
    backgroundColor: Color(0xFFFFFFFF),
    floating: true,
    pinned: true,
    snap: false,
    automaticallyImplyLeading: false,
    actions: [
      QRcodeOptions(),
      Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(shape: BoxShape.circle, color: GreyIcon),
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.search,
            color: BlackColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.push(
                  context,
                  SlideRightToLeftRoute(
                    page: BaseSearchPage(),
                  ),
                );
          },
        ),
      ),
      Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(shape: BoxShape.circle, color: GreyIcon),
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.facebookMessenger,
            color: BlackColor,
            size: 20,
          ),
          onPressed: () {
            final HomePageChat page = new HomePageChat();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
        ),
      ),
    ],
    bottom: TabBar(
      labelPadding: EdgeInsets.only(left: 20, right: 20),
      isScrollable: true,
      labelColor: BlueColor,
      unselectedLabelColor: GreyBottomBar,
      tabs: [
        for (var tabtab in tab)
          Tab(icon: FaIcon(tabtab.icon))
      ],
    ),
  );
}
