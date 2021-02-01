import 'dart:convert';

import 'package:facebook/components/homepage/post/newPost.dart';
import 'package:facebook/components/homepage/post/post.dart';
import 'package:facebook/components/homepage/stories.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/controller/HomePageController.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Homepage extends StatefulWidget {
  @override
  _Homepage createState() => _Homepage();
}

class _Homepage extends State<Homepage> {
  List<PostModel> listPost;
  bool isLoading = true;
  HomepageController _homepageController;
  int count=0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _controller = ScrollController();
  String Id;
  void initState() {
    super.initState();
    _homepageController = new HomepageController();
    _getId();
    this.loadData();
  }
  _getId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id_icre = prefs.getString("id_icre");
    setState(() {
      Id = id_icre;
    });
  }
  loadData() {
    setState(() {
      listPost = null;
    });
    try {
      _homepageController.getListPost().then((value) {
        if (jsonDecode(value.body)["data"].length != 0) {
          List<PostModel> temp = List<PostModel>();
          jsonDecode(value.body)["data"].forEach((element) {
            PostModel postModel = PostModel.fromJson(element);
            temp.add(postModel);
            setState(() {
              listPost = temp;
            });
          });
        }
        setState(() {
          isLoading = false;
        });
      }).catchError((e) {
        print(e.toString());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    print("refresh");
    // monitor network fetch
    this.loadData();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetc
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    // // _refreshController.loadNoData();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: NewPost(),
            ),
            SliverToBoxAdapter(
              child: Stories(),
            ),
            !isLoading
                ? (this.listPost != null
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return this.listPost[index].author.id==this.Id?PostTimeLine(
                            postModel: this
                                .listPost[index],isOwn: true,):PostTimeLine(
                            postModel: this
                                .listPost[index],isOwn: false,);

                           //Truyen tham so vao day
                        }, childCount: this.listPost.length),
                      )
                    : SliverToBoxAdapter(
                        child: NoDataScreen(
                          title: "Chưa có bất kì bài đăng nào",
                          content: "Hãy kết nối với bạn bè",
                          urlImage: "assets/images/conversation.png",
                        ),
                      ))
                : SliverToBoxAdapter(
                    child: Container(
                      child: _Loading(),
                    ),
                  )
          ],
        ),
      ),
      color: GreyBackgroud,
    );
  }
}
Widget _Loading() {
  return SingleChildScrollView(
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
                height: 100,
                color: BaseColor,
              ),
            ),
          ),
      ],
    ),
  );
}
