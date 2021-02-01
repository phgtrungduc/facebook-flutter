import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../const/const.dart';

class Stories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
        margin: EdgeInsets.only(top: 5),
        color: WhiteColor,
        height: 280,
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == 0)
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: _StoryCard(
                          addStory: false,
                          user: "Phuong Trung Duc",
                        ),
                      );
                    else {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: _StoryCard(
                          addStory: true,
                          user: "Anonymous",
                        ),
                      );
                    }
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: WhiteColor,
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FlatButton(
                      padding: EdgeInsets.all(10),
                      color: LightBlueColor,
                      child: Text(
                        "Xem tất cả tin",
                        style: TextStyle(color: BlueColor, fontSize: 20),
                      ),
                      onPressed: () {},
                    )),
              )
            ],
          ),
        ));
  }
}

class _StoryCard extends StatelessWidget {
  final bool addStory;
  final String user;
  _StoryCard({Key key, @required this.addStory, @required this.user})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: Container(
            height: 200,
            width: 110,
            child: Image.asset(
              "assets/images/avatar.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
            height: 200,
            width: 110,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black26]))),
        Positioned(
            top: 8,
            left: 8,
            child: this.user == "Phuong Trung Duc"
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: WhiteColor),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 30,
                        color: BlueColor,
                      ),
                      onPressed: () {},
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: WhiteColor),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: BlueColor,
                      child: CircleAvatar(
                        backgroundImage: AssetImage("assets/images/story.jpg"),
                      ),
                    ))),
        Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              this.user == "Phuong Trung Duc" ? "Thêm tin" : "Tin đã thêm",
              style: TextStyle(color: WhiteColor, fontWeight: FontWeight.w900),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ))
      ],
    );
  }
}
