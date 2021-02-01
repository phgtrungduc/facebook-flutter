import 'dart:convert';
// import 'dart:html';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/loginscreen/loginScreen.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/search/view/baseSearch.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'Setting/SettingPane.dart';

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//         appBar: AppBar(
//           title: Text("first Route"),
//         ),
//         backgroundColor: Colors.white,
//         body: MenuScreen()),
//   ));
// }

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String name;
  String avatar;

  bool internet = true;
  bool hasData = false;
  bool isLoading = false;

  Future<void> _getPreShare() async {
    await this.hasInternet();
    if (this.internet == false) return;
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id_icre");
    API api = new API();
    api.getUserInfor(id).then((res) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      int code = json.decode(res.body)["code"];
      if (code == 1000) {
        setState(() {
          name = jsonDecode(res.body)["data"]["name"];
          avatar = jsonDecode(res.body)["data"]["avatar"];
        });
      } else {
        setState(() {
          this.hasData = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print(e);
    });
  }

  void _logOut()async {
    var storage = new FlutterSecureStorage();
    await storage.deleteAll();
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    prefs.clear();
  }

  void callbackRefresh() {
    _getPreShare();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPreShare();
  }

  @override
  Widget build(BuildContext context) {
    return this.internet
        ? ListView(
            padding: EdgeInsets.only(top: 0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlideRightToLeftRoute(
                                  page: BaseSearchPage(),
                                ),
                              );
                            },
                            color: Color(0xFFFFFFFF),
                            child: Icon(
                              Icons.search,
                            ),
                            shape: CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    FlatButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var id_user = prefs.getString("id_icre");
                          Navigator.push(
                            context,
                            SlideRightToLeftRoute(
                              page: UserWall(
                                userId: id_user,
                                isOwner: true,
                              ),
                            ),
                          );
                        },
                        child: isLoading
                            ? Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Column(
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: BaseColor,
                                        highlightColor: HighlightColor,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: BaseColor,
                                          ),
                                          title: Container(
                                            height: 20,
                                            color: BaseColor,
                                          ),
                                          subtitle: Container(
                                            height: 12,
                                            color: BaseColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])
                            : Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25.0,
                                    backgroundImage: this.avatar == null
                                        ? AssetImage(PlaceHolderAvatarUrl)
                                        : NetworkImage(Host + this.avatar),
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        this.name ?? "",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text('Xem trang cá nhân của bạn'),
                                    ],
                                  ),
                                ],
                              )),
                    Divider(
                      color: Colors.grey[600],
                      indent: 10,
                      endIndent: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 500),
              Column(
                children: [
                  Card(
                    child: ExpansionTile(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.help, size: 20.0),
                            SizedBox(width: 10.0),
                            Text(
                              'Trợ giúp và hỗ trợ',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      children: <Widget>[
                        Card(
                          child: RaisedButton(
                            elevation: 0,
                            onPressed: () {},
                            color: Colors.grey[100],
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, left: 8, right: 8, bottom: 16),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.book, size: 20.0),
                                  SizedBox(width: 10.0),
                                  Text(
                                    'Điều khoản và chính sách',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: ExpansionTile(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.settings, size: 20.0),
                            SizedBox(width: 10.0),
                            Text(
                              'Cài Đặt và Quyền riêng tư',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      children: <Widget>[
                        Card(
                          child: RaisedButton(
                            elevation: 0,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SettingPane(
                                          callbackRefresh: this.callbackRefresh,
                                        )),
                              );
                            },
                            color: Colors.grey[100],
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, left: 8, right: 8, bottom: 16),
                              child: Row(
                                children: <Widget>[
                                  //Icon(Icons.supervised_user_circle_rounded,
                                  //  size: 20.0),
                                  SizedBox(width: 10.0),
                                  Text(
                                    'Cài đặt',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: RaisedButton(
                      elevation: 0,
                      onPressed: () async {
                        _logOut();
                        Navigator.pushReplacement(
                          context,
                          SlideRightToLeftRoute(
                            page: LoginScreen(),
                          ),
                        );
                      },
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16, left: 8, right: 8, bottom: 16),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.local_dining, size: 20.0),
                            SizedBox(width: 10.0),
                            Text(
                              'Đăng xuất',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : NoDataScreen(
            title: 'Không có kết nối mạng',
            emitParent: this._getPreShare(),
          );
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
}
