import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/Elements/userFriend.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/homepage/post/newPost.dart';
import 'package:facebook/components/homepage/post/post.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/search/view/baseSearch.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:facebook/model/UserInfor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'Elements/userImages.dart';
import 'Elements/userInfor.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserWall extends StatelessWidget {
  final String userId;
  final bool isOwner;

  const UserWall({Key key, this.userId, this.isOwner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0.9,
        title: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  SlideRightToLeftRoute(
                    page: BaseSearchPage(),
                  ),
                );
              },
              child: Container(
                width: size.width * 0.8,
                height: 38,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: Color(0xFFFFFFFF), width: 0.0),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF757575),
                      ),
                    ),
                    Text(
                      'Tìm kiếm',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ), //tabbar

      backgroundColor: Colors.white,

      body: UserProfileBody(
        userId: this.userId,
        isOwner: this.isOwner,
        // parent: this,
      ),
    );
  }
}

class UserProfileBody extends StatefulWidget {
  UserProfileBody({
    Key key,
    @required this.userId,
    this.isOwner,
  }) : super(key: key);

  String userId;
  final bool isOwner;

  @override
  _UserProfileBodyState createState() => _UserProfileBodyState();
}

class _UserProfileBodyState extends State<UserProfileBody> {
  Map userInfor = Map();
  bool isLoading = false;
  bool hasData = true;
  bool internet = true;

  ScrollController _scrollController;
  int initCount = 5;
  int initIndex = 0;
  List lisPost = [];
  bool isLoadingMore = false;
  bool loading = false;
  bool hasDataPost = false;

  String ownId;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var userChatInfo;

  @override
  void initState() {
    super.initState();
    this.getUserInfo(widget.userId);
    _scrollController = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> hasInternet() async {
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

  void callbackRefresh() {
    this.getUserInfo(widget.userId);
  }

  void _onRefresh() async {
    await this.getUserInfo(widget.userId);
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // await this.getUserInfo(widget.userId);
    // // if failed,use loadFailed(),if no data return,use LoadNodata()
    // if (mounted) setState(() {});
    // _refreshController.loadComplete();
  }

  void snackBar(String text, BuildContext context) {
    var snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<void> getUserInfo(String userId) async {
    await this.hasInternet();
    if (this.internet == false) return;
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    API api = new API();
    try {
      await api.getUserInfor(widget.userId).then((res) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          setState(() {
            this.hasData = true;
            userInfor.clear();
            userInfor = json.decode(res.body)["data"];
            userChatInfo = UserChatInfor.fromJson(userInfor);
            ownId = prefs.getString('id_user');
          });
        } else if (code == 9999) {
          setState(() {
            this.hasData = false;
          });
        }
      });
      this.getPostUser(initCount, initIndex);
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
  }

  Future<void> getPostUser(int count, int index, {loadmore = false}) async {
    if (mounted && !loadmore) {
      setState(() {
        this.loading = true;
      });
    }
    try {
      await API().getMyListPosts(widget.userId, count, index).then((res) {
        if (mounted && !loadmore) {
          setState(() {
            this.loading = false;
          });
        }
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          var data = json.decode(res.body)["data"];
          setState(() {
            for (var i = 0; i < data.length; i++) {
              this.lisPost.add(PostModel.fromJson(data[i]));
            }
            if (lisPost.length > 0) {
              hasDataPost = true;
            }
          });
        } else if (code == 9999) {
          snackBar(
              "Kết nối mạng không ổn định hoặc server không phản hồi", context);
        }
      });
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
  }

  _loadMore() async {
    if (this.isLoadingMore == true) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (mounted) {
        setState(() {
          this.isLoadingMore = true;
        });
      }
      int index = this.lisPost.length;
      int count = 5;
      await this.getPostUser(count, index, loadmore: true);
      if (mounted) {
        setState(() {
          this.isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      header: MaterialClassicHeader(
        distance: 30.0,
        color: CircularColor,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: this.internet
          ? (this.hasData
              ? ListView(
                  controller: _scrollController,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 15), // padding for all page
                      child: Column(
                        children: [
                          //cover image of user and avatar of user
                          UserImages(
                            userId: widget.userId,
                            isOwner: widget.isOwner,
                            avatarUrl: this.userInfor['avatar'] == null
                                ? null
                                : Host + this.userInfor['avatar'],
                            coverUrl: this.userInfor['cover_photo'] == null
                                ? null
                                : Host + this.userInfor['cover_photo'],
                            userName: this.userInfor['name'],
                            isFriend: this.userInfor['is_friend'],
                            isLoading: this.isLoading,
                            callbackRefresh: this.callbackRefresh,
                            userChatInfo: this.userChatInfo,
                            ownID: this.ownId,
                          ),
                          //infor of user
                          UserInfor(
                            userId: widget.userId,
                            isOwner: widget.isOwner,
                            address: this.userInfor['address'],
                            city: this.userInfor['city'],
                            isLoading: this.isLoading,
                            callbackRefresh: this.callbackRefresh,
                          ),
                          //user and friend
                          UserFriends(
                            userId: widget.userId,
                            userName: this.userInfor['name'],
                            isLoading: this.isLoading,
                            isOwner: widget.isOwner,
                            callbackRefresh: this.callbackRefresh,
                            // parent: parent,
                          ),
                        ],
                      ),
                    ),
                    //big devider
                    Divider(
                      height: 30,
                      color: Colors.grey[400],
                      thickness: 12,
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15, bottom: 11),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Bài viết',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (widget.isOwner) NewPost(),
                        ],
                      ),
                    ),
                    Divider(
                      height: 30,
                      color: Colors.grey[400],
                      thickness: 12,
                    ),
                    if (!this.isLoading)
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        child: Wrap(
                          spacing: 10,
                          children: [
                            RaisedButton(
                              padding: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 7, right: 7),
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              onPressed: () {},
                              child: Wrap(
                                spacing: 5,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 22,
                                  ),
                                  Text(
                                    'Ảnh',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    Divider(
                      height: 30,
                      color: Colors.grey[400],
                      thickness: 12,
                    ),
                    Container(
                      color: Color(0xFFF5F5F5),
                      child: (this.isLoading == false && this.loading == false)
                          ? (this.hasDataPost
                              ? Column(
                                  children: [
                                    for (var item in this.lisPost)
                                      PostTimeLine(
                                        postModel: item,
                                        isOwn: widget.isOwner,
                                      ),
                                    if (this.isLoadingMore)
                                      Container(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('đang tải...'),
                                          ),
                                        ),
                                      )
                                  ],
                                )
                              : (!widget.isOwner
                                  ? NoDataScreen(
                                      title: 'Không có bài viết nào',
                                    )
                                  : NoDataScreen(
                                      title: 'Bạn không có bài viết nào',
                                      content:
                                          'Hãy chia sẻ thêm để mọi người biết bạn đang nghĩ gì <3',
                                    )))
                          : Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Column(
                                children: [
                                  for (int i = 0; i < 5; i++)
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
                    )
                  ],
                )
              : NoDataScreen(
                  title:
                      'Người dùng không tồn tại hoặc bạn đã bị chặn hoặc bị chặn.',
                  urlImage: PlaceHolderAvatarUrl,
                ))
          : NoDataScreen(
              title: 'Không có kết nối mạng',
              userId: widget.userId,
              emitParent: this.getUserInfo(widget.userId),
            ),
    );
  }
}
