import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/loginscreen/RegisterPaneVerify.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'RegisterEntity.dart';

class RegisterPanePassword extends StatefulWidget {
  final RegisterEntity registerEntity;

  const RegisterPanePassword({Key key, this.registerEntity}) : super(key: key);

  @override
  _RegisterPanePasswordState createState() => _RegisterPanePasswordState();
}

class _RegisterPanePasswordState extends State<RegisterPanePassword> {
  final _formKey = GlobalKey<FormState>();
  String password = "";
  String passwordVerify = "";
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        showReturnDialog();
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          title: Text(
            'Nhập mật khẩu',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          elevation: 0.4,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 25),
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: Text(
                    "Nhập mật khẩu",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      // icon: Icon(Icons.person),
                      // hintText: 'What do people call you?',
                      labelText: 'Nhập Mật khẩu',
                      labelStyle: TextStyle(color: BlackColor)),
                  onSaved: (String value) {
                    // password = value;
                    //   widget.registerEntity.password = password;
                  },
                  validator: (String value) {
                    password = value;
                    String pattern = r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{4,}$';
                    RegExp regExp = new RegExp(pattern);
                    if (value.length == 0) {
                      return 'Hãy nhập mật khẩu !';
                    } else if (value.contains(' ') || !regExp.hasMatch(value)) {
                      return 'mật khẩu gồm cả chữ, số và ít nhất 4 kí tự !';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      // icon: Icon(Icons.person),
                      // hintText: 'What do people call you?',
                      labelText: 'Xác nhận mật khẩu',
                      labelStyle: TextStyle(color: BlackColor)),
                  onSaved: (String value) {
                    passwordVerify = value;
                    widget.registerEntity.password = passwordVerify;
                  },
                  validator: (String value) {
                    String pattern = r'^(?=.*?[a-zA-Z])(?=.*?[0-9]).{4,}$';
                    RegExp regExp = new RegExp(pattern);
                    if (value.length == 0) {
                      return 'Hãy nhập mật khẩu !';
                    } else if (value.contains(' ') || !regExp.hasMatch(value)) {
                      return 'mật khẩu gồm cả chữ, số và ít nhất 4 kí tự !';
                    } else if (password != value) {
                      return 'xác nhận mật khẩu sai';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 50),
                SizedBox(
                  height: 40.0,
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        // If the form is valid, display a Snackbar.
                        print("validate ok !");
                        _formKey.currentState.save();
                        print(widget.registerEntity.toString());
                        Navigator.push(
                          context,
                          SlideRightToLeftRoute(
                            page: RegisterPaneVerify(
                              registerEntity: widget.registerEntity,
                            ),
                          ),
                        );
                      } else {
                        print("validate no valid !");
                      }
                    },
                    child: Text('Tiếp',
                        style: TextStyle(
                          color: WhiteColor,
                          fontSize: 16,
                        )),
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
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
            },
          )
        ],
      ),
    );
  }
}
