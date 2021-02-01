import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class NotifyDeletePopup extends StatelessWidget {
  Function callback;

  NotifyDeletePopup({Key key, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(top:17,bottom:17,left: 17,right:5),
        width: MediaQuery.of(context).size.width*0.95,
        margin: EdgeInsets.only(bottom: 10),
        // color: Color(0xFF000000),
        // height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Color(0xFF000000).withOpacity(0.95),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Đã gỡ thông báo này',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            if(callback != null) Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  // callback();
                },
                child: Text(
                  'Hoàn tác',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
