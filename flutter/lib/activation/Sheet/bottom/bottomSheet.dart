import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Row singleOption(String nameOption, {iconOption, callbackFunction, context}) {
  /// tittle of options
  /// icon for options
  /// on tap function for options
  /// context parent for render
  return Row(children: [
    Expanded(
      child: FlatButton(
        color: Color(0xFFFFFFFF),
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 5, right: 5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // elevation: 0.0,
        onPressed: callbackFunction,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFBDBDBD)),
                child: Icon(
                  iconOption,
                  size: 23,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                '$nameOption',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 19,
                  color: Color(0xFF0000000),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  ]);
}

void showSlideBottomSheet(BuildContext context, {listOptions}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.only(top: 25, bottom: 20),
        decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35))),
        child: Wrap(
          children: [
            Center(
              child: Divider(
                height: 1,
                thickness: 3,
                color: Colors.grey[400],
                indent: MediaQuery.of(context).size.width * 0.43,
                endIndent: MediaQuery.of(context).size.width * 0.43,
              ),
            ),
            Wrap(children: listOptions),
          ],
        ),
      );
    },
  );
}
