import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:facebook/activation/accessHardware/accessHardware.dart';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:facebook/components/editPublicDetail/EditAddressPane1.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:facebook/activation/Sheet/bottom/bottomSheet.dart';
import 'Elements/WidgetDetails.dart';

class PublicDetail extends StatefulWidget {
  final String userId;

  const PublicDetail({Key key, this.userId}) : super(key: key);

  @override
  _PublicDetailState createState() => _PublicDetailState();
}

class _PublicDetailState extends State<PublicDetail> {
  bool internet = true;
  bool hasData = false;
  bool isLoading = false;
  Map userInfor = Map();

  String avatarPostUrl;
  String coverPostUrl;

  List<Widget> listOptionsForCoverImage;
  List<Widget> listOptionsForAvatarImage;

  //ScrollController _scrollController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    this.getUserInfo(widget.userId);
    super.initState();

    listOptionsForCoverImage = [
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
  }

  void _onRefresh() async {
    this.getUserInfo(widget.userId);
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void callbackRefresh() {
    this.getUserInfo(widget.userId);
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('chỉnh sửa chi tiết công khai',
            style: TextStyle(fontSize: 16.0)),
        elevation: 0.9,
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: SmartRefresher(
            enablePullDown: true,
            header: MaterialClassicHeader(
              distance: 30.0,
              color: CircularColor,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: this.isLoading
                ? ListView(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Column(
                        children: [
                          for (int i = 0; i < 20; i++)
                            Shimmer.fromColors(
                              baseColor: BaseColor,
                              highlightColor: HighlightColor,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: BaseColor,
                                ),
                                title: Container(
                                  height: 20,
                                  color: BaseColor,
                                ),
                                subtitle: Container(
                                  height: 12,
                                  color: BaseColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ])
                : this.internet
                    ? this.hasData
                        ? ListView(
                            children: <Widget>[
                              rowTitle("Ảnh đại diện", "Chỉnh sửa", context),
                              Center(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width:
                                      MediaQuery.of(context).size.height * 0.2,
                                  child: ClipOval(
                                    child: userInfor['avatar'] == null
                                        ? Image.asset(PlaceHolderAvatarUrl,
                                            fit: BoxFit.cover)
                                        : Image.network(
                                            Host + userInfor['avatar'],
                                            // width: size.width,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes
                                                      : null,
                                                ),
                                                // child: Image.asset('assets/lazy_loading/16_green.gif'),
                                              );
                                            },
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: Colors.grey[800],
                                height: 30.0,
                              ),
                              rowTitle("Ảnh bìa", "Chỉnh sửa", context),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: userInfor['cover_photo'] == null
                                      ? Image.asset(PlaceHolderAvatarUrl,
                                          fit: BoxFit.cover)
                                      : Image.network(
                                          Host + userInfor['cover_photo'],
                                          // width: size.width,
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
                                              // child: Image.asset('assets/lazy_loading/16_green.gif'),
                                            );
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Divider(
                                color: Colors.grey[800],
                                height: 30.0,
                              ),
                              rowTitle("Tiểu sử", "Chỉnh sửa", context),
                              Center(
                                child: Text("Mô tả bản thân ....",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    )),
                              ),
                              Divider(
                                color: Colors.grey[800],
                                height: 30.0,
                              ),
                              rowTitle("Chi tiết", "Chỉnh sửa", context),
                              details(userInfor['city'], userInfor['address']),
                            ],
                          )
                        : NoDataScreen(
                            title: 'Người dùng không tồn tại ',
                            userId: widget.userId,
                            emitParent: this.getUserInfo(widget.userId),
                          )
                    : NoDataScreen(
                        title: ' Không có kết nối mạng',
                        userId: widget.userId,
                        emitParent: this.getUserInfo(widget.userId),
                      )),
      ),
    );
  }

  Widget rowTitle(String title, String action, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            RaisedButton(
              onPressed: () {
                if (title == "Ảnh đại diện") {
                  showSlideBottomSheet(context,
                      listOptions: listOptionsForAvatarImage);
                } else if (title == "Ảnh bìa") {
                  showSlideBottomSheet(context,
                      listOptions: listOptionsForCoverImage);
                } else if (title == "Tiểu sử") {
                  // mở giao diện chỉnh sửa tiểu sử
                } else if (title == "Chi tiết") {
                  // mở giao diện chỉnh sửa chi tiết
                  Navigator.push(
                    context,
                    SlideRightToLeftRoute(
                      page: EditAddressPane1(
                          userId: widget.userId,
                          city: userInfor['address'],
                          callbackRefresh: this.callbackRefresh),
                    ),
                  );
                }
              },
              color: Color(0xFFFFFFFF),
              child: Text(
                action,
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  void showBottomSheet(String message, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text('$message'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> hasInternet() async {
    print('checking internet ...');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        this.internet = false;
      });
    } else {
      if (mounted) {
        setState(() {
          this.internet = true;
        });
      }
    }
    return;
  }

  Future<void> getUserInfo(String userId) async {
    this.hasInternet();
    if (this.internet == false) return;
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    API api = new API();
    try {
      await api.getUserInfor(widget.userId).then((res) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        int code = json.decode(res.body)["code"];
        if (code == 1000) {
          setState(() {
            this.hasData = true;
            userInfor.clear();
            userInfor = json.decode(res.body)["data"];
            print('user infor below :');
            print(userInfor);
          });
        } else if (code == 9999) {
          setState(() {
            this.hasData = false;
          });
        }
      });
    } on Exception {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Kết nối mạng không ổn định hoặc server không phản hồi");
    }
  }

  Future<void> setAvatar(String imgPath) async {
    if (imgPath == null) return;
    try {
      showLoaderDialog(context);
      API().setAvatar(imgPath).then((result) {
        result.stream.bytesToString().then((res) {
          Navigator.pop(context);
          print(res);
          int code = json.decode(res)['code'];
          if (code == 1000) {
            var data = json.decode(res)['data'];
            setState(() {
              userInfor['avatar'] = data['avatar'];
            });
          } else if (code == 9999) {
            showBottomSheet(
                "Không thể cập nhật ảnh đại diện T.T. Xin hãy thử lại sau...",
                context);
          }
        });
      });
    } on Exception {
      showBottomSheet(
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
          print(res);
          int code = json.decode(res)['code'];
          if (code == 1000) {
            var data = json.decode(res)['data'];
            setState(() {
              userInfor['cover_photo'] = data['cover_photo'];
            });
          } else if (code == 9999) {
            showBottomSheet(
                "Không thể cập nhật ảnh bìa :((. Xin hãy thử lại sau...",
                context);
          }
        });
      });
    } on Exception {
      showBottomSheet(
          "Kết nối mạng không ổn định hoặc server không phản hồi", context);
    }
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
}
