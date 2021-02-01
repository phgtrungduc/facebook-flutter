import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/profileSearch.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/editPublicDetail/publicDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class UserSetting extends StatefulWidget {
  final String userId;
  String userName;
  bool isOwner = false;

  UserSetting({Key key, this.userId, this.userName, this.isOwner})
      : super(key: key);

  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  int codeCheckBlock = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    String name = widget.userName;
    String idUser = widget.userId;
    if (widget.isOwner != null && widget.isOwner == true) {
      name = "bạn";
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.9,
        title: Text(
          'Cài đặt trang cá nhân',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Container(
        color: Color(0xFFFFFFFF),
        child: Column(
          children: [
            Divider(
              height: 12,
              thickness: 12,
            ),
            widget.isOwner == true
                ? buttonOption(() {
                    Navigator.push(
                      context,
                      SlideRightToLeftRoute(
                        page: PublicDetail(
                          userId: widget.userId,
                        ),
                      ),
                    );
                  }, icon: Icons.edit, title: 'Chỉnh sửa trang cá nhân')
                : buttonOption(
                    () {
                      _showBlockDialog(name, int.parse(idUser));
                    },
                    icon: FontAwesomeIcons.userLock,
                    title: 'Chặn',
                  ),
            Divider(
              height: 1,
              thickness: 2,
            ),
            buttonOption(
              () {
                Navigator.push(
                  context,
                  SlideRightToLeftRoute(
                    page: ProfileSearch(
                      userId: widget.userId,
                      userName: widget.userName,
                    ),
                  ),
                );
              },
              icon: FontAwesomeIcons.search,
              title: 'Tìm kiếm trên trang cá nhân của $name',
            ),
            Divider(
              height: 12,
              thickness: 12,
            ),
            ListTile(
              title: Text(
                'Liên kết đến trang cá nhân của $name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Liên kết của riêng $name trên facebook'),
            ),
            Divider(
              height: 7,
              thickness: 0,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 13.0),
                child: InkWell(
                  child: Text(
                    "https://www.facebook.com/${widget.userName}",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () async {
                    // if (await canLaunch("https://www.facebook.com/user.infor")) {
                    //   await launch("https://www.facebook.com/user.infor");
                    // }
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 13.0, top: 11, bottom: 11),
                  child: RaisedButton(
                    color: Color(0xFFFFFFFF),
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        side: BorderSide()),
                    padding: EdgeInsets.all(10),
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(
                          text: "https://www.facebook.com/${widget.userName}"));
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'sao chép liên kết',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlatButton buttonOption(callbackFunction, {icon, title}) {
    return FlatButton(
      onPressed: callbackFunction,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 25.0,
              color: Color(0xFF000000),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Text(
                '$title',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setBlockFriend(int idUser) async {
    showLoaderDialog(context);
    API api = new API();
    try {
      await api.setBlock(idUser).then((res) {
        int code = json.decode(res.body)["code"];
        Navigator.pop(context);
        if (code == 1000) {
          codeCheckBlock = code;
          Navigator.of(context).pop();
          //back to
          Navigator.pop(context);
        } else {
          print(code.toString() + "lỗi không xác định");
          showBottomSheet2(context);
        }
      });
    } on Exception {
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  void showBottomSheet2(BuildContext context) {
    showModalBottomSheet(
      context: _scaffoldKey.currentContext,
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
      Navigator.of(context).pop();
      Navigator.pop(context);
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
      context: _scaffoldKey.currentContext,
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
              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  this.setBlockFriend(idUser);
                });
              }
            },
          )
        ],
      ),
    );
  }
}
