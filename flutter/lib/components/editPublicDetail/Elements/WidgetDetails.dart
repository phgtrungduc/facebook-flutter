import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget details(String city, String address) {
  return Column(
    children: <Widget>[
      Row(
        children: [
          Icon(Icons.location_city),
          SizedBox(width: 10),
          address == null
              ? Text(
                  "Tỉnh/Thành Phố hiện tại",
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : Text(
                  "$address",
                  style: TextStyle(
                    color: BlackColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                )
        ],
      ),
      SizedBox(height: 10),
      Row(
        children: [
          Icon(Icons.work),
          SizedBox(width: 10),
          city == null
              ? Text(
                  "Nơi làm việc",
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : Text(
                  "$city",
                  style: TextStyle(
                    color: BlackColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                )
        ],
      ),
      SizedBox(height: 10),
      // Row(
      //   children: [
      //     Icon(Icons.sort_by_alpha),
      //     SizedBox(width: 10),
      //     Text(
      //       "Học vấn",
      //       style: TextStyle(
      //         color: Color(0xFF9E9E9E),
      //         fontSize: 16.0,
      //         fontWeight: FontWeight.normal,
      //       ),
      //     ),
      //   ],
      // ),
      SizedBox(height: 10),
      // Row(
      //   children: [
      //     Icon(Icons.supervised_user_circle),
      //     SizedBox(width: 10),
      //     Text(
      //       "Tình trạng hôn nhân",
      //       style: TextStyle(
      //         color: Color(0xFF9E9E9E),
      //         fontSize: 16.0,
      //         fontWeight: FontWeight.normal,
      //       ),
      //     ),
      //   ],
      // ),
      SizedBox(height: 10),
    ],
  );
}
