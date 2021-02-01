import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/seeAllFriend.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/menuScreen/elements/RowUserBlock.dart';
import 'package:facebook/components/menuScreen/model/UserBlockModel.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class BlockUserPane extends StatefulWidget {
  @override
  _BlockUserPaneState createState() => _BlockUserPaneState();
}

class _BlockUserPaneState extends State<BlockUserPane> {
  List<UserBlockModel> userBLockModels = [
    // UserBlockModel(
    //     urlImage: "https://picsum.photos/250?image=9", name: "Nam Phạm"),
    // UserBlockModel(
    //     urlImage: "https://picsum.photos/250?image=2", name: "Tiến NV "),
    // UserBlockModel(
    //     urlImage: "https://picsum.photos/250?image=3", name: "Bá Đức Đầu moi "),
    // UserBlockModel(
    //     urlImage: "https://picsum.photos/250?image=4", name: "Đức PT ")
  ];

  int count = 20;

  int index = 0;

  List listBlockUserFriends;

  bool internet = true;

  bool isLoading = false;

  bool hasData = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _getListBlocks(index, count);
    super.initState();
  }

  void _onRefresh() async {
    userBLockModels.clear();
    _getListBlocks(0, 10, loadmore: false);
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    int flag = userBLockModels.length;
    if (userBLockModels.length != 0 && flag >= 10) {
      this.count = 10;
      this.index = this.userBLockModels.length + 1;
      _getListBlocks(count, index, loadmore: true);
      print("flag" + flag.toString());
      print("count" + count.toString());
      print("index" + index.toString());
    } else {}
    _refreshController.loadComplete();
  }

  void _getListBlocks(int index, int count, {loadmore = false}) async {
    await this.hasInternet();
    if (this.internet == false) return;
    if (mounted == true && loadmore == false) {
      setState(() {
        this.isLoading = true;
      });
    }
    API api = new API();
    try {
      await api.getListBlocks(index, count).then((res) {
        int code = json.decode(res.body)["code"];
        if (code == 1000 && mounted) {
          if (mounted) {
            setState(() {
              try {
                listBlockUserFriends = json.decode(res.body)['data'];
                if (listBlockUserFriends.length != 0) {
                  for (var i = 0; i < listBlockUserFriends.length; i++) {
                    Map info = listBlockUserFriends[i]['info'];
                    print("list request friends: $info");
                    userBLockModels.add(
                      UserBlockModel(
                          idUser: info['user_id'],
                          urlImage: info['avatar'],
                          name: info['username']),
                    );
                  }
                } else {
                  print("list lấy rỗng !");
                }
              } on Exception catch (e) {
                print(' Error: $e');
              }

              if (listBlockUserFriends.length != 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chặn",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Người bị chặn",
                    style: TextStyle(
                      height: 2,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Kiểm soát người nhìn thấy hoạt động của bạn và cách chúng tôi dùng dữ liệu cá nhân hóa trải nghiệm" +
                        "Kiểm soát người nhìn thấy hoạt động của bạn và cách chúng tôi dùng dữ liệu cá nhân hóa trải nghiệm",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  Card(
                    child: RaisedButton(
                      elevation: 0,
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        var id_user = prefs.getString("id_icre");
                        seeAllFriend(id_user.toString(), context);
                      },
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16, left: 8, right: 8, bottom: 16),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.add, size: 20.0, color: Colors.blue),
                            SizedBox(width: 10.0),
                            Text(
                              'Thêm vào danh sách chặn',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: MaterialClassicHeader(
                  distance: 30.0,
                  color: CircularColor,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: this.isLoading
                    ? ListView(children: [
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
                                title: 'Không có ai bị chặn. ',
                              )
                            : listBlockFriend(userBLockModels)),
          ),
        ],
      ),
    );
  }

  void seeAllFriend(String userId, BuildContext context) {
    Navigator.push(
      context,
      SlideRightToLeftRoute(
        page: SeeAllFriend(
          userId: userId,
        ),
      ),
    );
  }

  Widget listBlockFriend(List<UserBlockModel> userBlockModels) {
    List<Widget> list = new List<Widget>();
    for (UserBlockModel user in userBlockModels) {
      list.add(RowUserBLock(userBlockModel: user));
    }
    return new ListView(children: list);
  }
}
