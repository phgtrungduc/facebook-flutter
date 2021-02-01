import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:facebook/components/loginscreen/loginScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  _Register createState() => _Register();
}

class _Register extends State<Register> {
  bool canSee = true;
  bool fullInfor = false;
  final phoneNumberController = new TextEditingController();
  final passwordController = new TextEditingController();
  bool isLoading = false;
  initState() {
    super.initState();
  }
  Future<List<String>> getDeviceDetails() async {
    String deviceName;
    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId;  //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor;  //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

//if (!mounted) return;
    return [deviceName, deviceVersion, identifier];
  }
  void snackBar(String text, BuildContext context) {
    var snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void signUp(BuildContext context) {
    String phonenumber = phoneNumberController.text.trim();
    String password = passwordController.text.trim();
    if (password == phonenumber) {
      snackBar("Mật khẩu phải khác số điện thoại", context);
    } else if (phonenumber.codeUnitAt(0) == 48 || phonenumber.length != 10) {
      snackBar("Số điện thoại không hợp lệ", context);
    } else if (password.length < 6 || password.length > 10) {
      snackBar("Mật khẩu không hợp lệ", context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void checkFullInfor() {
    String phonenumber = phoneNumberController.text;
    String password = passwordController.text;
    if (phonenumber.trim() != "" && password.trim() != "") {
      setState(() {
        fullInfor = true;
      });
    } else {
      setState(() {
        fullInfor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  onChanged: (val) {
                    this.checkFullInfor();
                  },
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
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                          style: TextStyle(color: BlackColor, fontSize: 20),
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
                        child:
                            Icon(Icons.remove_red_eye, color: GreyTimeAndIcon),
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
                            horizontal: size.width * 0.35, vertical: 15),
                        onPressed: fullInfor
                            ? () {
                                signUp(context2);
                              }
                            : null,
                        child: Text('Đăng kí',
                            style: TextStyle(
                                color: fullInfor ? WhiteColor : GreyFontColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600)),
                        color: BlueButtonLogin,
                      )),
                ),
              ),
            ]));
  }
}
