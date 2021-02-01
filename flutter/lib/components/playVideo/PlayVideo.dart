import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/homepage/post/post.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/search/view/baseSearch.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  List listVideos = [];
  int initCount = 3;
  int initIndex = 0;

  bool isLoadingMore = false;

  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController;

  String userId;

  bool internet = true;
  bool loading = false;
  bool hasData = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMore);
    this._getInfor();
    this.getListVideos(initIndex, initCount);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _getInfor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userIdLogged = prefs.getString("id_icre");
    setState(() {
      userId = userIdLogged;
    });
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
    await this.getListVideos(initIndex, initCount);
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
        int index = this.listVideos.length;
        await this.getListVideos(index, initCount, loadmore: true);
        setState(() {
          this.isLoadingMore = false;
        });
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
    );
  }

  Future<void> getListVideos(int index, int count, {loadmore = false}) async {
    await this.hasInternet();
    if (!internet) return;
    if (mounted && !loadmore) {
      setState(() {
        this.loading = true;
      });
    }
    try {
      API().getListVideos(index, count).then((res) {
        if (mounted && !loadmore) {
          setState(() {
            this.loading = false;
          });
        }
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          var data = json.decode(res.body)['data'];
          print(data);
          setState(() {
            for (var i = 0; i < data.length; i++) {
              listVideos.add(
                PostModel.fromJson(data[i]),
              );
            }
            if (listVideos.length > 0) {
              this.hasData = true;
            }
          });
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
                          'Khoảnh khắc',
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
                                for (var item in listVideos)
                                  PostTimeLine(
                                    postModel: item,
                                    isOwn: userId == item.author.id,
                                  ),
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
                                    title: 'Không tìm thấy video nào.',
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
                                this.getListVideos(initIndex, initCount),
                          ),
                        ],
                      ),
                    ),
            ]),
          ),
        ],
      ),
    );
  }
}

class OneVideo extends StatefulWidget {
  String url;
  OneVideo({Key key, this.url}) : super(key: key);
  @override
  _OneVideoState createState() => _OneVideoState();
}

class _OneVideoState extends State<OneVideo> {
  VideoPlayerController _controller;
  bool looping = true;
  @override
  void initState() {
    super.initState();
    print(widget.url);
    if (widget.url != null) {
      _controller = VideoPlayerController.network(widget.url)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          _controller.setLooping(looping);
        });
    }
  }

  bool showButtonControll = true;
  Widget buildVideo(Size size) {
    return Center(
      child: _controller.value.initialized
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: () {
                  if (!this.showButtonControll) {
                    if (mounted) {
                      this.setState(() {
                        this.showButtonControll = true;
                      });
                      Timer(Duration(seconds: 5), () {
                        setState(() {
                          this.showButtonControll = false;
                        });
                      });
                    }
                  }
                },
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    Align(
                      alignment: Alignment.center,
                      child: this.showButtonControll
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                  Timer(Duration(seconds: 5), () {
                                    if (mounted) {
                                      setState(() {
                                        this.showButtonControll = false;
                                      });
                                    }
                                  });
                                });
                              },
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: WhiteColor,
                                size: 50,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            )
          : Container(
              width: size.width,
              height: size.width * (9 / 16),
              color: BlackColor,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return buildVideo(size);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
