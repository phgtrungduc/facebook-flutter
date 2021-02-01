import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/homepage/post/comment.dart';
import 'package:facebook/components/homepage/post/editPost.dart';
import 'package:facebook/components/homepage/post/imagesPost.dart';
import 'package:facebook/components/playVideo/PlayVideo.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/mainScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';

class PostTimeLine extends StatelessWidget {
  PostModel postModel;
  bool isOwn;
  // final Post post;

  PostTimeLine({Key key, this.postModel, this.isOwn})
      : super(
            key:
                key); //1 doi tuong post la 1 bai post bao gom anh, thoi gian, caption,...
  Widget buildGridView() {
    int number = postModel.images.length;
    List<String> listImage = List<String>.from(postModel.images);
    if (number == 0) {
      return SizedBox.shrink();
    } else if (number == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                    height: 200,
                    child:
                        Image.network(Host + listImage[0], fit: BoxFit.cover)),
                Container(
                    height: 200,
                    child:
                        Image.network(Host + listImage[1], fit: BoxFit.cover))
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                  height: 400,
                  child: Image.network(Host + listImage[2], fit: BoxFit.cover)))
        ],
      );
    } else {
      if (number > 2) number = 2;
      return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: (number != 0) ? number : 2,
        children: List.generate(number, (index) {
          return Image.network(Host + listImage[index], fit: BoxFit.cover);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.symmetric(vertical: 5.0),
        color: WhiteColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostHeader(
                    name: this.postModel.author.name,
                    avatar: this.postModel.author.avatar,
                    status: this.postModel.status,
                    created_at: this.postModel.created_at,
                    postId: this.postModel.id,
                    isOwn: this.isOwn,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  if (postModel.described != null)
                    ReadMoreText(postModel.described,
                        trimLines: 10,
                        colorClickableText: BlueColor,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: '...Xem thêm',
                        trimExpandedText: '..Thu gọn',
                        moreStyle: TextStyle(
                            color: BlackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                  onTap: () {
                    if (this.postModel.images != null &&
                        this.postModel.images.length >= 2) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ImagesPost(postModel: this.postModel)));
                    }
                    ;
                  },
                  child: (this.postModel.video.length > 0)
                      ? OneVideo(url: Host + this.postModel.video[0])
                      : buildGridView()),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: PostStat(
                like: this.postModel.like,
                comment: this.postModel.comment,
                is_liked: this.postModel.is_liked,
                postId: this.postModel.id,
              ),
            ),
          ],
        ));
  }
}

class PostHeader extends StatelessWidget {
  API api = new API();
  dynamic getAvatar(String avatar) {
    if (avatar == null) {
      return AssetImage('assets/images/avatar_placeholder.png');
    } else {
      return NetworkImage(Host + avatar);
    }
  }

  String name;
  String avatar;
  String status;
  DateTime created_at;
  String postId;
  bool isOwn;
  PostHeader({this.name, this.avatar, this.status, this.created_at,this.postId, this.isOwn});
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
  @override
  Widget build(BuildContext context) {
    return Container(
      color: WhiteColor,
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: getAvatar(this.avatar)),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (this.status != null&&this.status.trim()!="")
                    ? RichText(
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: this.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: BlackColor),
                            ),
                            TextSpan(
                                text: " ― Đang ",
                                style:
                                    TextStyle(fontSize: 17, color: BlackColor)),
                            WidgetSpan(
                              child: FaIcon(FontAwesomeIcons.smile, size: 17),
                            ),
                            TextSpan(
                                text: " cảm thấy ",
                                style:
                                    TextStyle(fontSize: 17, color: BlackColor)),
                            TextSpan(
                              text: this.status,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: BlackColor),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        this.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: BlackColor),
                      ),
                Row(
                  children: [
                    Text(
                      this.getDifferenceDate(this.created_at),
                      style: TextStyle(color: GreyFontColor),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Icon(
                      Icons.public,
                      color: GreyFontColor,
                    ),
                  ],
                )
              ],
            ),
          ),
          Material(
            child: FlatButton(
              shape: CircleBorder(),
              child: Icon(Icons.more_horiz),
              onPressed: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10))),
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                                leading: Icon(
                                  Icons.notifications_off,
                                  color: BlackColor,
                                  size: 30,
                                ),
                                title: Text("Tắt thông báo về bài viết này",
                                    style: TextStyle(
                                        fontSize: 18, color: BlackColor)),
                                onTap: () {}),
                          ),
                          if(isOwn) Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: BlackColor,
                                size: 30,
                              ),
                              title: Text("Xóa",
                                  style: TextStyle(
                                      color: BlackColor, fontSize: 18)),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Xác nhận xóa"),
                                      content: Text("Bạn có muốn xóa bài đăng này?"),
                                      actions: [
                                        FlatButton(onPressed:(){
                                          showLoaderDialog(context);
                                          api.delete_post(this.postId).then((res){
                                            int code = json.decode(res.body)["code"];
                                            if (code==1000){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => MainScreen()),
                                              );
                                            }else {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              showDialog(context: context,builder: (BuildContext context) => AlertDialog(title: Text("Xóa không thành công"),));
                                            }
                                          });
                                        }, child: Text("Có")),
                                        FlatButton(onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        }, child: Text("Không"))
                                      ],
                                    );;
                                  },
                                );
                              },
                            ),
                          ),
                          if(isOwn) Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: Icon(
                                Icons.mode_edit,
                                color: BlackColor,
                                size: 30,
                              ),
                              title: Text("Chỉnh sửa bài viết",
                                  style:
                                  TextStyle(color: BlackColor, fontSize: 18)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditPost(postId: this.postId,)),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: Icon(
                                Icons.report,
                                color: BlackColor,
                                size: 30,
                              ),
                              title: Text("Tìm hỗ trợ hoặc báo cáo bài viết",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: BlackColor,
                                  )),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Xác nhận báo cáo"),
                                      content: Text("Bạn có muốn báo cáo bài đăng này?"),
                                      actions: [
                                        FlatButton(onPressed:(){
                                          showLoaderDialog(context);
                                          api.reportPost(this.postId).then((res){
                                            int code = json.decode(res.body)["code"];
                                            if (code==1000){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => MainScreen()),
                                              );
                                              showDialog(context: context,
                                                  builder: (BuildContext context) =>
                                                      AlertDialog(title: Text("Thành công"),
                                                        content:Row(
                                                          children:[
                                                            CircleAvatar(
                                                              radius: 20,
                                                              backgroundImage: AssetImage("assets/images/check.png")
                                                            ),
                                                            SizedBox(width: 5,),
                                                            Text("Báo cáo bài đăng thành công!")
                                                          ]
                                                        )));
                                            }else {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              showDialog(context: context,builder: (BuildContext context) => AlertDialog(title: Text("Báo cáo bài đăng thất bại"),));
                                            }
                                          });
                                        }, child: Text("Có")),
                                        FlatButton(onPressed: (){
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        }, child: Text("Không"))
                                      ],
                                    );;
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}

class PostStat extends StatefulWidget {
  bool is_liked;
  int like;
  int comment;
  String postId;
  PostStat({this.like, this.comment, this.is_liked, this.postId});
  @override
  _PostStat createState() => _PostStat();
}

const LikeIcon = [FontAwesomeIcons.thumbsUp, FontAwesomeIcons.solidThumbsUp];

class _PostStat extends State<PostStat> {
  bool isLike;
  int like;
  int comment;
  @override
  void initState() {
    super.initState();
    setState(() {
      this.isLike = widget.is_liked;
      this.like = widget.like;
      this.comment = widget.comment;
    });
  }

  setLike() {
    API api = new API();
    api.like(widget.postId).then((res) {
      int code = json.decode(res.body)["code"];
      if (code == 1000) {
        if (isLike) {
          bool newLike = !this.isLike;
          int newLikeCount = this.like;
          if (this.like > 0) newLikeCount = this.like - 1;
          setState(() {
            isLike = newLike;
            like = newLikeCount;
          });
        } else {
          bool newLike = !this.isLike;
          int newLikeCount = this.like + 1;
          setState(() {
            isLike = newLike;
            like = newLikeCount;
          });
        }
      } else {
        print("Không thành công");
      }
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration:
                  BoxDecoration(color: BlueColor, shape: BoxShape.circle),
              child: Icon(
                Icons.thumb_up,
                size: 12,
                color: WhiteColor,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
                child: Text(this.like.toString(),
                    style: TextStyle(color: GreyFontColor))),
            Text(this.comment.toString() + " bình luận",
                style: TextStyle(color: GreyFontColor)),
          ],
        ),
        Divider(color: GreyTimeAndIcon),
        Container(
          height: 30,
          child: Row(
            children: [
              this.isLike
                  ? _PostButton(
                      icon: FaIcon(LikeIcon[1], color: BlueColor, size: 20.0),
                      label: 'Thích',
                      onTap: () {
                        setLike();
                      },
                      isLike: this.isLike,
                    )
                  : _PostButton(
                      icon:
                          FaIcon(LikeIcon[0], color: GreyAboutPost, size: 20.0),
                      label: 'Thích',
                      onTap: () {
                        setLike();
                      },
                      isLike: this.isLike,
                    ),
              VerticalDivider(color: GreyAboutPost),
              _PostButton(
                icon: FaIcon(FontAwesomeIcons.comment,
                    color: GreyAboutPost, size: 20.0),
                label: 'Bình Luận',
                onTap: () {
                  showMaterialModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10))),
                      context: context,
                      builder: (context) => SafeArea(
                            child: Comment(
                                postId: widget.postId,
                                like: widget.like,
                                comment: widget.comment),
                          ),
                      expand: true);
                },
                isLike: false,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final FaIcon icon;
  final String label;
  final Function onTap;
  final bool isLike;

  const _PostButton(
      {Key key,
      @required this.icon,
      @required this.label,
      @required this.onTap,
      @required this.isLike})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            height: 25.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 4.0),
                Text(
                  label,
                  style: TextStyle(color: isLike ? BlueColor : GreyAboutPost),
                ),
              ],
            ),
          ),
        ),
      ),
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