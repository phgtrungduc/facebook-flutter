import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/loginscreen/RegisterPaneBirthday.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'RegisterEntity.dart';

class RegisterPaneVerify extends StatefulWidget {
  final RegisterEntity registerEntity;

  const RegisterPaneVerify({Key key, this.registerEntity}) : super(key: key);

  @override
  _RegisterPaneVerifyState createState() => _RegisterPaneVerifyState();
}

class _RegisterPaneVerifyState extends State<RegisterPaneVerify> {
  void signUp(BuildContext context, String phone, String password, String name,
      DateTime birthday) {
    API api = new API();
    try {
      showLoaderDialog(context);
      api.signUp(phone, password, name, birthday).then((res) {
        //pop loader
        Navigator.pop(context);
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          showNoticeDialog("Đăng ký thành công !");
        } else if (code == 9996) {
          showNoticeDialog("User Đã tồn tại !");
        }
      });
    } on Exception {
      showNoticeDialog('Lỗi mạng !');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        showReturnDialog();
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          title: Text(
            'Điều khoản & quyền riêng tư',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          elevation: 0.4,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 30),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hoàn tất đăng ký",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            'Bằng cách nhấn vào nút tạo tài khoản, bạn sẽ đồng ý với'),
                    TextSpan(
                        text: ' Điều khoản và chính sách',
                        style: TextStyle(color: Colors.blue)),
                    TextSpan(text: ' của chúng tôi'),
                  ],
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                height: 50.0,
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    showVerifyDialog();
                  },
                  child: Text('Đăng kí',
                      style: TextStyle(color: WhiteColor, fontSize: 16)),
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 50),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            'Thông tin liên hệ chúng tối sẽ gửi bạn qua SMS hoặc email xác nhận ...'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showReturnDialog() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Quay lại trang đăng ký ?"),
        content: new Text(
            "Nếu bạn quay lại , bạn sẽ mất toàn bộ thông tin đã làm từ trước"),
        actions: <Widget>[
          FlatButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Xác nhận về trang đăng kí'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  showVerifyDialog() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Xác nhận đăng ký ?"),
        content: new Text(
            "Chúng tôi sẽ đưa bạn về trang đăng nhập ngay sau khi bạn nhấp đăng kí"),
        actions: <Widget>[
          FlatButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Đăng kí'),
            onPressed: () {
              signUp(
                  context,
                  widget.registerEntity.phone,
                  widget.registerEntity.password,
                  widget.registerEntity.name,
                  widget.registerEntity.birthday);
            },
          )
        ],
      ),
    );
  }

  showNoticeDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Thông báo"),
        content: new Text("$message"),
        actions: <Widget>[
          FlatButton(
            child: Text('Quay về trang đăng kí gốc'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    ).whenComplete(() {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
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
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showBottomSheet(String mess) {
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
}
