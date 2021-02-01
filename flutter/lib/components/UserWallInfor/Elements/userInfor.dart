import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/editPublicDetail/publicDetail.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class UserInfor extends StatefulWidget {
  final String userId;
  final bool isOwner;
  final String address;
  final String city;
  bool isLoading;
  Function callbackRefresh;
  UserInfor({
    Key key,
    this.userId,
    this.isOwner,
    this.address,
    this.city,
    this.isLoading,
    this.callbackRefresh,
  }) : super(key: key);

  @override
  _UserInforState createState() => _UserInforState();
}

class _UserInforState extends State<UserInfor> {
  ReusedWidget reusedWidget;

  @override
  void initState() {
    super.initState();
    reusedWidget = ReusedWidget();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String address = widget.address;
    String city = widget.city;
    return Container(
      // width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      child: !widget.isLoading
          ? Column(mainAxisSize: MainAxisSize.max, children: [
              if (city != null)
                reusedWidget.optionButton(
                    icon: FontAwesomeIcons.briefcase,
                    text: '$city',
                    callbackFunction: () {}),
              if (address != null)
                reusedWidget.optionButton(
                    icon: FontAwesomeIcons.home,
                    text: 'Sống tại $address',
                    callbackFunction: () {}),
              if (widget.isOwner)
                Center(
                  child: Container(
                    width: size.width,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideRightToLeftRoute(
                            page: PublicDetail(
                              userId: widget.userId,
                            ),
                          ),
                        ).whenComplete(() {
                          widget.callbackRefresh();
                        });
                      },
                      color: Color(0xFFE3F2FD),
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        'Chỉnh sửa chi tiết công khai',
                        style: TextStyle(
                          color: Color(0xFF01579B),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              Divider(
                indent: 0, //start devider
                endIndent: 0, //end devider
                height: 23,
                color: Colors.grey[400],
              )
            ])
          : Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Wrap(
                runSpacing: 10,
                children: [
                  Shimmer.fromColors(
                    baseColor: BaseColor,
                    highlightColor: HighlightColor,
                    child: Container(
                      width: size.width * 0.5,
                      height: 25,
                      color: BaseColor,
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: BaseColor,
                    highlightColor: HighlightColor,
                    child: Container(
                      width: size.width * 0.6,
                      height: 25,
                      color: BaseColor,
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: BaseColor,
                    highlightColor: HighlightColor,
                    child: Container(
                      width: size.width * 0.8,
                      height: 25,
                      color: BaseColor,
                    ),
                  ),
                  Divider(
                    indent: 0, //start devider
                    endIndent: 0, //end devider
                    height: 23,
                    color: Colors.grey[400],
                  )
                ],
              ),
            ),
    );
  }
}

class ReusedWidget {
  Align optionButton({icon, text, callbackFunction}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: callbackFunction,
        child: Padding(
          padding: const EdgeInsets.only(top: 3.0, bottom: 11.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 0.0, left: 7.0, bottom: 0.0, right: 17.0),
                child: Icon(
                  icon,
                  size: 26,
                  color: Color(0xDD000000),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 7.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 19,
                      color: Color(0xDD000000),
                      letterSpacing: 0.01,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
