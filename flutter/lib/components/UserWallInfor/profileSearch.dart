import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/homepage/post/post.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/reuseComponent/searchBox.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSearch extends StatefulWidget {
  final String userId;
  final String userName;

  const ProfileSearch({Key key, this.userId, this.userName}) : super(key: key);

  @override
  _ProfileSearchState createState() => _ProfileSearchState();
}

class _ProfileSearchState extends State<ProfileSearch> {
  int count = 20;
  int index = 0;
  String currentKeyword = '';
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = true;
  bool isSearching = false;

  final _editController = TextEditingController();
  ScrollController _scrollController;
  List searchPost = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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

  _loadMore() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (currentKeyword != "") {
        var count = this.searchPost.length + 20;
        var index = this.searchPost.length;
        print('loadmore ori');
        this.searchPostUser(currentKeyword,
            index: index, count: count, loadmore: true);
      }
    }
  }

  Future<void> searchPostUser(String keyword,
      {count, index, loadmore = false}) async {
    if (count == null || index == null) {
      count = this.count;
      index = this.index;
    }
    if (mounted && !loadmore) {
      this.searchPost.clear();
      this.isLoading = true;
    }
    try {
      await API()
          .getPostOfUser(widget.userId, keyword, count: count, index: index)
          .then((res) {
        if (mounted && !loadmore) {
          this.isLoading = false;
        }
        int code = json.decode(res.body)["code"];
        // print(res.body);
        if (code == 1000) {
          var data = json.decode(res.body)["data"];
          // print(data);
          setState(() {
            for (var i = 0; i < data.length; i++) {
              this.searchPost.add(PostModel.fromJson(data[i]));
            }
          });
        } else if (code == 9999) {
          this.showError(
              "Kết nối mạng không ổn định hoặc server không phản hồi");
        }
      });
    } on Exception {
      this.showError("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMore);
  }

  void _onRefresh() async {
    this._editController.clear();
    currentKeyword = '';
    setState(() {
      this.searchPost.clear();
      this.isSearching = false;
    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
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
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0.9,
        title: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: searchBox(
            autoFocus: true,
            hintText: 'Tìm kiếm trong bài viết, ảnh và hơn thế nữa',
            hasSuffix: true,
            editController: _editController,
            onSuffixAction: () {
              _editController.clear();
              setState(() {
                this.isSearching = false;
              });
            },
            onTapFunction: () {
              print('tap');
            },
            onChangedFunction: (text) {
              if (text == "") {
                setState(() {
                  this.searchPost.clear();
                  this.isSearching = false;
                  currentKeyword = '';
                });
              }
            },
            onSubmittedFunction: (text) {
              text = text.trim();
              if (text != "") {
                setState(() {
                  this.isSearching = true;
                });
                this.searchPostUser(text, count: 20, index: 0);
                currentKeyword = text;
              } else {
                setState(() {
                  this.isSearching = false;
                  this.searchPost.clear();
                  currentKeyword = '';
                });
              }
            },
          ),
        ),
      ),
      backgroundColor: Color(0xFFFFFFFFF),
      body: SmartRefresher(
        enablePullDown: true,
        header: MaterialClassicHeader(
          distance: 30.0,
          color: CircularColor,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: this.isSearching
            ? !this.isLoading
                ? (this.searchPost.length > 0
                    ? Container(
                        color: GreyBackgroud,
                        child: ListView(
                          controller: _scrollController,
                          children: [
                            for (var item in searchPost)
                              PostTimeLine(
                                postModel: item,
                                isOwn: widget.userId == item.author.id,
                              ),
                          ],
                        ),
                      )
                    : Container(
                        child: NoDataScreen(
                          title: 'Oops!!! :((',
                          content: 'Không có dữ liệu trùng khớp.',
                        ),
                      ))
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
                  )
            : Container(
                child: NoDataScreen(
                  title: 'Bạn đang tìm gì à',
                  content:
                      'Tìm kiếm trong trang cá nhân ${widget.userName} để biết thêm điều gì đó.',
                ),
              ),
      ),
    );
  }
}
