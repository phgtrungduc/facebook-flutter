import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/loginscreen/RegisterPaneBirthday.dart';
import 'RegisterEntity.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterPaneName extends StatefulWidget {
  @override
  _RegisterPaneNameState createState() => _RegisterPaneNameState();
}

class _RegisterPaneNameState extends State<RegisterPaneName> {
  final _formKey = GlobalKey<FormState>();

  String firstName = "";

  String lastName = "";

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
            'Tên',
            style: TextStyle(fontSize: 16),
          ),
          elevation: 0.4,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 60),
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Bạn tên gì ?",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Họ',
                            labelStyle: TextStyle(color: BlackColor)),
                        onSaved: (String value) {
                          firstName = value.trim();
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Hãy nhập họ';
                          } else if (value.contains(" ")) {
                            return 'Họ chưa hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Tên',
                            labelStyle: TextStyle(color: BlackColor)),
                        onSaved: (String value) {
                          lastName = value.trim();
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Hãy nhập tên';
                          } else if (value.contains(" ")) {
                            return 'Tên chưa hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                SizedBox(
                  height: 40.0,
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        // If the form is valid, display a Snackbar.
                        _formKey.currentState.save();
                        RegisterEntity entity = new RegisterEntity(
                            firstName + " " + lastName,
                            DateTime.now(),
                            null,
                            null);
                        Navigator.push(
                          context,
                          SlideRightToLeftRoute(
                            page: RegisterPaneBirthday(
                              registerEntity: entity,
                            ),
                          ),
                        );
                      } else {
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
            },
          )
        ],
      ),
    );
  }
}
