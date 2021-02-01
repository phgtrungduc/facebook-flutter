import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SettingNotify.dart';
import 'SettingPushNotify.dart';

class RowSettingNotification extends StatefulWidget {
  final String title;
  final IconData iconData;

  RowSettingNotification({Key key, this.title, this.iconData})
      : super(key: key);

  @override
  _RowSettingNotificationState createState() => _RowSettingNotificationState();
}

class _RowSettingNotificationState extends State<RowSettingNotification> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.title != "Thông báo đẩy")
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingNotify()),
          );
        else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingPushNotify()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Icon(widget.iconData, size: 30.0),
            SizedBox(
              width: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Bật/tắt thông báo',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
