import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'RegisterPaneName.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: WhiteColor,
      scaffoldBackgroundColor: WhiteColor,
    ),
    debugShowCheckedModeBanner: false,
    home: RegisterPane1(),
  ));
}

class RegisterPane1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhiteColor,
      body: Container(
        margin: EdgeInsets.only(top: 100),
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 130.0,
                child: Image.asset("assets/images/registration.jpg"),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                "Tham gia Facebook",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Chúng tôi sẽ giúp bạn tạo tài khoản mới sau vài bước dễ dàng",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: SizedBox(
                height: 40.0,
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlideRightToLeftRoute(
                        page: RegisterPaneName(
                            // userId: id_user,
                            // isOwner: true,
                            ),
                      ),
                    );
                  },
                  child: Text('Tiếp',
                      style: TextStyle(
                        color: WhiteColor,
                        fontSize: 16,
                      )),
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
