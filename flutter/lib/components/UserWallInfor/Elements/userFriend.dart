import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/seeAllFriend.dart';
import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/friendsPage/friendsPage.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class UserFriends extends StatefulWidget {
  final String userId;
  final String userName;
  bool isOwner;
  bool isLoading;
  Function callbackRefresh;

  UserFriends(
      {Key key, this.userId, this.userName, this.isLoading, this.isOwner, this.callbackRefresh})
      : super(key: key);

  @override
  _UserFriendsState createState() => _UserFriendsState();
}

class _UserFriendsState extends State<UserFriends> {
  List listUserFriends = [];
  List listUserFriendsUi = [];
  int totalFriend = 0;
  @override
  void initState() {
    super.initState();
    // this.getUserFriends(0, 6, widget.userId);
  }

  void snackBar(String text, BuildContext context) {
    var snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void getUserFriends(int index, int count, String userId) async {
    API api = new API();
    try {
      await api.getUserFriends(index, count, userId: userId).then((res) {
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          Map data = json.decode(res.body)['data'];
          setState(() {
            listUserFriends.clear();
            listUserFriendsUi.clear();
            listUserFriends = data["friends"];
            totalFriend = data['total'];
            for (var i = 0; i < data['total']; i++) {
              listUserFriendsUi.add(
                friendInfor(listUserFriends[i]['info'], context),
              );
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

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      this.getUserFriends(0, 6, widget.userId);
    }
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      margin: EdgeInsets.only(top: 0),
      child: Column(
          children: !widget.isLoading
              ? [
                  GestureDetector(
                    onTap: () {
                      seeAllFriend(widget.userId, widget.userName, context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            title: Text(
                              'Bạn bè',
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '$totalFriend bạn bè',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF616161)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                SlideRightToLeftRoute(
                                  page: Scaffold(
                                    appBar: AppBar(
                                      title: Text(
                                        "Bạn Bè",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    body: FriendsPage(),
                                  ),
                                ),
                              ).whenComplete(() {
                                widget.callbackRefresh();
                              });
                            },
                            child: widget.isOwner == true
                                ? Text(
                                    'Tìm bạn bè',
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF01579B)),
                                  )
                                : Container(),
                          ),
                        )
                      ],
                    ),
                  ),
                  Wrap(
                    children: [for (var friend in listUserFriendsUi) friend],
                  ),
                  Container(
                    width: size.width,
                    margin: EdgeInsets.only(top: 10),
                    child: RaisedButton(
                      onPressed: () {
                        seeAllFriend(widget.userId, widget.userName, context);
                      },
                      elevation: 0.0,
                      color: Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        'Xem tất cả bạn bè',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ]
              : [
                  Wrap(
                    children: [
                      for (int i = 0; i < 6; i++)
                        Shimmer.fromColors(
                          baseColor: BaseColor,
                          highlightColor: HighlightColor,
                          child: Container(
                            width: 110,
                            padding: EdgeInsets.only(
                                top: 10, left: 10, right: 10, bottom: 0),
                            child: Container(
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: BaseColor,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                ]),
    );
  }

  Column friendInfor(Map infor, context) {
    String userName = infor['username'] == null ? 'null' : infor['username'];
    String userId = infor['user_id'].toString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 110,
          padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color(0xFFBDBDBD),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: GestureDetector(
                onTap: () {
                  seeInforFriend(userId, context);
                },
                child: infor['avatar'] == null
                    ? Image.asset(PlaceHolderAvatarUrl)
                    : Image.network(
                        Host + infor['avatar'],
                        // width: size.width,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                            // child: Image.asset('assets/lazy_loading/16_green.gif'),
                          );
                        },
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        Container(
          width: 90,
          child: FlatButton(
            onPressed: () {
              seeInforFriend(userId, context);
            },
            padding: EdgeInsets.all(0),
            child: Text(
              userName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> seeInforFriend(String userId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    ).whenComplete(() => widget.callbackRefresh());
  }

  void seeAllFriend(String userId, String userName, BuildContext context) {
    Navigator.push(
      context,
      SlideRightToLeftRoute(
        page: SeeAllFriend(
          userId: userId,
          userName: userName,
        ),
      ),
    ).whenComplete(() => widget.callbackRefresh());
  }
}
