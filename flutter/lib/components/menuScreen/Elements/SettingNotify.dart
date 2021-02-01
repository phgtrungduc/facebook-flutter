import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingNotify extends StatefulWidget {
  @override
  _SettingNotifyState createState() => _SettingNotifyState();
}

class _SettingNotifyState extends State<SettingNotify> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: AlertDialog(
        title: new Text("Bật/tắt thông báo"),
        content: Row(
          children: [
            Expanded(child: Text('Thông báo đẩy')),
            Switch(
              activeColor: Colors.pinkAccent,
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  if (isSwitched == true)
                    isSwitched = false;
                  else
                    isSwitched = true;
                });
              },
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('THOÁT'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
