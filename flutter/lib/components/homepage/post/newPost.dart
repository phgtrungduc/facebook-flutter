import 'dart:convert';

import 'package:facebook/components/homepage/post/addNewPost.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/controller/InforUserController.dart';
import 'package:facebook/test/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  InforUserController _inforUserController;
  String avatar;
  void getInforUser() {
    _inforUserController.getUserInfor().then((value) {
      setState(() {
        avatar = jsonDecode(value.body)["data"]["avatar"];
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    _inforUserController = new InforUserController();
    getInforUser();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.only(top: 2),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: GreyBackgroud)),
                color: WhiteColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: this.avatar != null
                      ? NetworkImage(Host + this.avatar)
                      : AssetImage(PlaceHolderAvatarUrl),
                  radius: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: GreyTimeAndIcon),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: FlatButton(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Bạn đang nghĩ gì ? ",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20,
                              color: BlackColor.withOpacity(0.7),
                              fontWeight: FontWeight.w400),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddNewPost()),
                          );
                        },
                      )
                      // child: TextField(
                      //   onTap: (){
                      //     Navigator.push(
                      //               context,
                      //               MaterialPageRoute(builder: (context) => AddNewPost()),
                      //             );
                      //   },
                      //     style: TextStyle(fontSize: 20, color: BlackColor),
                      //     decoration: InputDecoration(
                      //       border: InputBorder.none,
                      //       hintText: "Bạn đang nghĩ gì ? ",
                      //     )),
                      ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: double.infinity,
            color: WhiteColor,
            child: Row(
              children: [
                Container(
                  width: size.width * 2 / 5,
                  child: FlatButton.icon(
                    icon: Icon(
                      Icons.videocam,
                      color: LiveStreamColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePageImage(title:"concac") ));
                    },
                    label: Expanded(
                        child: Container(
                      child: Text(
                        "Phát trực tiếp",
                        style: TextStyle(
                          color: BlackColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                  ),
                ),
                Container(
                  width: size.width / 5,
                  child: FlatButton.icon(
                    icon: FaIcon(
                      FontAwesomeIcons.images,
                      color: ImageColor,
                      size: 18,
                    ),
                    onPressed: () {},
                    label: Expanded(
                      child: Container(
                        child: Text(
                          "Ảnh",
                          style: TextStyle(color: BlackColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2 * size.width / 5,
                  child: FlatButton.icon(
                    icon: FaIcon(
                      FontAwesomeIcons.camera,
                      color: RoomColor,
                      size: 18,
                    ),
                    onPressed: () {},
                    label: Expanded(
                      child: Container(
                        child: Text(
                          "Phòng họp mặt",
                          style: TextStyle(color: BlackColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ]));
  }
}
