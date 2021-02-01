import 'dart:convert';

import 'package:facebook/components/homepage/homepage.dart';
import 'package:facebook/components/homepage/post/addNewPost.dart';
import 'package:facebook/components/homepage/post/feelingScreen.dart';
import 'package:facebook/components/loginscreen/loginScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api.dart';
import 'components/animationRouteClass/SlideAnimation.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    theme: ThemeData(
          primaryColor: WhiteColor,
          scaffoldBackgroundColor: WhiteColor,
        ),
        debugShowCheckedModeBanner: false
    );
  }
}

// class MyApp extends StatefulWidget {
//   MyApp({Key key}) : super(key: key);
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
//   void checkLogin(BuildContext context) async {
//     var storage = new FlutterSecureStorage();
//     var value = await storage.read(key: "accessToken");
//     if (value != null)
//       Navigator.push(context, MaterialPageRoute<void>(
//         builder: (BuildContext context) {
//           return MainScreen();
//         },
//       ));
//     else
//       Navigator.push(context, MaterialPageRoute<void>(
//         builder: (BuildContext context) {
//           return LoginScreen();
//         },
//       ));
//   }
//
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => checkLogin(context));
//   }
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: "Facebook",
//         home: Scaffold(
//           backgroundColor: BlueColor,
//           body: Center(
//             child: SingleChildScrollView(
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(vertical: 15),
//                         child: Text("Facebook",
//                             style: TextStyle(
//                                 color: WhiteColor,
//                                 fontSize: 55,
//                                 fontWeight: FontWeight.w900)),
//                       ),
//                       CircularProgressIndicator(
//                         backgroundColor: WhiteColor,
//                       ),
//                       Builder(builder: (context)=>
//                           FlatButton(
//                         child: Text("An nut"),
//                         onPressed: (){
//                           Navigator.push(
//                               context, MaterialPageRoute(builder: (context) => LoginScreen()));
//                         },
//                       ))
//                     ])),
//           ),
//         ), // truyen userId vao` mainscreen
//         theme: ThemeData(
//           primaryColor: WhiteColor,
//           scaffoldBackgroundColor: WhiteColor,
//         ),
//         debugShowCheckedModeBanner: false);
//   }
// }
