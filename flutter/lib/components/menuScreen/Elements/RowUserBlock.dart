import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/menuScreen/model/UserBlockModel.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RowUserBLock extends StatefulWidget {
  UserBlockModel userBlockModel;

  RowUserBLock({Key key, @required this.userBlockModel}) : super(key: key);

  @override
  _RowUserBLockState createState() => _RowUserBLockState();
}

class _RowUserBLockState extends State<RowUserBLock> {
  bool visibile_row = true;

  void setUnBlock(int idUser) async {
    API api = new API();
    try {
      showLoaderDialog(context);
      api.setUnBlock(idUser).then((res) {
        Navigator.pop(context);
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          setState(() {
            visibile_row = false;
          });
          Navigator.pop(context);
          showNoticeDialog("bỏ chặn thành công !");
        } else {
          showNoticeDialog("Lỗi xảy ra, vui lòng thử lại !");
        }
      });
    } on Exception {
      showBottomSheet(
          context, "Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visibile_row,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 30.0,
              backgroundImage: widget.userBlockModel.urlImage == null
                  ? AssetImage(PlaceHolderAvatarUrl)
                  : NetworkImage(Host + widget.userBlockModel.urlImage),
            ),
            SizedBox(width: 16),
            Expanded(child: Text('${widget.userBlockModel.name}')),
            RaisedButton(
              onPressed: _showMaterialDialog,
              color: Colors.white,
              child: Text("Bỏ chặn "),
            )
          ],
        ),
      ),
    );
  }

  _showMaterialDialog() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Bỏ chặn ${widget.userBlockModel.name}"),
        content: new Text(
            "Nếu bạn bỏ chặn ${widget.userBlockModel.name} , hắn có thể xem dòng thời gian và liên hệ với bạn ! "),
        actions: <Widget>[
          FlatButton(
            child: Text('Thoát'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Xác nhận'),
            onPressed: () {
              setUnBlock(widget.userBlockModel.idUser);
            },
          )
        ],
      ),
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
      // Navigator.pop(context);
      // widget.callbackRefresh();
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
            },
          )
        ],
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
}
