import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/loginscreen/RegisterPanePhone.dart';
import 'RegisterEntity.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class RegisterPaneBirthday extends StatefulWidget {
  final RegisterEntity registerEntity;

  const RegisterPaneBirthday({Key key, this.registerEntity}) : super(key: key);

  @override
  _RegisterPaneBirthdayState createState() => _RegisterPaneBirthdayState();
}

class _RegisterPaneBirthdayState extends State<RegisterPaneBirthday> {
  String mess = "";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale.fromSubtags(languageCode: 'vi')],
      home: WillPopScope(
        onWillPop: () {
          showReturnDialog();
        },
        child: Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          appBar: AppBar(
            backgroundColor: Color(0xFFFFFFFF),
            title: Text(
              'Ngày sinh',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: BlackColor),
            ),
            elevation: 0.4,
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 100),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Sinh nhật của bạn là khi nào ?",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 100,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (dateTime) {
                        print(dateTime);
                        widget.registerEntity.birthday = dateTime;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "$mess",
                    style: TextStyle(fontSize: 18.0, color: LiveStreamColor),
                  ),
                  SizedBox(height: 60),
                  SizedBox(
                    height: 40.0,
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        if (widget.registerEntity.birthday.year > 2015) {
                          setState(() {
                            mess = "Ngày tháng năm không hợp lệ !";
                          });
                        } else {
                          mess = "";
                          print(widget.registerEntity.toString());
                          Navigator.push(
                            context,
                            SlideRightToLeftRoute(
                              page: RegisterPanePhone(
                                registerEntity: widget.registerEntity,
                              ),
                            ),
                          );
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
            },
          )
        ],
      ),
    );
  }
}
