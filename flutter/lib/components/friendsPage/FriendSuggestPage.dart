import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/friendsPage/elements/RowSuggestFriend.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import 'elements/RowUserFriend.dart';
import 'elements/UserFriendModel.dart';

class FriendSuggestPage extends StatefulWidget {
  final String userId;

  const FriendSuggestPage({Key key, this.userId}) : super(key: key);
  @override
  _FriendSuggestPageState createState() => _FriendSuggestPageState();
}

class _FriendSuggestPageState extends State<FriendSuggestPage> {
  List<UserFriendModel> userFriendModels = [
    // UserFriendModel(
    //     urlImage: "https://picsum.photos/250?image=9",
    //     commonFriend: 7,
    //     name: "Nam Phạm"),
    // UserFriendModel(
    //     urlImage: "https://picsum.photos/250?image=2",
    //     commonFriend: 2,
    //     name: "Tiến NV "),
    // UserFriendModel(
    //     urlImage: "https://picsum.photos/250?image=3",
    //     commonFriend: 8,
    //     name: "Bá Đức Đầu moi "),
    // UserFriendModel(
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
    super.initState();
    //_scrollController = ScrollController()..addListener(_loadMore);
    getSuggestFriends(index, count);
  }

  void _onRefresh() async {
    userFriendModels.clear();
    getSuggestFriends(0, 20, loadmore: false);
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    int flag = userFriendModels.length;
    if (userFriendModels.length != 0 && flag >= 5) {
      this.count = 20;
      this.index = this.userFriendModels.length + 1;
      getSuggestFriends(0, 10, loadmore: true);
    } else {}
    _refreshController.loadComplete();
  }

  void getSuggestFriends(int index, int count, {loadmore = false}) async {
    await this.hasInternet();
    if (!internet) return;
    if (mounted == true && loadmore == false) {
      setState(() {
        this.isLoading = true;
      });
    }
    API api = new API();
    try {
      await api.getSuggestFriends().then((res) {
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          Map data = json.decode(res.body)['data'];
          setState(() {
            try {
              listUserFriends = data["friends"];
              totalFriends = listUserFriends.length;
              if (listUserFriends.length != 0) {
                for (var i = 0; i < totalFriends; i++) {
                  Map info = listUserFriends[i]['info'];
                  userFriendModels.add(
                    UserFriendModel(
                        idUser: info['user_id'],
                        urlImage: info['avatar'],
                        commonFriend: info['same_friends'],
                        name: info['username']),
                  );
                }
              } else {
              }
            } on Exception catch (e) {
              print(' Error: $e');
            }

            if (totalFriends != 0) {
              setState(() {
                this.hasData = true;
              });
            }
          });
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
          'Gợi ý kết bạn',
          style: TextStyle(fontSize: 14),
        ),
        elevation: 0.4,
        centerTitle: true,
      ),
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
            RichText(
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: TextStyle(
                    fontSize: 27.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: 'Những người ban có thể biết'),
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
                        : listSuggestFriend(userFriendModels)
          ],
        ),
      ),
    );
  }

  Widget listSuggestFriend(userFriendModels) {
    List<Widget> list = new List<Widget>();
    for (UserFriendModel user in userFriendModels) {
      list.add(RowSuggestFriend(userFriendModel: user));
    }
    return new Column(children: list);
  }
}
