import 'dart:convert';

import 'package:facebook/activation/Sheet/bottom/bottomSheet.dart';
import 'package:facebook/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class OneNotify extends StatefulWidget {
  final String avatarUrl;
  final String messNotify;
  final String timeNotify;
  bool seen;
  final int notifyId;
  final int index;
  Function route;
  Function callback;

  OneNotify({
    Key key,
    @required this.avatarUrl,
    @required this.messNotify,
    this.timeNotify,
    this.seen,
    this.notifyId,
    this.route,
    this.index,
    this.callback,
  }) : super(key: key);
  @override
  _OneNotifyState createState() => _OneNotifyState();
}

class _OneNotifyState extends State<OneNotify> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  seenNotify(int notifyId, bool seen) async {
    try {
      await API().seenNotify(notifyId, seen).then((res) {
        print(res.body);
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          if (mounted) {
            setState(() {
              widget.seen = seen;
            });
          }
        } else if (code == 9999) {
          print("Có lỗi xảy ra, vui lòng thử lại sau.");
        } else {
          print("Lỗi không xác định.");
        }
      });
    } on Exception {
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      color: Color(0xFFFFFFFF),
      child: FlatButton(
        onPressed: () {
          this.seenNotify(widget.notifyId, true);
          if (mounted) {
            setState(() {
              widget.seen = true;
            });
          }
          widget.route();
        },
        color: widget.seen == true ? Color(0xFFFFFFFF) : Color(0xFFE1F5FE),
        child: Row(
          children: [
            Container(
              width: 63,
              child: CircleAvatar(
                backgroundColor: Color(0xFF9E9E9E),
                radius: 50,
                backgroundImage: NetworkImage(widget.avatarUrl),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Wrap(
                  children: [
                    Text(
                      widget.messNotify,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 7),
                      child: Text(
                        widget.timeNotify,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              child: Icon(
                Icons.more_horiz,
                size: 27,
              ),
              // onTap: widget.callback(
              //   widget.avatarUrl,
              //   widget.messNotify,
              //   widget.notifyId
              // ),
              onTap: () {
                showSlideBottomSheet(context, listOptions: [
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 63,
                            child: CircleAvatar(
                              backgroundColor: Color(0xFF9E9E9E),
                              radius: 50,
                              backgroundImage: NetworkImage(widget.avatarUrl),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 11.0, left: 19, right: 19),
                          child: Text(
                            widget.messNotify,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  singleOption(
                    'Gỡ thông báo này',
                    iconOption: FontAwesomeIcons.timesCircle,
                    callbackFunction: () {
                      Navigator.pop(context);
                      widget.callback(widget.index, widget.notifyId);
                    },
                  ),
                  if (widget.seen == true)
                    singleOption(
                      'Đánh dấu là chưa đọc',
                      iconOption: FontAwesomeIcons.timesCircle,
                      callbackFunction: () {
                        Navigator.pop(context);
                        this.seenNotify(widget.notifyId, false);
                        setState(() {
                          widget.seen = false;
                        });
                      },
                    ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
