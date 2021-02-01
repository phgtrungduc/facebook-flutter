import 'dart:convert';

import 'package:facebook/model/UserInfor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';

class HeaderChat extends StatefulWidget {
  @override
  _HeaderChatState createState() => _HeaderChatState();
}

class _HeaderChatState extends State<HeaderChat> {
  TextEditingController _searchController = new TextEditingController();
  String avatar;

  void _getOwnInfor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      avatar =
          UserChatInfor.fromJson(json.decode(prefs.getString("information"))).avatar;
    });
  }
  initState(){
    super.initState();
    _getOwnInfor();
  }
  dynamic getAvatar() {
    if (this.avatar == null) {
      return AssetImage('assets/images/avatar_placeholder.png');
    } else {
      return NetworkImage(Host + this.avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundImage: this.getAvatar(),
                          radius: 25,
                        )
                      ),
                    ],
                  ),
                  Text(
                    "Chats",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.edit),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: greyChat, borderRadius: BorderRadius.circular(15)),
          child: TextField(
            cursorColor: BlackColor,
            controller: _searchController,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: BlackColor,
                ),
                hintText: "Search",
                border: InputBorder.none),
          ),
        )
      ],
    );
  }
}
