import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/model/CommentModel.dart';
import 'package:facebook/model/UserInfor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Comment extends StatefulWidget {
  String postId;
  int like;
  int comment;
  Comment({@required this.postId, this.like, this.comment});
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  API api;
  int isLoading = 0; //0 là chưa load, 1 là có dữ liệu, 2 là không có dữ liệu
  List<UserChatInfor> author;
  List<CommentModel> comment;
  ScrollController _scrollController;
  bool hasContent = false;
  bool loadingComment = false;
  TextEditingController _inputController;
  initState() {
    api = new API();
    _scrollController = new ScrollController();
    _inputController = new TextEditingController();
    this.loadData();
    _inputController.addListener(() {
      if (_inputController.text != null && _inputController.text.trim() != "") {
        setState(() {
          hasContent = true;
        });
      } else {
        setState(() {
          hasContent = false;
        });
      }
    });
  }
  String formatDate(DateTime date) {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    return dateFormat.format(date);
  }
  getDifferenceDate(DateTime date){
    DateTime now = DateTime.now();
    int difference = now.difference(date).inSeconds;
    if (difference>=60){
      difference =  now.difference(date).inMinutes;
      if (difference>=60){
        difference =  now.difference(date).inHours;
        if (difference>=24){
          difference =  now.difference(date).inDays;
          if (difference>7){
            return formatDate(date);
          }
          else {
            return difference.toString()+" ngày trước";
          }
        }else {
          return difference.toString()+" giờ trước";
        }
      }else {
        return difference.toString()+" phút trước";
      }
    }
    else {
      return "vài giây trước";
    }
  }
  loadData() {
    api.getComment(widget.postId).then((value) {
      int code = json.decode(value.body)["code"];
      if (code == 1000) {
        if (jsonDecode(value.body)["data"].length != 0) {
          List<UserChatInfor> authorTemp = new List<UserChatInfor>();
          List<CommentModel> commentTemp = new List<CommentModel>();
          jsonDecode(value.body)["data"].forEach((element) {
            UserChatInfor userInfor = UserChatInfor.fromJson(element["author"]);
            CommentModel commentInfor = CommentModel.fromJson(element);
            authorTemp.add(userInfor);
            commentTemp.add(commentInfor);
            setState(() {
              author = authorTemp;
              comment = commentTemp;
            });
          });

          setState(() {
            isLoading = 1;
          });
        } else {
          setState(() {
            isLoading = 2;
          });
        }
      } else if (code == 994) {
        setState(() {
          isLoading = 2;
        });
      }
      ;
    }).catchError((e) {
      print(e.toString());
    });
  }

  Widget InputComment() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            color: GreyBackgroud),
        child: TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          controller: _inputController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Viết bình luận ...",
            suffixIcon: this.hasContent
                ? (this.loadingComment
                    ? CircularProgressIndicator(backgroundColor: GreyAboutPost)
                    : IconButton(
                        icon: FaIcon(FontAwesomeIcons.solidPaperPlane,
                            color: BlueColor, size: 35),
                        onPressed: () {
                          this.addComment();
                        }))
                : SizedBox.shrink(),
          ),
        ));
  }

  addComment() {
    setState(() {
      loadingComment = true;
    });
    api.set_comment(widget.postId, _inputController.text).then((res) {
      _inputController.text = "";
      this.loadData();
      setState(() {
        loadingComment = false;
      });
    }).catchError((e) {
      print(e.toString());
      setState(() {
        loadingComment = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.isLoading == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
      return SafeArea(
          child: Material(
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.like.toString(),
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  padding: EdgeInsets.all(3),
                  decoration:
                      BoxDecoration(color: BlueColor, shape: BoxShape.circle),
                  child: Icon(
                    Icons.thumb_up,
                    size: 15,
                    color: WhiteColor,
                  ),
                )
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.thumb_up, size: 25, color: BlueColor),
                onPressed: () {},
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: GreyBackgroud)),
                      color: WhiteColor),
                ),
                Expanded(
                    child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return SingleComment(
                        author: this.author[index],
                        comment: this.comment[index].comment,
                    created_at: getDifferenceDate(this.comment[index].created_at),);
                    // if (index == 9)
                    //   return SingleComment(
                    //       author: this.author[0], comment: "ke tao cuoi cung");
                    // else
                    //   return SingleComment(
                    //       author: this.author[0], comment: "ke tao");
                  },
                  scrollDirection: Axis.vertical,
                  itemCount: this.author.length,
                )),
                InputComment()
              ],
            ),
          ),
        ),
      ));
    } else if (this.isLoading == 0) {
      return SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: GreyBackgroud)),
                  color: WhiteColor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(widget.like.toString()),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: BlueColor, shape: BoxShape.circle),
                          child: Icon(
                            Icons.thumb_up,
                            size: 12,
                            color: WhiteColor,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _Loading())
          ],
        ),
      ));
    } else {
      return SafeArea(
          child: Material(
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.like.toString(),
                  style: TextStyle(fontSize: 18),
                ),

              ],
            ),
            title: Container(
              padding: EdgeInsets.all(3),
              decoration:
              BoxDecoration(color: BlueColor, shape: BoxShape.circle),
              child: Icon(
                Icons.thumb_up,
                size: 15,
                color: WhiteColor,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.thumb_up, size: 25, color: BlueColor),
                onPressed: () {},
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: GreyBackgroud)),
                      color: WhiteColor),
                ),
                Expanded(
                    child: NoDataScreen(
                  title: "Chưa có bình luận nào",
                  content: "Hãy là người đấu tiên bình luận",
                  urlImage: "assets/images/comment.png",
                )),
                InputComment()
              ],
            ),
          ),
        ),
      ));
    }
  }
}

class SingleComment extends StatefulWidget {
  UserChatInfor author;
  String comment;
  String created_at;
  SingleComment({@required this.author, @required this.comment,@required this.created_at});
  @override
  _SingleCommentState createState() => _SingleCommentState();
}

class _SingleCommentState extends State<SingleComment> {
  bool isLike = false;
  dynamic getAvatar(String avatar) {
    if (avatar == null) {
      return AssetImage('assets/images/avatar_placeholder.png');
    } else {
      return NetworkImage(Host + avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(right: 15),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: getAvatar(widget.author.avatar),
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                        child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: greyChat,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.author.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17)),
                          Text(
                            widget.comment,
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    )),
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(widget.created_at),
                            SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLike = !this.isLike;
                                });
                              },
                              child: Text("Thích",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: this.isLike
                                          ? BlueColor
                                          : GreyAboutPost)),
                            )
                          ]),
                    )
                  ],
                ),
              )
            ],
          )),
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
  );
}
