import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'EditAddressPane2.dart';

class EditAddressPane1 extends StatefulWidget {
  final String userId;
  String city;
  Function callbackRefresh;

  EditAddressPane1({Key key, this.userId, this.city, this.callbackRefresh})
      : super(key: key);
  @override
  _EditAddressPane1State createState() => _EditAddressPane1State();
}

class _EditAddressPane1State extends State<EditAddressPane1> {
  String _selection;

  void editAddress(String address) {
    API api = new API();
    try {
      showLoaderDialog(context);
      api.editAddress(address).then((res) {
        Navigator.pop(context);
        if (res != null) {
          int code = json.decode(res.body)["code"];
          if (code == 1000) {
            print(
                code.toString() + json.decode(res.body)["message"].toString());
            showBottomSheet(context, "Sửa thành công !");
          } else {
            print(
                code.toString() + json.decode(res.body)["message"].toString());
            showBottomSheet(context, "Sửa thất bại !");
          }
        } else {
          showBottomSheet(context, "Lỗi mạng !");
        }
      });
    } on Exception {
      Navigator.pop(context);
      showBottomSheet(
          context, "Kết nối mạng không ổn định hoặc server không phản hồi");
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa địa chỉ',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 0.4,
      ),
      backgroundColor: WhiteColor,
      body: Container(
        //margin: EdgeInsets.only(top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RaisedButton(
              color: Colors.white,
              onPressed: () {
                // Navigator.push(
                //   context,
                //   SlideRightToLeftRoute(
                //     page: EditAddressPane2(
                //         //   userId: widget.userId,
                //         //   city: userInfor['city'],
                //         ),
                //   ),
                // );
                _buttonTapped();
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_city),
                    SizedBox(width: 10),
                    widget.city == null
                        ? Text(
                            "Chọn địa chỉ (thành phố)",
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        : _selection == null
                            ? Text(
                                widget.city,
                                style: TextStyle(
                                  color: BlackColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                _selection,
                                style: TextStyle(
                                  color: BlackColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40.0,
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  if (widget.city != null && _selection == null) {
                    editAddress(widget.city);
                  } else if (widget.city == null && _selection != null) {
                    editAddress(_selection);
                  } else if (widget.city != null && _selection != null) {
                    editAddress(_selection);
                  } else {
                    showBottomSheet(context, "Mời chọn địa chỉ !");
                  }
                },
                child: Text('Lưu',
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
    );
  }

  Future _buttonTapped() async {
    var results =
        await Navigator.of(context).push(new MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return new EditAddressPane2();
      },
    ));

    if (results != null && results.containsKey('selection')) {
      setState(() {
        _selection = results['selection'];
        widget.city = _selection;
      });
    }
  }

  void showBottomSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Thông báo'),
                subtitle: Text('$message'),
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
}
