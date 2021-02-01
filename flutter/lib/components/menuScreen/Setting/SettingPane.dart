import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BlockUserPane.dart';
import 'ChangeNamePane.dart';
import 'ChangePasswordPane.dart';
import 'SettingNotificationPane.dart';

class SettingPane extends StatefulWidget {
  Function callbackRefresh;
  SettingPane({Key key, @required this.callbackRefresh});
  @override
  _SettingPane createState() => _SettingPane();
}

class _SettingPane extends State<SettingPane> {
  var name;

  bool internet = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getNameFromSharePref();
  }

  _getNameFromSharePref() async {
    await this.hasInternet();
    if (this.internet == false) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        name = prefs.getString("name");
      });
    }
  }

  void callbackRefresh() {
    _getNameFromSharePref();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.callbackRefresh();
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Cài đặt",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        backgroundColor: Colors.white,
        body: this.internet
            ? ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cài đặt tài khoản",
                          style: TextStyle(
                            height: 2,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Quản lý thông tin về bạn,các tài khoản thanh toán và danh bạ của bạn cũng như tài khoản nói chung",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Card(
                          child: ExpansionTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.person, size: 20.0),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Thông tin cá nhân',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'Đổi tên,sdt hoặc email',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
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
                                      SlideRightToLeftRoute(
                                          page: ChangeNamePane(
                                        userName: name.toString(),
                                        callbackRefresh: this.callbackRefresh,
                                      )),
                                    );
                                  },
                                  color: Colors.grey[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tên',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                            Text(
                                              name.toString(),
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(Icons.arrow_right, size: 20.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bảo mật và đăng nhập",
                          style: TextStyle(
                            height: 2,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Đổi mật khẩu và thực hiện các hành động khác để tăng cường bảo mật cho tài khoản",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Card(
                          child: RaisedButton(
                            elevation: 0,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangePasswordPane()),
                              );
                            },
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  //Icon(Icons.shield, size: 20.0),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Đổi mật khẩu',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'Nhấn vào đây để đổi mật khẩu',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quyền riêng tư",
                          style: TextStyle(
                            height: 2,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Kiểm soát người nhìn thấy hoạt động của bạn và cách chúng tôi dùng dữ liệu cá nhân hóa trải nghiệm.",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Card(
                          child: RaisedButton(
                            elevation: 0,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BlockUserPane()),
                              );
                            },
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.block, size: 20.0),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chặn',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'Xem những người bị bạn chặn ',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thông báo",
                          style: TextStyle(
                            height: 2,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Quyết định cách bạn giao tiếp với hệ thống",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Card(
                          child: RaisedButton(
                            elevation: 0,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SettingNotificationPane()),
                              );
                            },
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.notifications, size: 20.0),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cài đặt thông báo',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'Chọn thông báo muốn nhận',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : NoDataScreen(
                title: 'Không có kết nối mạng',
                emitParent: this._getNameFromSharePref(),
              ),
      ),
    );
  }
}
