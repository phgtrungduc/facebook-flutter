import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeNamePane extends StatefulWidget {
  final String userName;
  Function callbackRefresh;

  ChangeNamePane({Key key, @required this.userName, this.callbackRefresh});

  @override
  _ChangeNamePaneState createState() => _ChangeNamePaneState();
}

class _ChangeNamePaneState extends State<ChangeNamePane> {
  var id_user;
  bool internet = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getIdUserFromSharePref();
  }

  _getIdUserFromSharePref() async {
    await this.hasInternet();
    if (this.internet == false) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id_user = prefs.getString("id_icre");
    });
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

  void editName(String name) {
    API api = new API();
    try {
      showLoaderDialog(context);
      api.editName(name).then((res) {
        Navigator.pop(context);
        if (res != null) {
          int code = json.decode(res.body)["code"];
          if (code == 1000) {
            print(
                code.toString() + json.decode(res.body)["message"].toString());
            showBottomSheet(context, "Sửa thành công !");
            _savePreShare("name", name);
          } else {
            print(
                code.toString() + json.decode(res.body)["message"].toString());
            showBottomSheet(context, "Sửa thất bại !");
          }
        } else {
          showBottomSheet(context, "Lỗi mạng, vui lòng thử lại !");
        }
      });
    } on Exception {
      Navigator.pop(context);
      showBottomSheet(
          context, "Kết nối mạng không ổn định hoặc server không phản hồi");
      // print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  _savePreShare(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controllerText =
        TextEditingController(text: widget.userName);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tên",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: this.internet
          ? ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Họ và Tên",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        ),
                        TextField(
                          controller: _controllerText,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[500]),
                              ),
                              hintText: 'Enter a search term'),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              if (_controllerText.text != widget.userName)
                                editName(_controllerText.text);
                              else
                                showBottomSheet(
                                    context, "Tên không đổi, hãy chọn tên !");
                            },
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, left: 8, right: 8, bottom: 16),
                              child: Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, left: 8, right: 8, bottom: 16),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : NoDataScreen(
              title: 'Không có kết nối mạng',
              emitParent: this.hasInternet(),
            ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Đang tải...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showBottomSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.info_rounded),
                title: Text('$message'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      Navigator.pop(context);
      widget.callbackRefresh();
    });
  }

  showNoticeDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Thông báo"),
        content: new Text("$message"),
        actions: <Widget>[
          FlatButton(
            child: Text('Xác nhận'),
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
