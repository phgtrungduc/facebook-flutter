import 'dart:convert';
import 'package:facebook/components/loginscreen/RegisterPane1.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/mainScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:facebook/api/api.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool canSee = true;
  bool fullInfo = false;
  final phoneNumberController = new TextEditingController();
  final passwordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  initState() {
    super.initState();
  }

  void checkFullInfor() {
    String phonenumber = phoneNumberController.text;
    String password = passwordController.text;
    if (phonenumber.trim() != "" && password.trim() != "") {
      setState(() {
        fullInfo = true;
      });
    } else {
      setState(() {
        fullInfo = false;
      });
    }
  }

  void showError(String error) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Đã xảy ra lỗi'),
                subtitle: Text(error),
              ),
            ],
          ),
        );
      },
    );
  }

  void snackBar(String text, BuildContext context) {
    var snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  bool hasKeyBoard() {
    return (MediaQuery.of(context).viewInsets.bottom == 0);
  }

  _savePreShare(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  _deletePreShare(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  void logIn(BuildContext context2, String phone, String password) {
    setState(() {
      isLoading = true;
    });
    API api = new API();
    try {
      api.logIn(phone, password).then((res) {
        print("thanhcong");
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          var storage = new FlutterSecureStorage();
          storage.write(
              key: "acessToken", value: json.decode(res.body)["accessToken"]);
          _savePreShare(
              "id_icre", json.decode(res.body)["data"]["id"].toString());
          _savePreShare("password", password);
          _savePreShare("phone", phone);
          _savePreShare("id_user", json.decode(res.body)["data"]["_id"]);
          _savePreShare("name", json.decode(res.body)["data"]["name"]);
          _savePreShare(
              "information", json.encode(json.decode(res.body)["data"]));
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
        } else if (code == 999) {
          setState(() {
            isLoading = false;
          });
          showError(
              "Số điện thoại không tồn tại trên hệ thống hoặc không hợp lệ");
          print("Số điện thoại không tồn tại trên hệ thống hoặc không hợp lệ");
        } else if (code == 1011) {
          setState(() {
            isLoading = false;
          });
          print("Mật khẩu không hợp lệ");
          showError("Mật khẩu không hợp lệ");
        } else if (code == 1012) {
          setState(() {
            isLoading = false;
          });
          print(
              "Tài khoản của bạn đã bị chặn khỏi hệ thống do vi phạm quy định");
          showError(
              "Tài khoản của bạn đã bị chặn khỏi hệ thống do vi phạm quy định");
        } else {
          setState(() {
            isLoading = false;
          });
          showError("lỗi không xác định");
        }
      });
    } on Exception {
      showError("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: BlueColor,
        body: Center(
          child: isLoading
              ? CircularProgressIndicator(
                  backgroundColor: WhiteColor,
                )
              : SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Text("Facebook",
                              style: TextStyle(
                                  color: WhiteColor,
                                  fontSize: 55,
                                  fontWeight: FontWeight.w900)),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10, top: 50),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            onChanged: (val) {
                              this.checkFullInfor();
                            },
                            keyboardType: TextInputType.number,
                            controller: phoneNumberController,
                            style: TextStyle(color: BlackColor, fontSize: 20),
                            decoration: InputDecoration(
                                hintText: "Số điện thoại",
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            width: size.width * 0.9,
                            decoration: BoxDecoration(
                              color: WhiteColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    onChanged: (val) {
                                      this.checkFullInfor();
                                    },
                                    controller: passwordController,
                                    obscureText: canSee,
                                    style: TextStyle(
                                        color: BlackColor, fontSize: 20),
                                    decoration: InputDecoration(
                                        hintText: "Mật khẩu",
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none),
                                  ),
                                ),
                                GestureDetector(
                                  onTapDown: (TapDownDetails details) {
                                    setState(() {
                                      canSee = !canSee;
                                    });
                                  },
                                  onTapUp: (TapUpDetails details) {
                                    setState(() {
                                      canSee = !canSee;
                                    });
                                  },
                                  child: Icon(Icons.remove_red_eye,
                                      color: GreyTimeAndIcon),
                                )
                              ],
                            )),
                        Builder(
                          //builder to show snackbar
                          builder: (context2) => Container(
                            margin: EdgeInsets.only(top: 20),
                            alignment: Alignment.center,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: RaisedButton(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.3,
                                      vertical: 15),
                                  onPressed: fullInfo
                                      ? () {
                                          String phone =
                                              phoneNumberController.text;
                                          String password =
                                              passwordController.text;
                                          this.logIn(context2, phone, password);
                                        }
                                      : null,
                                  child: Text('Đăng nhập',
                                      style: TextStyle(
                                          color: fullInfo
                                              ? WhiteColor
                                              : GreyFontColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600)),
                                  color: BlueButtonLogin,
                                )),
                          ),
                        ),
                        hasKeyBoard()
                            ? Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Text(
                                        "Chưa có tài khoản?",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: RaisedButton(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width * 0.2,
                                                vertical: 15),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RegisterPane1()),
                                              );
                                            },
                                            child: Text('Tạo tài khoản mới',
                                                style: TextStyle(
                                                    color: WhiteColor,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            color: GreenButtonLogin,
                                          )),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox.shrink()
                      ]),
                ),
        ));
  }
}
