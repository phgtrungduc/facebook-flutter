import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/activation/Sheet/bottom/bottomSheet.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/reuseComponent/searchBox.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SeeAllFriend extends StatefulWidget {
  final String userId;
  final String userName;

  const SeeAllFriend({Key key, @required this.userId, this.userName})
      : super(key: key);
  @override
  _SeeAllFriendState createState() => _SeeAllFriendState();
}

class _SeeAllFriendState extends State<SeeAllFriend>
    with SingleTickerProviderStateMixin {
  String friendName;
  List listUserFriends = [];
  List listUserFriendsUi = [];
  List searchUserFriend = [];

  int count = 20;
  int index = 0;
  int totalFriends = 0;

  int codeCheckBlock = 0;

  bool isSearching = false;
  bool isLoading = false;
  bool hasData = false;
  bool internet = true;

  List<Widget> listOptions;
  ScrollController _scrollController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _editController = TextEditingController();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //for options bottom sheet
    listOptions = List(4);
    _scrollController = ScrollController()..addListener(_loadMore);
    this.getUserFriends(this.index, this.count, widget.userId);
  }

  Future<void> hasInternet() async {
    print('checking');
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

  void _onRefresh() async {
    await this.getUserFriends(this.index, this.count, widget.userId);
    this._editController.clear();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _loadMore() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_editController.text.trim() == "") {
        var count = this.listUserFriends.length + 20;
        var index = this.listUserFriends.length;
        print('loadmore ori');
        this.getUserFriends(index, count, widget.userId, loadmore: true);
      } else {
        var count = this.searchUserFriend.length + 20;
        var index = this.searchUserFriend.length;
        print('load more search');
        this.searchUser(
            widget.userId, _editController.text.trim(), count, index,
            loadmore: true);
      }
    }
  }

  void showError(String error) {
    showModalBottomSheet(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Thông báo'),
                subtitle: Text(error),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Navigator.pop(context);
    });
  }

  void removeFriend(String userId) {
    if (mounted) {
      setState(() {
        for (var i = 0; i < listUserFriends.length; i++) {
          if (listUserFriends[i]['info']['user_id'].toString() == userId) {
            listUserFriends.removeAt(i);
            listUserFriendsUi.removeAt(i);
            if (listUserFriends.length == 0) {
              this.hasData = false;
            }
            break;
          }
        }
      });
    }
  }

  Future<void> searchUser(String userId, String keyword, int count, int index,
      {loadmore = false}) async {
    if (!loadmore) {
      this.searchUserFriend.clear();
      this.showLoaderDialog(context);
    }
    try {
      await API().searchUserFriend(userId, keyword, count, index).then((res) {

        if (!loadmore) {
          Navigator.pop(context);
        }
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          var data = json.decode(res.body)['data'];

          setState(() {
            for (var i = 0; i < data.length; i++) {
              Map info = data[i]['info'];
              searchUserFriend
                  .add(showOneFriend(info, context, listOptions: listOptions));
            }
            if (searchUserFriend.length == 0) {
              this.showError("Không tìm thấy bạn bè nào.");
            }
          });
          // this.removeFriend(userId);
        } else if (code == 9999) {
          this.showError("Có lỗi xảy ra, vui lòng thử lại sau.");
        } else if (code == 1009) {
          this.showError("Không có dữ liệu.");
        }
      });
    } on Exception {
      this.showError("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  Future<void> unfriend(String userId) async {
    this.showLoaderDialog(context);
    try {
      await API().unfriend(userId).then((res) {
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          // var data = json.decode(res.body)['data'];

          this.removeFriend(userId);
        } else if (code == 9999) {
          this.showError("Có lỗi xảy ra, vui lòng thử lại sau.");
        } else if (code == 9994) {
          this.showError("Không thể thực hiện thao tác này.");
        }
      });
    } on Exception {
      this.showError("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
    Navigator.pop(context);
  }

  Future<void> getUserFriends(int index, int count, String userId,
      {loadmore = false}) async {
    await this.hasInternet();
    if (!this.internet) return;
    if (mounted && !loadmore) {
      setState(() {
        this.isLoading = true;
        listUserFriends.clear();
        listUserFriendsUi.clear();
      });
    }
    API api = new API();
    try {
      await api.getUserFriends(index, count, userId: userId).then((res) {
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          Map data = json.decode(res.body)['data'];

          setState(() {
            listUserFriends = data["friends"];
            totalFriends = data['total'];
            for (var i = 0; i < listUserFriends.length; i++) {
              Map info = listUserFriends[i]['info'];
              listUserFriendsUi
                  .add(showOneFriend(info, context, listOptions: listOptions));
            }
            if (totalFriends != 0) {
              this.hasData = true;
            }
          });
        } else if (code == 9999) {
          this.showError('Kết nối mạng không ổn định hoặc server không phản hồi');
        }
      });
    } on Exception {
      this.showError('Kết nối mạng không ổn định hoặc server không phản hồi');
    }
    if (mounted) {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _editController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userName;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '$userName',
          style: TextStyle(fontSize: 14),
        ),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: MaterialClassicHeader(
          distance: 30.0,
          color: CircularColor,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: internet
            ? isLoading
                ? ListView(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Column(
                        children: [
                          for (int i = 0; i < 10; i++)
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
                : !hasData
                    ? NoDataScreen(
                        title: 'Không tìm thấy bạn bè nào.',
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverAppBar(
                            elevation: 1.0,
                            backgroundColor: Color(0xFFFFFFFF),
                            pinned: true,
                            expandedHeight: 80, //150 old
                            automaticallyImplyLeading: false,
                            // collapsedHeight: 110,
                            flexibleSpace: Padding(
                              padding: EdgeInsets.all(10),
                              child: Wrap(
                                runSpacing: 5,
                                children: [
                                  // Row(
                                  //   children: [
                                  //     Wrap(
                                  //       spacing: 10,
                                  //       runSpacing: 5,
                                  //       children: [
                                  //         RaisedButton(
                                  //           elevation: 0.0,
                                  //           onPressed: () {},
                                  //           shape: RoundedRectangleBorder(
                                  //             borderRadius:
                                  //                 BorderRadius.all(Radius.circular(20)),
                                  //           ),
                                  //           color: Color(0xFF81D4FA),
                                  //           child: Text(
                                  //             'All',
                                  //             style: TextStyle(
                                  //               fontSize: 12,
                                  //               fontWeight: FontWeight.w500,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ],
                                  // ),
                                  searchBox(
                                    hasSuffix: true,
                                    editController: _editController,
                                    onSuffixAction: () {
                                      _editController.clear();
                                      if (mounted) {
                                        setState(() {
                                          this.isSearching = false;
                                          this.searchUserFriend.clear();
                                        });
                                      }
                                    },
                                    onTapFunction: () {
                                      print('tap');
                                    },
                                    onChangedFunction: (text) {
                                      if (text == "") {
                                        setState(() {
                                          this.isSearching = false;
                                          this.searchUserFriend.clear();
                                        });
                                      }
                                    },
                                    onSubmittedFunction: (text) {
                                      text = text.trim();
                                      if (text != "") {
                                        setState(() {
                                          this.isSearching = true;
                                        });
                                        this.searchUser(
                                            widget.userId, text, 20, 0);
                                      } else {
                                        setState(() {
                                          this.isSearching = false;
                                          this.searchUserFriend.clear();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate(
                              !isSearching
                                  ? [
                                      for (var friend in listUserFriendsUi)
                                        friend,
                                    ]
                                  : [
                                      for (var friend in searchUserFriend)
                                        friend,
                                    ],
                            ),
                          ),
                        ],
                      )
            : NoDataScreen(
                title: 'Không có kết nối mạng',
                content: 'Hãy kiểm tra lại đường truyền và thử lại sau',
                emitParent:
                    this.getUserFriends(this.index, this.count, widget.userId),
              ),
      ),
    );
  }

  Container showOneFriend(Map info, BuildContext context,
      {List<Widget> listOptions}) {
    //get infor here
    String userId = info['user_id'].toString();
    String userName = info['username'];
    String avatar = info['avatar'];
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      color: Color(0xFFFFFFFF),
      height: 70,
      child: Row(
        children: [
          Container(
            width: 52,
            child: CircleAvatar(
              backgroundColor: Color(0xFF9E9E9E),
              radius: 50,
              backgroundImage: avatar == null
                  ? AssetImage(PlaceHolderAvatarUrl)
                  : NetworkImage(Host + avatar),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Wrap(
                children: [
                  Text(
                    '$userName',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            child: Icon(Icons.more_horiz),
            onTap: () {
              setState(() {
                listOptions[0] = singleOption(
                  'Xem bạn bè của $userName',
                  iconOption: FontAwesomeIcons.userFriends,
                  context: context,
                  callbackFunction: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      SlideRightToLeftRoute(
                        page: SeeAllFriend(userId: userId, userName: userName),
                      ),
                    ).whenComplete(() {
                      this._onRefresh();
                    });
                  },
                );
                listOptions[1] = singleOption(
                  'Xem trang cá nhân của $userName',
                  iconOption: FontAwesomeIcons.userCircle,
                  context: context,
                  callbackFunction: () async {
                    Navigator.pop(context);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String userIdLogged = prefs.getString("id_icre");
                    bool isOwner = (userId == userIdLogged) ? true : false;

                    Navigator.push(
                      context,
                      SlideRightToLeftRoute(
                        page: UserWall(
                          userId: userId,
                          isOwner: isOwner,
                        ),
                      ),
                    ).whenComplete(() {
                      this._onRefresh();
                    });
                  },
                );
                listOptions[2] = singleOption(
                  'Chặn $userName',
                  iconOption: FontAwesomeIcons.userLock,
                  context: context,
                  callbackFunction: () {
                    Navigator.pop(context);
                    _showBlockDialog(userName, int.parse(userId));
                  },
                );
                listOptions[3] = singleOption(
                  'Hủy kết bạn với $userName',
                  iconOption: FontAwesomeIcons.userTimes,
                  context: context,
                  callbackFunction: () {
                    Navigator.pop(context);
                    this.unfriend(userId);
                  },
                );
              });
              showSlideBottomSheet(context, listOptions: listOptions);
            },
          )
        ],
      ),
    );
  }

  void setBlockFriend(int idUser) async {
    showLoaderDialog(context);
    API api = new API();
    try {
      await api.setBlock(idUser).then((res) {
        int code = json.decode(res.body)["code"];
        Navigator.pop(context);
        if (code == 1000) {
          codeCheckBlock = code;
          this.removeFriend(idUser.toString());
        } else {
          print(code.toString() + "lỗi không xác định");
          showBottomSheet2(context);
        }
      });
    } on Exception {
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  void showBottomSheet2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Thông báo'),
                subtitle: Text('Lỗi mạng !'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      Navigator.of(context).pop();
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Đang tải...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showBlockDialog(String name, int idUser) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Chặn ${name}"),
        content: new Text(
            "Nếu bạn chặn ${name} , Hắn không thể xem dòng thời gian và liên hệ với bạn ! "),
        actions: <Widget>[
          FlatButton(
            child: Text('THOÁT'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Xác nhận'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                this.setBlockFriend(idUser);
              });
            },
          )
        ],
      ),
    );
  }
}
