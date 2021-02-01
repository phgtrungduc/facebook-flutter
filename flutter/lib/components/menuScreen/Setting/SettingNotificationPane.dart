import 'package:facebook/components/menuScreen/elements/RowSettingNotification.dart';
import 'package:flutter/material.dart';

class SettingNotificationPane extends StatefulWidget {
  @override
  _SettingNotificationPaneState createState() =>
      _SettingNotificationPaneState();
}

class _SettingNotificationPaneState extends State<SettingNotificationPane> {
  bool selected = false;
  List<String> titleList = [
    'Bình luận',
    'Cập nhật từ bạn bè',
    'Lời mời kết bạn',
    'Những người bạn có thể biết',
    'Sinh nhật',
    'Video',
    'Phản hồi về báo cáo bài viết',
  ];
  List<IconData> iconList = [
    Icons.comment_bank_outlined,
    Icons.group_outlined,
    Icons.person_add,
    Icons.supervised_user_circle_outlined,
    Icons.cake_outlined,
    Icons.video_label,
    Icons.report,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cài đặt thông báo",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Bạn Nhận thông báo về",
              style: TextStyle(
                  height: 2,
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: <Widget>[
              for (int i = 0; i < titleList.length; i++)
                RowSettingNotification(
                  title: titleList[i],
                  iconData: iconList[i],
                )
            ],
          ),
          Divider(
            height: 20,
            color: Colors.grey[500],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Bạn Nhận thông báo Qua",
              style: TextStyle(
                  height: 2,
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          RowSettingNotification(
            title: "Thông báo đẩy",
            iconData: Icons.notification_important,
          )
        ],
      ),
    );
  }
}
