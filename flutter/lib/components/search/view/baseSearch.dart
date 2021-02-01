import 'package:connectivity/connectivity.dart';
import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/homepage/post/post.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/reuseComponent/searchBox.dart';
import 'package:facebook/components/search/controller/controller.dart';
import 'package:facebook/components/search/view/DailyScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class BaseSearchPage extends StatefulWidget {
  @override
  _BaseSearchPageState createState() => _BaseSearchPageState();
}

class _BaseSearchPageState extends State<BaseSearchPage>
    with SingleTickerProviderStateMixin {
  bool showHistory = true;
  String hintText = 'Tìm kiếm';
  bool loadingHistory = true;
  bool isLoadingMore = false;
  bool isLoadingMorePost = false;
  bool internet = true;

  int initCount = 10;
  int initIndex = 0;

  bool showLoadingSearch = false;
  bool hasData = false;

  String userId;

  String currentKeyword = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _searchController = SearchController();
  final _editController = TextEditingController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TabController _controller;
  ScrollController _scrollControllerUser;
  ScrollController _scrollControllerPost;
  @override
  void initState() {
    super.initState();
    _scrollControllerUser = ScrollController()..addListener(_loadMoreUser);
    _scrollControllerPost = ScrollController()..addListener(_loadMorePost);
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          if (_searchController.searchHistory.length == 0) {
            this.hasData = false;
          }
        });
      }
    });
    _controller = TabController(vsync: this, length: 2);
    this._getInfor();
    this.initHistorySearch();
  }

  void _getInfor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userIdLogged = prefs.getString("id_icre");
    setState(() {
      userId = userIdLogged;
    });
  }

  _loadMoreUser() async {
    if (isLoadingMore) return;
    if (_scrollControllerUser.position.pixels ==
        _scrollControllerUser.position.maxScrollExtent) {
      print('loadmore user');
      if (mounted) {
        setState(() {
          this.isLoadingMore = true;
        });
      }
      int index = _searchController.userResult.length;
      int count = 20;
      var res = await _searchController.searchUserHome(this.currentKeyword,
          count: count, index: index);
      setState(() {
        _searchController.userResult = res;
        this.isLoadingMore = false;
      });
    }
  }

  _loadMorePost() async {
    if (isLoadingMorePost) return;
    if (_scrollControllerPost.position.pixels ==
        _scrollControllerPost.position.maxScrollExtent) {
      if (mounted) {
        setState(() {
          this.isLoadingMorePost = true;
        });
      }
      print('loadmore post');
      int index = _searchController.postResult.length;
      int count = 20;
      var res = await _searchController.searchPostHome(this.currentKeyword,
          count: count, index: index);
      setState(() {
        _searchController.postResult = res;
        this.isLoadingMorePost = false;
      });
    }
  }

  Future<dynamic> initHistorySearch() async {
    await this.hasInternet();
    if (!internet) return;
    if (mounted) {
      setState(() {
        this.hasData = true;
      });
    }
    var res = await _searchController.getSearchHistory(count: 20, index: 0);
    // print(res);
    if (res == -1 || res == 0) {
      this.showError('Kết nối mạng không ổn định hoặc server không phản hồi');
      return;
    }
    if (mounted) {
      setState(() {
        if (_searchController.searchHistory.length == 0) {
          this.hasData = false;
        }
        this.loadingHistory = false;
      });
    }
    // print(listSearchHistory);
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
    );
  }

  Future<dynamic> search(String keyword, int count, int index) async {
    if (mounted) {
      setState(() {
        this.showLoadingSearch = true;
      });
    }
    print(keyword);
    var res1 = await _searchController.searchUserHome(keyword,
        count: count, index: index);
    var res2 = await _searchController.searchPostHome(keyword,
        count: count, index: index);
    if (mounted) {
      setState(() {
        this.showLoadingSearch = false;
      });
    }
    // if (res1 == -1 || res1 == 0 || res2 == -1 || res2 == 0) {
    //   this.showError('Kết nối mạng không ổn định hoặc server không phản hồi');
    //   return;
    // }
  }

  void _onRefreshUser() async {
    setState(() {
      this.showHistory = false;
    });
    await _searchController.searchUserHome(this.currentKeyword,
        count: initCount, index: initIndex);
    _refreshController.refreshCompleted();
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

  void _onRefreshPost() async {
    setState(() {
      this.showHistory = false;
    });
    await _searchController.searchPostHome(this.currentKeyword,
        count: initCount, index: initIndex);
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0.9,
        title: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: searchBox(
            editController: _editController,
            autoFocus: true,
            hintText: this.hintText,
            hasSuffix: true,
            onSubmittedFunction: (value) {
              if (mounted && value.trim() != "") {
                setState(() {
                  this.showHistory = false;
                });
                this.currentKeyword = value.trim();
                this.search(value, initCount, 0);
              }
            },
            onSuffixAction: () {
              if (_editController.text == "") return;
              _editController.clear();
              if (mounted) {
                setState(() {
                  this.showHistory = true;
                  this.initHistorySearch();
                });
              }
            },
          ),
        ),
      ), //tabbar

      backgroundColor: Colors.white,

      body: internet
          ? (showHistory
              ? (this.hasData
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: ListView(children: [
                        if (!this.loadingHistory)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gần đây',
                                style: TextStyle(fontSize: 18),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlideRightToLeftRoute(
                                      page: DailyScreen(),
                                    ),
                                  ).whenComplete(
                                      () => this.initHistorySearch());
                                },
                                padding: EdgeInsets.all(0),
                                color: Color(0xFFFFFFFF),
                                elevation: 0.0,
                                focusElevation: 0.0,
                                hoverElevation: 0.0,
                                highlightElevation: 0.0,
                                disabledElevation: 0.0,
                                highlightColor: Color(0xFFFFFFFF),
                                focusColor: Color(0xFFFFFFFF),
                                child: Text(
                                  'Chỉnh sửa',
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: Color(0xFFEEEEEEEE),
                        ),
                        for (var item in _searchController.searchHistory)
                          oneSearch(item.content, item.searchId)
                      ]),
                    )
                  : NoDataScreen(
                      title: 'Hãy nhập và tìm kiếm gì đó',
                      urlImage: PlaceHolderSearchUrl,
                    ))
              : !this.showLoadingSearch
                  ? Scaffold(
                      backgroundColor: GreyTimeAndIcon,
                      appBar: AppBar(
                        toolbarHeight: 50,
                        elevation: 0.0,
                        bottom: TabBar(
                          controller: _controller,
                          labelPadding:
                              EdgeInsets.only(left: 0, right: 8, bottom: 0),
                          isScrollable: false,
                          tabs: [Tab(text: 'Mọi người'), Tab(text: 'Bài đăng')],
                        ),
                      ),
                      body: TabBarView(
                        controller: _controller,
                        children: [
                          SmartRefresher(
                            enablePullDown: true,
                            header: MaterialClassicHeader(
                              distance: 30.0,
                              color: CircularColor,
                            ),
                            controller: _refreshController,
                            onRefresh: _onRefreshUser,
                            child: ListView(
                              controller: _scrollControllerUser,
                              children: _searchController.userResult.length > 0
                                  ? [
                                      for (var user
                                          in _searchController.userResult)
                                        onePerson(user.user),
                                      if (this.isLoadingMore)
                                        Container(
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text('đang tải...'),
                                            ),
                                          ),
                                        )
                                    ]
                                  : [
                                      NoDataScreen(
                                          title:
                                              'Không có kết quả tìm kiếm phù hợp',
                                          content:
                                              'Hãy cùng thử tìm kiếm người bạn khác khác nào')
                                    ],
                            ),
                          ),
                          SmartRefresher(
                            enablePullDown: true,
                            header: MaterialClassicHeader(
                              distance: 30.0,
                              color: CircularColor,
                            ),
                            controller: _refreshController,
                            onRefresh: _onRefreshPost,
                            child: ListView(
                              controller: _scrollControllerPost,
                              children: _searchController.postResult.length > 0
                                  ? [
                                      for (var item
                                          in _searchController.postResult)
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: PostTimeLine(
                                            postModel: item,
                                            isOwn: userId == item.author.id,
                                          ),
                                        ),
                                      if (this.isLoadingMorePost)
                                        Container(
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text('đang tải...'),
                                            ),
                                          ),
                                        )
                                    ]
                                  : [
                                      NoDataScreen(
                                          title: 'Không có bài viết phù hợp',
                                          content:
                                              'Hãy cùng thử tìm kiếm bài viết khác nào')
                                    ],
                            ),
                          ),
                        ],
                      ),
                    )
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
                    ))
          : NoDataScreen(
              title: 'Không có kết nối mạng',
              content: 'Hãy kiểm tra lại đường truyền và thử lại sau',
              emitParent: this.initHistorySearch(),
            ),
    );
  }

  Widget oneSearch(String content, int searchId) {
    return GestureDetector(
      onTap: () {
        _editController.text = content;
        this.currentKeyword = content;
        var value = content;
        if (mounted && value.trim() != "") {
          setState(() {
            this.showHistory = false;
          });
          this.search(value, initCount, 0);
        }
      },
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 28,
            color: Color(0xFF757575),
          ),
          Expanded(
            child: ListTile(
              dense: true,
              title: Text(
                content,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Card onePerson(Map infor) {
    String userName = infor['username'] == null ? 'null' : infor['username'];
    String userId = infor['user_id'].toString();
    return Card(
      margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: ListTile(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String id = prefs.getString("id_icre");
            bool isOwner = id == userId;
            Navigator.push(
              context,
              SlideRightToLeftRoute(
                page: UserWall(
                  userId: userId,
                  isOwner: isOwner,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: BaseColor,
            backgroundImage: infor['avatar'] == null
                ? AssetImage(PlaceHolderAvatarUrl)
                : NetworkImage(Host + infor['avatar']),
          ),
          title: Text(
            userName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: BlackColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          // subtitle: infor,
        ),
      ),
    );
  }
}
