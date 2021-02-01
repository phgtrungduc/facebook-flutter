import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/friendsPage/elements/UserFriendModel.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RowUserFriend extends StatefulWidget {
  UserFriendModel userFriendModel;

  RowUserFriend({Key key, @required this.userFriendModel}) : super(key: key);

  @override
  _RowUserFriendState createState() => _RowUserFriendState();
}

class _RowUserFriendState extends State<RowUserFriend> {
  String message = "";

  bool visibleRowButton = true;

  bool visibile_more_horiz_button = false;

  bool visibile_message = false;

  bool visibile_row = true;

  // ignore: missing_return
  void setAcceptFriend(int idUser, int isAccept) {
    API api = new API();
    try {
      showLoaderDialog(context);
      api.setAcceptFriend(idUser, isAccept).then((res) async {
        Navigator.pop(context);
        if (res != null) {
          int code = json.decode(res.body)["code"];
          // codeCheckAccept = code;
          if (code == 1000) {
            if (isAccept == 1) {
              setState(() {
                {
                  message = "Đã chấp nhập lời mời kết bạn";
                  visibile_message = true;
                  visibleRowButton = false;
                }
              });
            } else {
              setState(() {
                message = "Đã xóa lời mời kết bạn";
                visibile_message = true;
                visibleRowButton = false;
                visibile_more_horiz_button = true;
              });
            }
            print(json.decode(res.body)["message"]);
          } else {
            showBottomSheet2(context);
          }
        } else {
          showBottomSheet2(context);
        }
      });
    } on Exception {
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  void setBlockFriend(int idUser) {
    API api = new API();
    try {
      api.setBlock(idUser).then((res) {
        int code = json.decode(res.body)["code"];
        if (res != null) {
          if (code == 1000) {
            setState(() {
              Navigator.pop(context);
              Navigator.pop(context);
            });
            print(json.decode(res.body)["message"]);
          } else {
            Navigator.pop(context);
            showBottomSheet2(context);
          }
        }
      });
    } on Exception {
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        seeInforFriend(widget.userFriendModel.idUser.toString(), context);
      },
      child: Visibility(
        visible: visibile_row,
        child: Container(
          margin: EdgeInsets.only(top: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 45.0,
                    backgroundImage: widget.userFriendModel.urlImage == null
                        ? AssetImage(PlaceHolderAvatarUrl)
                        : NetworkImage(Host + widget.userFriendModel.urlImage),
                  ),
                ),
              ),
              Flexible(
                flex: 7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userFriendModel.name.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${widget.userFriendModel.commonFriend} bạn chung ',
                      style: TextStyle(fontSize: 14),
                    ),
                    Visibility(
                      visible: visibleRowButton,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              onPressed: () {
                                this.setAcceptFriend(
                                    widget.userFriendModel.idUser, 1);
                                // setState(() {
                                //   if (codeCheckAccept == 1000) {
                                //     message = "Đã chấp nhập lời mời kết bạn";
                                //     visibile_message = true;
                                //     visibleRowButton = false;
                                //   } else {
                                //     showBottomSheet2(context);
                                //   }
                                // });
                              },
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              child: Text("Chấp nhận"),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              onPressed: () {
                                this.setAcceptFriend(
                                    widget.userFriendModel.idUser, 0);
                                // setState(() {
                                //   if (codeCheckAccept == 1000) {
                                //     Navigator.pop(context);
                                // message = "Đã xóa lời mời kết bạn";
                                // visibile_message = true;
                                // visibleRowButton = false;
                                // visibile_more_horiz_button = true;
                                //   } else {
                                //     Navigator.pop(context);
                                //     showBottomSheet2(context);
                                //   }
                                // });
                              },
                              color: Colors.grey[300],
                              child: Text("Xóa"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: visibile_message,
                      child: Text(
                        "$message",
                      ),
                    )
                  ],
                ),
              ),
              // 2 khối này phải đi liền nhau , do mở rộng để cho icon ra rìa row !
              Visibility(
                visible: visibile_more_horiz_button,
                child: Expanded(
                  child: Text(""),
                ),
              ),
              Visibility(
                visible: visibile_more_horiz_button,
                child: Container(
                    child: IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: () {
                    showBottomSheet(context, widget.userFriendModel.name,
                        widget.userFriendModel.idUser);
                  },
                )),
              )
              //end 2 khối
            ],
          ),
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context, String name, int idUser) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Chặn ${name}'),
                subtitle:
                    Text('Bạn sẽ không thể theo dõi ${name} trên facebook '),
                onTap: () {
                  // setState(() {
                  //   visibile_row = false;
                  // });
                  Navigator.pop(bc);
                  _showBlockDialog(name, idUser);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showBottomSheet2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Thông báo'),
                subtitle: Text('Lỗi mạng !'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        print('Hey there, I\'m calling after hide bottomSheet');
        visibile_row = true;
      });
    });
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

  _showBlockDialog(String name, int idUser) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Chặn ${name}"),
        content: new Text(
            "Nếu bạn chặn ${name} , Hắn không thể xem dòng thời gian và liên hệ với bạn ! "),
        actions: <Widget>[
          FlatButton(
            child: Text('THOÁT'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Xác nhận'),
            onPressed: () {
              setState(() {
                visibile_row = false;
                showLoaderDialog(context);
                this.setBlockFriend(idUser);
                // Future.delayed(Duration(milliseconds: 1050), () {
                //   print(" This line is execute after 1 seconds");
                //   if (codeCheckBlock == 1000) {
                //     Navigator.pop(context);
                //     Navigator.of(context).pop();
                //   } else {
                //     Navigator.pop(context);
                //     Navigator.of(context).pop();
                //     showBottomSheet2(context);
                //   }
                // });
              });
            },
          )
        ],
      ),
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
    );
  }
}
