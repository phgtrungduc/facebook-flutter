import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/chat/home_page_chat.dart';
import 'package:facebook/components/friendsPage/friendsPage.dart';
import 'package:facebook/components/homepage/homepage.dart';
import 'package:facebook/components/menuScreen/MenuScreen.dart';
import 'package:facebook/components/notification/notification.dart';
import 'package:facebook/components/playVideo/PlayVideo.dart';
import 'package:facebook/components/qrCode/qrcode.dart';
import 'package:facebook/components/search/view/baseSearch.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final storage = new FlutterSecureStorage();
  TabController _tabController;
  String userId;
  @override
  initState(){
    super.initState();
    _tabController = new TabController(length: tab.length, vsync: this);
    _getInfor();
  }
  void _getInfor()  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userIdLogged = prefs.getString("id_icre");
    setState(() {
      userId = userIdLogged;
    });
  }

  SliverAppBar getAppBar(){
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: DefaultTabController(
        length: 6,
        child: NestedScrollView(
          headerSliverBuilder: (context, bool innerBoxIsScrolled) {
            return [
              getAppBar()
            ];
          },
          floatHeaderSlivers: true,
          body: TabBarView(
            children: [
              Homepage(),
              FriendsPage(),
              VideoApp(),
              UserProfileBody(
                userId: this.userId,
                isOwner: true,
              ),
              UserNotifications(userId: this.userId),
              MenuScreen()
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
