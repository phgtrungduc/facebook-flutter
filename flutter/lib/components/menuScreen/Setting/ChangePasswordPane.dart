import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:flutter/material.dart';

class ChangePasswordPane extends StatefulWidget {
  @override
  _ChangePasswordPaneState createState() => _ChangePasswordPaneState();
}

class _ChangePasswordPaneState extends State<ChangePasswordPane> {
  TextEditingController _controllerPassOld = TextEditingController();

  TextEditingController _controllerPassNew = TextEditingController();

  TextEditingController _controllerPassVerify = TextEditingController();

  bool internet = true;

  @override
  void initState() {
    super.initState();
    this.hasInternet();
  }

  Future<void> changePassword(
      String oldPass, String newPass, String verifyPass) async {
    if (this.internet == false) return;
    if (_checkPassBeforeSubmmit(oldPass, newPass, verifyPass)) {
      API api = new API();
      try {
        showLoaderDialog(context);
        api.changePassword(oldPass, newPass).then((res) {
          Navigator.pop(context);
          if (res != null) {
            int code = json.decode(res.body)["code"];
            if (code == 1000) {
              showBottomSheet(context, "Sửa thành công !");
            } else {
              showNoticeDialog("Sai mật khẩu cũ!");
            }
          } else {
            showBottomSheet(context, "Lỗi mạng, vui lòng thử lại !");
          }
        });
      } on Exception {
        Navigator.pop(context);
        showBottomSheet(
            context, "Kết nối mạng không ổn định hoặc server không phản hồi");
        // print("Kết nối mạng không ổn định hoặc server không phản hồi");
      }
    }
  }

  bool _checkPassBeforeSubmmit(
      String oldPass, String newPass, String verifyPass) {
    if (oldPass == newPass) {
      showNoticeDialog("Mật khẩu cũ y hệt mật khẩu mới !");
      return false;
    } else if (verifyPass != newPass) {
      showNoticeDialog("Xác nhận mật khẩu không khớp !");
      return false;
    } else if (verifyPass == newPass && !_validatorNewPass(verifyPass)) {
      showNoticeDialog(
          'mật khẩu gồm cả chữ, số và ít nhất 4 kí tự, không khoảng trắng !');
      return false;
    } else {
      return true;
    }
  }

  bool _validatorNewPass(String value) {
    String pattern = r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{4,}$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return false;
    } else if (value.contains(' ') || !regExp.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> hasInternet() async {
    print('checking internet ...');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mật khẩu",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: this.internet
          ? ListView(
              children: [
                Card(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mật khẩu cũ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                        TextField(
                          obscureText: true,
                          controller: _controllerPassOld,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Mật khẩu mới",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                        TextField(
                          obscureText: true,
                          controller: _controllerPassNew,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Xác nhận mật khẩu",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                        TextField(
                          controller: _controllerPassVerify,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]),
                            ),
                          ),
                        ),
                        SizedBox(height: 64),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              changePassword(
                                  _controllerPassOld.text,
                                  _controllerPassNew.text,
                                  _controllerPassVerify.text);
                            },
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, left: 8, right: 8, bottom: 16),
                              child: Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, left: 8, right: 8, bottom: 16),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : NoDataScreen(
              title: 'Không có kết nối mạng',
              emitParent: this.hasInternet(),
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

  void showBottomSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.info_rounded),
                title: Text('$message'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      Navigator.pop(context);
    });
  }

  showNoticeDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Thông báo"),
        content: new Text("$message"),
        actions: <Widget>[
          FlatButton(
            child: Text('Xác nhận'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
