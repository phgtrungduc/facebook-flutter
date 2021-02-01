import 'dart:convert';
import 'dart:io';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/homepage/post/feelingScreen.dart';
import 'package:facebook/const/feelingInNewPost.dart';
import 'package:facebook/mainScreen.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:facebook/model/UserInfor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../const/const.dart';

class EditPost extends StatefulWidget {
  String postId;
  EditPost({this.postId});
  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<EditPost> {
  API api;
  PostModel postModel;
  final picker = ImagePicker();
  final _inputController = new TextEditingController();
  bool isReadOnly = false;
  bool hasContent = false;
  FeelingInNewPost isHasFeeling = null;
  Size size;
  UserChatInfor ownChatInfor;
  bool upload = false;
  List<dynamic> images;
  bool hasChange = false;
  loadData() {
    try {
      api.getPost(widget.postId).then((res) {
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          PostModel postModelTemp =
              PostModel.fromJson(json.decode(res.body)["data"]);
          this._inputController.text = postModelTemp.described;
          if (postModelTemp.status != null&&postModelTemp.status.trim()!="") {
            FeelingInNewPost temp = new FeelingInNewPost(
                feeling: postModelTemp.status, icon: FontAwesomeIcons.smile);
            setState(() {
              isHasFeeling = temp;
            });
          }

          setState(() {
            images = postModelTemp.images;
          });
        }
      }).catchError((e) {
        print(e.toString());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _getOwnInfor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ownChatInfor =
          UserChatInfor.fromJson(json.decode(prefs.getString("information")));
    });
  }


  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      API api = new API();
      api.uploadData(pickedFile.path).then((res) {
        String link = json.decode(res)["link"];
        print(link);
        List<dynamic> imagesTemp = this.images;
        imagesTemp.add(link);
        setState(() {
          images = imagesTemp;
        });
      }).catchError((e) {
        print(e);
      });
    } else {
      print('No image selected.');
    }
  }

  void setFeeling(FeelingInNewPost newFeeling) {
    print("set feeling");
    setState(() {
      this.isHasFeeling = newFeeling;
    });
  }

  void cancelFeeling() {
    print("cancle feeling");
    setState(() {
      this.isHasFeeling = null;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOwnInfor();
    _inputController.addListener(() {
      this.valueInput();
    });
    api = new API();
    images = new List<String>();
    this.loadData();
  }

  dynamic getAvatar(String avatar) {
    if (avatar == null) {
      return AssetImage('assets/images/avatar_placeholder.png');
    } else {
      return NetworkImage(Host + avatar);
    }
  }

  int findPositionSpace(String string) {
    int length = string.length;
    for (int i = length - 1; i >= 0; i--) {
      if (string[i] == " ") return i;
    }
    return -1;
  }

  void valueInput() {
    if (_inputController.text != null && _inputController.text.trim() != "") {
      setState(() {
        hasContent = true;
        hasChange = true;
      });
    } else {
      setState(() {
        hasContent = false;
      });
    }
    var temp = _inputController.text;
    var tempClean = temp.trim();
    int position = findPositionSpace(tempClean);
    if (position != -1) {
      String firstString = temp.substring(0, position + 1);
      String twoString = temp.substring(position + 1, temp.length);
      if (twoString == ":D") {
        _inputController.text = firstString + "\u{1F600}";
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );
      }
    } else {
      if (temp.trim() == ":D") {
        _inputController.text = "\u{1F600}";
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );
      }
    }
  }

  void editImages(int index) {
    setState(() {
      hasChange = true;
    });
    List<dynamic> imagesTemp = this.images;
    imagesTemp.removeAt(index);
    setState(() {
      images = imagesTemp;
    });
  }

  void editPost() {
    setState(() {
      upload = true;
    });
    print("edit post");
    String postId = widget.postId;
    String described = _inputController.text;
    String status;
    List<String> imagesSend = List<String>.from(this.images);
    if (this.isHasFeeling != null)
      status = this.isHasFeeling.feeling;
    else
      status = null;
    print(postId);
    print(described);
    print(status);
    print(this.images);
    api.editPost(postId, described, imagesSend, status).then((res) {
      int code = json.decode(res.body)["code"];
      if (code==1000) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen()),
        );
      }else {
        print("loi");
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return this.ownChatInfor != null
        ? Material(
            child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_inputController.text.trim() != "") {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text(
                                      "Bạn muốn hoàn thành bài viết của mình sau?",
                                      style: TextStyle(
                                          color: BlackColor, fontSize: 18),
                                    ),
                                    subtitle: Text(
                                        "Lưu làm bản nháp hoặc bạn có thể tiếp tục chỉnh sửa"),
                                  ),
                                  ListTile(
                                    onTap: () {},
                                    leading: FaIcon(FontAwesomeIcons.bookmark,
                                        size: 25),
                                    title: Text("Lưu làm bản nháp",
                                        style: TextStyle(
                                            color: BlackColor, fontSize: 18)),
                                    subtitle: Text(
                                        "Bạn sẽ nhận được thông báo về bản nháp"),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      setState(() {
                                        isReadOnly = true;
                                      });
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    leading: FaIcon(FontAwesomeIcons.trashAlt,
                                        size: 25),
                                    title: Text("Bỏ bài viết",
                                        style: TextStyle(
                                            color: BlackColor, fontSize: 18)),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          isReadOnly = false;
                                        });
                                        Navigator.pop(context);
                                      },
                                      leading: Icon(
                                        Icons.done,
                                        size: 30,
                                        color: DoneColor,
                                      ),
                                      title: Text("Tiếp tục chỉnh sửa",
                                          style: TextStyle(
                                              color: DoneColor, fontSize: 18)),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text("Chỉnh sửa bài viết"),
                  actions: [
                    this.upload
                        ? FlatButton(
                            onPressed: null,
                            child: CircularProgressIndicator(
                              backgroundColor: GreyBackgroud,
                            ))
                        : FlatButton(
                            child: Text(
                              "XONG",
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: this.hasContent && this.hasChange
                                ? () {
                                    this.editPost();
                                  }
                                : null,
                          )
                  ],
                ),
                body: Container(
                  padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      getAvatar(this.ownChatInfor.avatar)),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: isHasFeeling != null
                                    ? RichText(
                                        overflow: TextOverflow.visible,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: this.ownChatInfor.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                  color: BlackColor),
                                            ),
                                            TextSpan(
                                                text: " ― Đang ",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: BlackColor)),
                                            WidgetSpan(
                                              child: FaIcon(
                                                  FontAwesomeIcons.smile,
                                                  size: 18),
                                            ),
                                            TextSpan(
                                                text: " cảm thấy ",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: BlackColor)),
                                            TextSpan(
                                              text: this.isHasFeeling.feeling,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                  color: BlackColor),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(
                                        this.ownChatInfor.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: BlackColor),
                                      ),
                              )
                            ]),
                        Container(
                          width: double.infinity,
                          child: TextField(
                            readOnly: this.isReadOnly,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: _inputController,
                            style: TextStyle(
                              fontSize: 25,
                            ),
                            decoration: InputDecoration(
                              hintText: "Bạn đang nghĩ gì ?",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        //_image!=null?Image.file(_image,fit: BoxFit.cover,):SizedBox.shrink(),
                        this.images != null
                            ? GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                children: List.generate(this.images.length + 1,
                                    (index) {
                                  if (index == this.images.length) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: GreyAboutPost,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: IconButton(
                                        icon: Icon(Icons.add_circle_outlined),
                                        onPressed: () {
                                          getImageFromGallery();
                                        },
                                      ),
                                    );
                                  } else {
                                    return Stack(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Image.network(
                                            Host + this.images[index],
                                            fit: BoxFit.fill,
                                            height: 200,
                                          ),
                                        ),
                                        Positioned(
                                          child: IconButton(
                                            icon:
                                                FaIcon(FontAwesomeIcons.timesCircle),
                                            onPressed: () {
                                              editImages(index);
                                            },
                                          ),
                                          top: -12,
                                          right: -12,
                                        ),
                                      ],
                                    );
                                  }
                                }),
                              )
                            : SizedBox.shrink(),

                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
                bottomSheet: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                        color: GreyTimeAndIcon.withOpacity(0.3)),
                    child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  color: Color(0xFF737373),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: WhiteColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          onTap: () {
                                            setState(() {
                                              hasChange = true;
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FeelingScreen(
                                                          setFeeling:
                                                              this.setFeeling,
                                                          cancelFeeling: this
                                                              .cancelFeeling,
                                                          nowFeeling: this
                                                              .isHasFeeling)),
                                            );
                                          },
                                          leading: FaIcon(
                                              FontAwesomeIcons.solidGrinAlt,
                                              size: 30,
                                              color: FeelingColor),
                                          title: Text("Cảm xúc",
                                              style: TextStyle(
                                                  color: BlackColor,
                                                  fontSize: 18)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: ListTile(
                          title: Text(
                            "Thêm vào bài chỉnh sửa",
                            style: TextStyle(color: BlackColor),
                          ),
                          trailing: Container(
                              child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image,
                                size: 30,
                                color: PhotoColor,
                              ),
                              FaIcon(FontAwesomeIcons.solidGrinAlt,
                                  size: 30, color: FeelingColor),
                              Icon(
                                Icons.location_on,
                                size: 30,
                                color: CheckInColor,
                              ),
                            ],
                          )),
                        )))),
          )
        : Scaffold(
            body: Center(
            child: CircularProgressIndicator(
              backgroundColor: BlueColor,
            ),
          ));
  }
}
