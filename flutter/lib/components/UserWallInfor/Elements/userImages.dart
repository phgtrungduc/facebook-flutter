import 'dart:async';
import 'dart:convert';
import 'package:facebook/activation/imageClass/show/showFullScreenImage.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/UserWallInfor/userSetting.dart';
import 'package:facebook/components/animationRouteClass/ScaleAnimation.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/chat/chat_detail_page.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/model/UserInfor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facebook/activation/Sheet/bottom/bottomSheet.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class UserImages extends StatefulWidget {
  final String userId;
  final bool isOwner;
  final String userName;
  bool isLoading;
  String avatarUrl;
  String coverUrl;
  int isFriend;
  Function callbackRefresh;
  UserChatInfor userChatInfo;
  String ownID;
  UserImages({
    Key key,
    this.userId,
    this.isOwner,
    this.avatarUrl,
    this.coverUrl,
    this.userName,
    this.isFriend,
    this.isLoading,
    this.callbackRefresh,
    this.userChatInfo,
    this.ownID,
  }) : super(key: key);
  @override
  _UserImagesState createState() => _UserImagesState();
}

class _UserImagesState extends State<UserImages>
    with SingleTickerProviderStateMixin {
  //get userName, infor here from server use await async
  String userName;
  String avatarPostUrl;
  String coverPostUrl;

  List<Widget> listOptionsForCoverImage;
  List<Widget> listOptionsForAvatarImage;

  List<Widget> listOptionsForFriendRelationship;
  List<Widget> listAcceptOption;

  getImageFromPhone(ImageSource imageSource, String type) async {
    //value manage gallery and camera
    final picker = ImagePicker();
    var pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      switch (type) {
        case 'avatar':
          this.avatarPostUrl = pickedFile.path;
          break;
        case 'cover':
          this.coverPostUrl = pickedFile.path;
          break;
        default:
      }
    } else {
      this.avatarPostUrl = null;
      this.coverPostUrl = null;
    }
  }

  @override
  void initState() {
    super.initState();

    // print(widget.userName + ' tesst');
    listOptionsForCoverImage = [
      singleOption(
        'Xem ảnh bìa',
        iconOption: FontAwesomeIcons.image,
        context: context,
        callbackFunction: () {
          //turn off bottomsheet
          Navigator.pop(context);
          if (widget.coverUrl != null) {
            Navigator.push(
              context,
              ScaleAnimationRoute(
                page: ShowFullImage(
                  linkImage: widget.coverUrl,
                ),
              ),
            );
          } else {
            snackBar("Người dùng không có ảnh bìa", context);
          }
        },
      ),
      singleOption(
        'Chọn ảnh từ thư viện',
        iconOption: FontAwesomeIcons.userEdit,
        context: context,
        callbackFunction: () async {
          //turnoff bottom sheet
          Navigator.pop(context);
          await getImageFromPhone(ImageSource.gallery, 'cover');
          this.setCover(this.coverPostUrl);
        },
      ),
      singleOption(
        'Chọn ảnh từ máy ảnh',
        iconOption: FontAwesomeIcons.camera,
        context: context,
        callbackFunction: () async {
          //turnoff bottom sheet
          Navigator.pop(context);
          await getImageFromPhone(ImageSource.camera, 'cover');
          this.setCover(this.coverPostUrl);
        },
      ),
    ];

    //this is for avatar image
    listOptionsForAvatarImage = [
      singleOption(
        'Xem ảnh đại diện',
        iconOption: FontAwesomeIcons.image,
        context: context,
        callbackFunction: () {
          //turn off bottomsheet
          Navigator.pop(context);
          if (widget.avatarUrl != null) {
            Navigator.push(
              context,
              ScaleAnimationRoute(
                page: ShowFullImage(
                  linkImage: widget.avatarUrl,
                ),
              ),
            );
          } else {
            snackBar("Người dùng không có ảnh đại diện", context);
          }
        },
      ),
      singleOption(
        'Chọn ảnh từ thư viện',
        iconOption: FontAwesomeIcons.userEdit,
        context: context,
        callbackFunction: () async {
          //turnoff bottom sheet
          Navigator.pop(context);
          await this.getImageFromPhone(ImageSource.gallery, 'avatar');
          this.setAvatar(this.avatarPostUrl);
        },
      ),
      singleOption(
        'Chọn ảnh từ máy ảnh',
        iconOption: FontAwesomeIcons.camera,
        context: context,
        callbackFunction: () async {
          //turnoff bottom sheet
          Navigator.pop(context);
          await getImageFromPhone(ImageSource.camera, 'avatar');
          this.setAvatar(this.avatarPostUrl);
        },
      ),
    ];
    //this is for cover image

    if (!widget.isOwner) {
      //this is for cover image
      listOptionsForCoverImage = listOptionsForCoverImage.sublist(0, 1);

      //this is for avatar image
      listOptionsForAvatarImage = listOptionsForAvatarImage.sublist(0, 1);

      listOptionsForFriendRelationship = [
        singleOption('Hủy kết bạn', iconOption: FontAwesomeIcons.userTimes,
            callbackFunction: () {
          Navigator.pop(context);
          this.confirmUnfriend();
        })
      ];
    }

    listAcceptOption = [
      singleOption('Đồng ý', iconOption: FontAwesomeIcons.userCheck,
          callbackFunction: () {
        Navigator.pop(context);
        this.setAcceptFriend(1);
      }),
      singleOption('Từ chối', iconOption: FontAwesomeIcons.userLock,
          callbackFunction: () {
        Navigator.pop(context);
        this.setAcceptFriend(0);
      }),
    ];
  }

  Future<void> confirmUnfriend() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hủy kết bạn'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Bạn có chắc chắn muốn làm việc này ?')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tiếp tục'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() async {
                  await this.unfriend();
                });
              },
            ),
          ],
        );
      },
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Đang tải...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void snackBar(String text, BuildContext context) {
    var snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<void> setAvatar(String imgPath) async {
    if (imgPath == null) return;
    try {
      this.showLoaderDialog(context);
      API().setAvatar(imgPath).then((result) {
        result.stream.bytesToString().then((res) {
          Navigator.pop(context);
          int code = json.decode(res)['code'];
          if (code == 1000) {
            var data = json.decode(res)['data'];
            setState(() {
              widget.avatarUrl = Host + data['avatar'];
            });
          } else if (code == 9999) {
            snackBar(
                "Không thể cập nhật ảnh đại diện T.T. Xin hãy thử lại sau...",
                context);
          }
        });
      });
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
  }

  Future<void> setCover(String imgPath) async {
    if (imgPath == null) return;
    try {
      showLoaderDialog(context);
      API().setCover(imgPath).then((result) {
        result.stream.bytesToString().then((res) {
          Navigator.pop(context);
          int code = json.decode(res)['code'];
          if (code == 1000) {
            var data = json.decode(res)['data'];
            setState(() {
              widget.coverUrl = Host + data['cover_photo'];
            });
          } else if (code == 9999) {
            snackBar("Không thể cập nhật ảnh bìa :((. Xin hãy thử lại sau...",
                context);
          }
        });
      });
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
  }

  Future<void> setRequestFriend() async {
    this.showLoaderDialog(context);
    try {
      await API().setRequestFriend(widget.userId).then((res) {
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          // var data = json.decode(res.body)['data'];
          print(res.body);
          if (mounted) {
            setState(() {
              widget.isFriend = -1;
            });
          }
        } else if (code == 9999) {
          snackBar("Có lỗi xảy ra, vui lòng thử lại sau.", context);
        }
      });
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
    Navigator.pop(context);
  }

  Future<void> delRequestFriend() async {
    this.showLoaderDialog(context);
    try {
      await API().delRequestFriend(widget.userId).then((res) {
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          // var data = json.decode(res.body)['data'];
          print(res.body);
          if (mounted) {
            setState(() {
              widget.isFriend = 0;
            });
          }
        } else if (code == 9999) {
          snackBar("Có lỗi xảy ra, vui lòng thử lại sau.", context);
        } else if (code == 9994) {
          snackBar("Không thể thực hiện thao tác này.", context);
        }
      });
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
    Navigator.pop(context);
  }

  Future<void> unfriend() async {
    this.showLoaderDialog(context);
    try {
      await API().unfriend(widget.userId).then((res) {
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          // var data = json.decode(res.body)['data'];
          print(res.body);
          if (mounted) {
            setState(() {
              widget.isFriend = 0;
            });
          }
        } else if (code == 9999) {
          snackBar("Có lỗi xảy ra, vui lòng thử lại sau.", context);
        } else if (code == 9994) {
          snackBar("Không thể thực hiện thao tác này.", context);
        }
      });
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
    Navigator.pop(context);
  }

  Future<void> setAcceptFriend(int isAccept) async {
    this.showLoaderDialog(context);
    try {
      await API()
          .setAcceptFriend(int.parse(widget.userId), isAccept)
          .then((res) {
        int code = json.decode(res.body)['code'];
        if (code == 1000) {
          print(res.body);
          setState(() {
            if (isAccept == 1) {
              widget.isFriend = 1;
            } else {
              widget.isFriend = 0;
            }
          });
        } else if (code == 9999) {
          snackBar("Có lỗi xảy ra, vui lòng thử lại sau.", context);
        }
      });
    } on Exception {
      snackBar(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userName = widget.userName == null ? 'null' : widget.userName;
    Size size = MediaQuery.of(context).size;
    var coverWidth = size.width;
    var coverHeight = size.width * 0.6;
    var avatarWidth = (size.width - 30) * 0.5;
    var avatarHeight = (size.width - 30) * 0.5;
    var avatarMarginLeft = (size.width - 30) * 0.25;
    var avatarMarginTop = size.width * 0.3 + 15;
    return Container(
      child: Column(
        children: [
          Stack(
            children: <Widget>[
              Container(
                //height and width of container bottom
                width: coverWidth,
                height: coverHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showSlideBottomSheet(context,
                          listOptions: listOptionsForCoverImage);
                    },
                    child: Stack(
                      fit: StackFit.loose,
                      children: !widget.isLoading
                          ? [
                              Container(
                                color: Color(0xFFD6D6D6),
                                child: widget.coverUrl == null
                                    ? null
                                    : Image.network(
                                        widget.coverUrl,
                                        width: size.width,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null,
                                            ),
                                          );
                                          //   child:
                                          //       Image.asset('assets/lazy_loading/39.gif'),
                                          // );
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                // child: FadeInImage.assetNetwork(
                                //   placeholder: 'assets/lazy_loading/16_green.gif',
                                //   image: coverImageUrl,
                                //   width: size.width,
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              if (widget.isOwner)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton(
                                    heroTag: null,
                                    elevation: 0.4,
                                    foregroundColor: Color(0xFF000000),
                                    backgroundColor: Color(0xFFEEEEEE),
                                    onPressed: () {
                                      showSlideBottomSheet(context,
                                          listOptions: listOptionsForCoverImage
                                              .sublist(1, 3));
                                    },
                                    mini: true,
                                    child: Icon(
                                      FontAwesomeIcons.camera,
                                      size: 17,
                                    ),
                                  ),
                                ),
                            ]
                          : [
                              Shimmer.fromColors(
                                baseColor: BaseColor,
                                highlightColor: HighlightColor,
                                child: Container(
                                  width: coverWidth,
                                  height: coverHeight,
                                  color: BaseColor,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ),
              Container(
                width: avatarWidth, // tru` di phan` padding
                height: avatarHeight,
                margin: EdgeInsets.only(
                  left: avatarMarginLeft, // tru` di pha`n padding 2 ben
                  top:
                      avatarMarginTop, // dich chuyen them phan` padding ben tren
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFFFFFFF),
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(size.width),
                  ),
                  color: Color(0xFFE9E9E9),
                ),
                child: !widget.isLoading
                    ? GestureDetector(
                        onTap: () {
                          showSlideBottomSheet(context,
                              listOptions: listOptionsForAvatarImage);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 50,
                          backgroundImage: widget.avatarUrl == null
                              ? AssetImage(PlaceHolderAvatarUrl)
                              : NetworkImage(widget.avatarUrl),
                          child: widget.isOwner
                              ? Align(
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton(
                                    heroTag: null,
                                    elevation: 0.4,
                                    backgroundColor: Color(0xFFEEEEEE),
                                    foregroundColor: Color(0xFF000000),
                                    mini: true,
                                    onPressed: () {
                                      showSlideBottomSheet(context,
                                          listOptions: listOptionsForAvatarImage
                                              .sublist(1, 3));
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.camera,
                                      size: 17,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      )
                    : Shimmer.fromColors(
                        baseColor: BaseColor,
                        highlightColor: HighlightColor,
                        child: CircleAvatar(
                          backgroundColor: BaseColor,
                          radius: 50,
                        ),
                      ),
              ),
            ],
          ),
          !widget.isLoading
              ? Column(
                  children: [
                    Center(
                      child: Text(
                        this.userName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    (widget.isOwner)
                        ? Center(
                            child: Container(
                              width: size.width * 0.8,
                              padding: EdgeInsets.only(
                                top: 10,
                                // bottom: 15,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: RaisedButton(
                                      color: Color(0xFF1976D2),
                                      elevation: 0.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      padding: EdgeInsets.all(5),
                                      onPressed: () {
                                        //do something with story
                                      },
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Icon(
                                                Icons.add_circle,
                                                color: Color(0xFFFFFFFF),
                                                size: 25,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Thêm vào tin',
                                                style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: RaisedButton(
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            SlideRightToLeftRoute(
                                              page: UserSetting(
                                                userId: widget.userId,
                                                userName: '$userName',
                                                isOwner: widget.isOwner,
                                              ),
                                            ),
                                          ).whenComplete(() {
                                            widget.callbackRefresh();
                                          });
                                        },
                                        child: Icon(
                                          Icons.more_horiz,
                                          size: 23,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                              width: size.width,
                              padding: EdgeInsets.only(
                                top: 10,
                                // bottom: 15,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: RaisedButton(
                                      color: Color(0xFF1976D2),
                                      elevation: 0.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      padding: EdgeInsets.all(5),
                                      onPressed: () {
                                        //do something with message
                                        switch (widget.isFriend) {
                                          case 1:
                                            showSlideBottomSheet(context,
                                                listOptions:
                                                    listOptionsForFriendRelationship);
                                            break;
                                          case 0:
                                            this.setRequestFriend();
                                            break;
                                          case -1:
                                            this.delRequestFriend();
                                            break;
                                          case -2:
                                            showSlideBottomSheet(context,
                                                listOptions: listAcceptOption);
                                            break;
                                        }
                                      },
                                      child: relationshipUi(),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: RaisedButton(
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            SlideRightToLeftRoute(
                                              page: ChatDetailPage(
                                                ownId: widget.ownID,
                                                friendChatInfor:
                                                    widget.userChatInfo,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Wrap(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons
                                                  .facebookMessenger,
                                              color: Color(0xFF000000),
                                              size: 23,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: RaisedButton(
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            SlideRightToLeftRoute(
                                              page: UserSetting(
                                                userId: widget.userId,
                                                userName: this.userName,
                                                isOwner: widget.isOwner,
                                              ),
                                            ),
                                          ).whenComplete(() {
                                            widget.callbackRefresh();
                                          });
                                        },
                                        child: Wrap(
                                          children: [
                                            Icon(
                                              Icons.more_horiz,
                                              color: Color(0xFF000000),
                                              size: 23,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                )
              : Shimmer.fromColors(
                  baseColor: BaseColor,
                  highlightColor: HighlightColor,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          color: BaseColor,
                          width: size.width * 0.55,
                          height: 28,
                        ),
                        Row(
                          children: [
                            Container(
                              color: BaseColor,
                              width: size.width * 0.4,
                              height: 24,
                            ),
                            SizedBox(
                              height: 0,
                              width: size.width * 0.3 - 15.0 * 2,
                            ),
                            Container(
                              color: BaseColor,
                              width: size.width * 0.15,
                              height: 24,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
          Divider(
            indent: 0, //start devider
            endIndent: 0, //end devider
            height: 23,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Wrap relationshipUi() {
    widget.isFriend = widget.isFriend == null ? 1 : widget.isFriend;
    var icon;
    String _text;
    switch (widget.isFriend) {
      case 1:
        icon = FontAwesomeIcons.userCheck;
        _text = 'Bạn bè';
        break;
      case -2:
        icon = FontAwesomeIcons.userCheck;
        _text = 'Trả lời';
        break;
      case -1:
        icon = FontAwesomeIcons.userCheck;
        _text = 'Chờ phản hồi';
        break;
      case 0:
        icon = FontAwesomeIcons.userPlus;
        _text = 'Thêm bạn bè';
        break;
    }
    return Wrap(
      spacing: 20,
      children: [
        Icon(
          icon,
          color: Color(0xFFFFFFFF),
          size: 23,
        ),
        Text(
          _text,
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),
        )
      ],
    );
  }
}
