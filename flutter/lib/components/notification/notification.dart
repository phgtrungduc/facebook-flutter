import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/activation/Sheet/bottom/bottomSheet.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/friendsPage/friendsPage.dart';
import 'package:facebook/components/notification/elements/oneNotify.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/search/view/baseSearch.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/popup/notifyScreen/popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class UserNotifications extends StatefulWidget {
  final String userId;

  const UserNotifications({Key key, @required this.userId}) : super(key: key);
  @override
  _UserNotificationsState createState() => _UserNotificationsState();
}

class _UserNotificationsState extends State<UserNotifications> {
  List listNotifications;
  bool isShowPopupDeleteNotify = false;
  Widget notifyDelete;
  int notifyIdDelete;
  int initCount = 20;
  int initIndex = 0;

  bool isLoadingMore = false;

  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController;

  bool internet = true;
  bool loading = false;
  bool hasData = true;

  @override
  void initState() {
    super.initState();
    listNotifications = [];
    _scrollController = ScrollController()..addListener(_loadMore);
    this.getListNotifications(initIndex, initCount);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> hasInternet() async {
    print('checking');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        setState(() {
          this.internet = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          this.internet = true;
        });
      }
    }
    return;
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

  deleteNotify(int index, int notifyId) async {
    this.showLoaderDialog(context);
    try {
      await API().deleteNotify(notifyId).then((res) {
        print(res.body);
        Navigator.pop(context);
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          if (mounted) {
            setState(() {
              this.listNotifications.removeAt(index); //value is old widget
              this.isShowPopupDeleteNotify = true;
            });
          }
          // this.removeFriend(userId);
          Timer(Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                this.isShowPopupDeleteNotify = false;
              });
            }
          });
        } else if (code == 9999) {
          this.showError("Có lỗi xảy ra, vui lòng thử lại sau.");
        } else if (code == 1009) {
          this.showError("Không có dữ liệu.");
        } else {
          this.showError("Lỗi không xác định.");
        }
      });
    } on Exception {
      this.showError("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  // reverseAction() {
  //   setState(() {
  //     this.isShowPopupDeleteNotify = false;
  //     this.listNotifications.replaceRange(
  //         this.notifyIdDelete, this.notifyIdDelete + 1, [this.notifyDelete]);
  //   });
  // }

  void _onRefresh() async {
    await this.getListNotifications(initIndex, initCount);
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _loadMore() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (isLoadingMore) return;
      print('loadmore noti');
      if (mounted) {
        setState(() {
          this.isLoadingMore = true;
        });
        int index = this.listNotifications.length;
        await this.getListNotifications(index, initCount, loadmore: true);
        setState(() {
          this.isLoadingMore = false;
        });
      }
    }
  }

  void showError(String error) {
    showModalBottomSheet(
      context: context,
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
    );
  }

  Future<void> getListNotifications(int index, int count,
      {loadmore = false}) async {
    await this.hasInternet();
    if (!internet) return;
    if (mounted && !loadmore) {
      setState(() {
        this.loading = true;
        this.listNotifications.clear();
      });
    }
    try {
      API().getListNotifications(index, count).then((res) {
        if (mounted && !loadmore) {
          setState(() {
            this.loading = false;
          });
        }
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          var data = json.decode(res.body)['data'];
          print(data);
          if (mounted) {
            setState(() {
              for (var i = 0; i < data.length; i++) {
                String message = 'Bạn có một thông báo mới';
                String name = data[i]['info_user']['username'];
                var routeScreen;
                switch (data[i]['type']) {
                  case 'like':
                    message = "$name đã thích bài viết của bạn";
                    break;
                  case 'comment':
                    message = "$name đã bình luận bài viết của bạn";
                    break;
                  case 'request':
                    message = "$name đã gửi cho bạn lời mời kết bạn";
                    routeScreen = FriendsPage();
                    break;
                }
                int index = listNotifications.length + i;
                listNotifications.add(
                  OneNotify(
                    avatarUrl: Host + data[i]['info_user']['avatar'],
                    messNotify: message,
                    timeNotify: DateTime.parse(data[i]['created_at'])
                        .toLocal()
                        .toString(),
                    // color: color,
                    callback: deleteNotify,
                    index: index,
                    notifyId: data[i]['notify_id'],
                    seen: data[i]['seen'],
                    route: routeScreen != null
                        ? () {
                            Navigator.push(
                              context,
                              SlideRightToLeftRoute(
                                page: routeScreen,
                              ),
                            );
                          }
                        : () {},
                  ),
                );
              }
              if (listNotifications.length > 0) {
                this.hasData = true;
              }
            });
          }
        } else if (code == 9999) {
          this.showError(
              'Kết nối mạng không ổn định hoặc server không phản hồi');
        }
      });
    } on Exception {
      this.showError('Kết nối mạng không ổn định hoặc server không phản hồi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          SmartRefresher(
            enablePullDown: true,
            header: MaterialClassicHeader(
              distance: 30.0,
              color: CircularColor,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: CustomScrollView(controller: _scrollController, slivers: [
              SliverAppBar(
                expandedHeight: 28,
                collapsedHeight: 27,
                toolbarHeight: 0,
                elevation: 0.4,
                backgroundColor: Color(0xFFFFFFFF),
                automaticallyImplyLeading: false,
                flexibleSpace: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Thông báo',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Container(
                      width: 33,
                      height: 33,
                      margin: EdgeInsets.only(right: 20),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: GreyIcon),
                      child: IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.search,
                          color: BlackColor,
                          size: 17,
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
                  ],
                ),
                pinned: true,
              ),
              internet
                  ? (!loading
                      ? (hasData
                          ? SliverList(
                              delegate: SliverChildListDelegate([
                                for (var item in listNotifications) item,
                                if (isLoadingMore)
                                  Container(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('đang tải...'),
                                      ),
                                    ),
                                  )
                              ]),
                            )
                          : SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  NoDataScreen(
                                    title: 'Không tìm thấy thông báo nào.',
                                    content:
                                        'Hãy tương tác nhiều hơn để nhận đc thông báo từ bạn bè.',
                                  )
                                ],
                              ),
                            ))
                      : SliverList(
                          delegate: SliverChildListDelegate([
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
                          ]),
                        ))
                  : SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          NoDataScreen(
                            title: 'Không có kết nối mạng',
                            content:
                                'Hãy kiểm tra lại đường truyền và thử lại sau',
                            emitParent:
                                this.getListNotifications(initIndex, initCount),
                          ),
                        ],
                      ),
                    ),
            ]),
          ),
          if (this.isShowPopupDeleteNotify) NotifyDeletePopup(),
        ],
      ),
    );
  }
}
