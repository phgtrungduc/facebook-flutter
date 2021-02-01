import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingPushNotify extends StatefulWidget {
  @override
  _SettingPushNotifyState createState() => _SettingPushNotifyState();
}

class _SettingPushNotifyState extends State<SettingPushNotify> {
  bool isSwitched1 = true;
  bool isSwitched2 = true;
  bool isSwitched3 = true;
  bool isSwitched4 = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Đẩy",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.notifications_off, size: 30.0),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Tắt thông báo đẩy",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Tắt',
                        style:
                            TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: Colors.pinkAccent,
                  value: isSwitched1,
                  onChanged: (value) {
                    setState(() {
                      if (isSwitched1 == true)
                        isSwitched1 = false;
                      else
                        isSwitched1 = true;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.phonelink_ring, size: 30.0),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Rung",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Rung khi có thông báo đến',
                        style:
                            TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: Colors.pinkAccent,
                  value: isSwitched2,
                  onChanged: (value) {
                    setState(() {
                      if (isSwitched2 == true)
                        isSwitched2 = false;
                      else
                        isSwitched2 = true;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.flash_on, size: 30.0),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Đèn LED điện thoại",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Nháy LED khi có thông báo đến',
                        style:
                            TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: Colors.pinkAccent,
                  value: isSwitched3,
                  onChanged: (value) {
                    setState(() {
                      if (isSwitched3 == true)
                        isSwitched3 = false;
                      else
                        isSwitched3 = true;
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.volume_down, size: 30.0),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Âm thanh",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Phát âm thanh khi có thông báo đến',
                        style:
                            TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: Colors.pinkAccent,
                  value: isSwitched4,
                  onChanged: (value) {
                    setState(() {
                      if (isSwitched4 == true)
                        isSwitched4 = false;
                      else
                        isSwitched4 = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
