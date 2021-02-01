import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/loginscreen/RegisterPanePassword.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'RegisterEntity.dart';

class RegisterPanePhone extends StatefulWidget {
  final RegisterEntity registerEntity;

  const RegisterPanePhone({Key key, this.registerEntity}) : super(key: key);

  @override
  _RegisterPanePhoneState createState() => _RegisterPanePhoneState();
}

class _RegisterPanePhoneState extends State<RegisterPanePhone> {
  final _formKey = GlobalKey<FormState>();
  String phone = "";
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
            'Số điện thoại',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          elevation: 0.4,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 100),
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Nhập số điện thoại",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                        // icon: Icon(Icons.person),
                        // hintText: 'What do people call you?',
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: BlackColor)),
                    onSaved: (String value) {
                      phone = value;
                      widget.registerEntity.phone = phone;
                    },
                    validator: (String value) {
                      String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
                      RegExp regExp = new RegExp(pattern);
                      if (value.length == 0) {
                        return 'Hãy nhập số điện thoại !';
                      } else if (!regExp.hasMatch(value)) {
                        return 'Hãy nhập đúng định dạng !';
                      }
                      return null;
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
                              page: RegisterPanePassword(
                                registerEntity: this.widget.registerEntity,
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
            },
          )
        ],
      ),
    );
  }
}
