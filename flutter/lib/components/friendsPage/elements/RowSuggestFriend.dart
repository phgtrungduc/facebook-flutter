import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/friendsPage/elements/UserFriendModel.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RowSuggestFriend extends StatefulWidget {
  UserFriendModel userFriendModel;

  RowSuggestFriend({Key key, @required this.userFriendModel}) : super(key: key);

  @override
  _RowSuggestFriendState createState() => _RowSuggestFriendState();
}

class _RowSuggestFriendState extends State<RowSuggestFriend> {
  String message = "";

  bool visibleRowButton = true;
  bool visibile_cancel = false;

  bool visibile_message = false;
  bool visibile_row = true;

// ignore: missing_return
  void setRequestFriend(int idUser, int isAccept) {
    API api = new API();
    try {
      showLoaderDialog(context);

      api.setRequestFriend(idUser.toString()).then((res) {
        Navigator.pop(context);
        int code = json.decode(res.body)["code"];
        if (res != null) {
          if (code == 1000) {
            setState(() {
              message = "Đã gửi lời yêu cầu";
              //hiện mess
              visibile_message = true;
              // ẩn hàng button
              visibleRowButton = false;
              // hiện button cancel
              visibile_cancel = true;
            });

          } else {
            showBottomSheet(context, "Lỗi mạng !");

          }
        } else {
          showBottomSheet(context, "Lỗi mạng !");
        }
      });
    } on Exception {
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
      showBottomSheet(
          context, "Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  void delRequestFriend(int idUser) {
    API api = new API();
    try {
      showLoaderDialog(context);
      api.delRequestFriend(idUser.toString()).then((res) {
        Navigator.pop(context);
        if (res != null) {
          int code = json.decode(res.body)["code"];
          if (code == 1000) {
            setState(() {
              visibile_cancel = false;
              visibleRowButton = true;
              message = "";
            });

          } else {

          }
        } else {
          showBottomSheet(context, "Lỗi mạng !");
        }
      });
    } on Exception {
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
      showBottomSheet(
          context, "Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
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
                    widget.userFriendModel.name,
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
                              this.setRequestFriend(
                                  widget.userFriendModel.idUser, 1);
                            },
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                            child: Text("Thêm bạn"),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            onPressed: () {
                              setState(() {
                                visibile_row = false;
                              });
                            },
                            color: Colors.grey[300],
                            child: Text("Gỡ"),
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
                  ),
                  Visibility(
                    visible: visibile_cancel,
                    child: SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          //showLoaderDialog2(context);
                          this.delRequestFriend(widget.userFriendModel.idUser);

                          // setState(() {
                          //   visibile_cancel = false;
                          //   visibleRowButton = true;
                          //   message = "";
                          // });
                        },
                        color: Colors.grey[300],
                        child: Text("Hủy"),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context, String mess) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Thông báo'),
                subtitle: Text('$mess'),
              ),
            ],
          ),
        );
      },
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
}
