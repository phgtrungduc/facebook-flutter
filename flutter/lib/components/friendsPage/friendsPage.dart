import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/seeAllFriend.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/friendsPage/FriendSuggestPage.dart';
import 'package:facebook/components/friendsPage/elements/RowUserFriend.dart';
import 'package:facebook/components/friendsPage/elements/UserFriendModel.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<UserFriendModel> userFriendModels = [
    // UserFriendModel(
    //     idUser: 1,
    //     urlImage: "https://picsum.photos/250?image=9",
    //     commonFriend: 7,
    //     name: "Nam Phạm"),
    // UserFriendModel(
    //     idUser: 2,
    //     urlImage: "https://picsum.photos/250?image=2",
    //     commonFriend: 2,
    //     name: "Tiến NV "),
    // UserFriendModel(
    //     idUser: 3,
    //     urlImage: "https://picsum.photos/250?image=3",
    //     commonFriend: 8,
    //     name: "Bá Đức Đầu moi "),
    // UserFriendModel(
    //     idUser: 4,
    //     urlImage: "https://picsum.photos/250?image=4",
    //     commonFriend: 9,
    //     name: "Đức PT "),
  ];

  int count = 20;
  int index = 0;

  List listUserFriends;
  int totalFriends = 0;

  bool isLoading = false;
  bool hasData = false;
  bool internet = true;

  //ScrollController _scrollController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _getRequestedFriends(index, count);

    super.initState();
    //_scrollController = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _onRefresh() async {
    userFriendModels.clear();
    _getRequestedFriends(0, 20, loadmore: false);
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    int flag = userFriendModels.length;
    if (userFriendModels.length != 0 && flag >= 5) {
      this.count = 20;
      this.index = this.userFriendModels.length + 1;
      _getRequestedFriends(count, index, loadmore: true);
    } else {}
    _refreshController.loadComplete();
  }

  void _getRequestedFriends(int index, int count, {loadmore = false}) async {
    await this.hasInternet();
    if (!internet) return;
    if (mounted == true && loadmore == false) {
      setState(() {
        this.isLoading = true;
      });
    }
    API api = new API();
    try {
      await api.getRequestedFriends(index, count).then((res) {
        int code = json.decode(res.body)["code"];
        if (code == 1000 && mounted) {
          Map data = json.decode(res.body)['data'];
          if (mounted) {
            setState(() {
              try {
                listUserFriends = data["friends"];
                totalFriends = data['total'];
                if (listUserFriends.length != 0) {
                  for (var i = 0; i < totalFriends; i++) {
                    Map info = listUserFriends[i]['user_send'];
                    print("list request friends: $info");
                    userFriendModels.add(
                      UserFriendModel(
                          idUser: info['user_id'],
                          urlImage: info['avatar'],
                          commonFriend: info['same_friends'],
                          name: info['username']),
                    );
                  }
                } else {
                  print("list lấy rỗng !");
                }
              } on Exception catch (e) {
                print(' Error: $e');
              }

              if (totalFriends != 0) {
                this.hasData = true;
              }
            });
          }
        } else {
          print("Loi khong xac dinh");
        }
      });
    } on Exception {
      print("Loi khong xac dinh");
    }
    if (mounted == true) {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(
          distance: 30.0,
          color: CircularColor,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Container(
            //   padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            //   child: Text("Bạn bè",
            //       style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            // ),
            Row(
              children: [
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onPressed: () {
                    seeSuggestedFriend('placeholder', context);
                  },
                  color: Colors.grey[300],
                  child: Text("Gợi ý"),
                ),
                SizedBox(width: 16),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var userId = prefs.getString("id_icre");
                    String userName = prefs.getString("name");
                    seeAllFriend(userId, userName, context);
                  },
                  color: Colors.grey[300],
                  child: Text("Tất cả bạn bè"),
                )
              ],
            ),
            Divider(
              color: Colors.grey[400],
              height: 20.0,
            ),
            RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: TextStyle(
                    fontSize: 27.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: 'Lời mời kết bạn'),
                  TextSpan(
                      text: ' $totalFriends',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            isLoading
                ? Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Column(
                        children: [
                          for (int i = 0; i < 20; i++)
                            Shimmer.fromColors(
                              baseColor: BaseColor,
                              highlightColor: HighlightColor,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: BaseColor,
                                ),
                                title: Container(
                                  height: 20,
                                  color: BaseColor,
                                ),
                                subtitle: Container(
                                  height: 12,
                                  color: BaseColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ])
                : !this.internet
                    ? NoDataScreen(
                        title: 'Không có kết nối mạng',
                        emitParent: this.hasInternet(),
                      )
                    : !hasData
                        ? NoDataScreen(
                            title: 'Không có lời mời nào.',
                          )
                        : listRequestFriend(userFriendModels)
            // for (UserFriendModel user in userFriendModels)
            //   RowUserFriend(userFriendModel: user)
          ],
        ),
      ),
    );
  }

  void seeAllFriend(String userId, String userName, BuildContext context) {
    Navigator.push(
      context,
      SlideRightToLeftRoute(
        page: SeeAllFriend(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  void seeSuggestedFriend(String userId, BuildContext context) {
    Navigator.push(
      context,
      SlideRightToLeftRoute(
        page: FriendSuggestPage(
          userId: userId,
        ),
      ),
    );
  }

  Widget listRequestFriend(userFriendModels) {
    List<Widget> list = new List<Widget>();
    for (UserFriendModel user in userFriendModels) {
      list.add(RowUserFriend(userFriendModel: user));
    }
    return new Column(children: list);
  }

  Future<void> hasInternet() async {
    print('checking internet ...');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        this.internet = false;
      });
    } else {
      if (mounted) {
        setState(() {
          this.internet = true;
        });
      }
    }
    return;
  }
}
