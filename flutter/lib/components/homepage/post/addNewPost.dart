import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:facebook/components/homepage/homepage.dart';
import 'package:facebook/components/homepage/post/feelingScreen.dart';
import 'package:facebook/const/feelingInNewPost.dart';
import 'package:facebook/mainScreen.dart';
import 'package:facebook/model/UserInfor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../const/const.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:http/http.dart' as http;

class AddNewPost extends StatefulWidget {
  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  File _image;
  List _videos = [];
  final picker = ImagePicker();
  final _inputController = new TextEditingController();
  bool isReadOnly = false;
  bool hasContent = false;
  FeelingInNewPost isHasFeeling = null;
  List<Asset> _images = List<Asset>();
  String _error = 'No Error Dectected';
  Size size;
  UserChatInfor ownChatInfor;
  List<Asset> resultList = List<Asset>();
  bool upload = false;
  void _getOwnInfor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ownChatInfor =
          UserChatInfor.fromJson(json.decode(prefs.getString("information")));
    });
  }

  Future<void> loadAssets() async {
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        selectedAssets: _images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
      if (this._images.length > 0) {
        setState(() {
          this._videos.clear();
        });
      }
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _images = resultList;
      _error = error;
    });
  }

  Widget buildGridView() {
    int number = _images.length;
    if (number == 5) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  height: 210,
                  child: AssetThumb(
                    asset: _images[0],
                    width: 210,
                    height: 210,
                  ),
                ),
                Container(
                  height: 210,
                  child: AssetThumb(
                    asset: _images[1],
                    width: 210,
                    height: 210,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  height: 140,
                  child: AssetThumb(
                    asset: _images[2],
                    width: 210,
                    height: 140,
                  ),
                ),
                Container(
                  height: 140,
                  child: AssetThumb(
                    asset: _images[3],
                    width: 210,
                    height: 140,
                  ),
                ),
                Container(
                  height: 140,
                  child: AssetThumb(
                    asset: _images[4],
                    width: 210,
                    height: 140,
                  ),
                )
              ],
            ),
          )
        ],
      );
    } else if (number == 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  height: 200,
                  child: AssetThumb(
                    asset: _images[0],
                    width: 200,
                    height: 200,
                  ),
                ),
                Container(
                  height: 200,
                  child: AssetThumb(
                    asset: _images[1],
                    width: 200,
                    height: 200,
                  ),
                )
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                  height: 400,
                  child: AssetThumb(
                    asset: _images[2],
                    width: 200,
                    height: 400,
                  )))
        ],
      );
    } else {
      if (number > 2) number = 2;
      return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: (number != 0) ? number : 2,
        children: List.generate(_images.length, (index) {
          Asset asset = _images[index];
          return AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          );
        }),
      );
    }
  }

  bool showButtonControll = true;
  Widget buildVideo() {
    return Center(
      child: _videoPlayerController.value.initialized
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onTap: () {
                  if (!this.showButtonControll) {
                    if (mounted) {
                      this.setState(() {
                        this.showButtonControll = true;
                      });
                      Timer(Duration(seconds: 5), () {
                        setState(() {
                          this.showButtonControll = false;
                        });
                      });
                    }
                  }
                },
                child: Stack(
                  children: [
                    VideoPlayer(_videoPlayerController),
                    Align(
                      alignment: Alignment.center,
                      child: this.showButtonControll
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _videoPlayerController.value.isPlaying
                                      ? _videoPlayerController.pause()
                                      : _videoPlayerController.play();
                                  Timer(Duration(seconds: 5), () {
                                    if (mounted) {
                                      setState(() {
                                        this.showButtonControll = false;
                                      });
                                    }
                                  });
                                });
                              },
                              child: Icon(
                                _videoPlayerController.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: WhiteColor,
                                size: 50,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            )
          : Container(
              width: size.width,
              height: size.width * (9 / 16),
              color: BlackColor,
            ),
    );
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  VideoPlayerController _videoPlayerController;

  File _cameraVideo;

  File _video;
// This funcion will helps you to pick a Video File
  _pickVideo() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _video = video;
      setState(() {
        this._videos.clear();

        this._videos.add(video);
        this._images.clear();
      });
      _videoPlayerController = VideoPlayerController.file(_video)
        ..initialize().then((_) {
          setState(() {});
          // _videoPlayerController.play();
        });
    }
  }

  _pickVideoFromCamera() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      _cameraVideo = video;
      setState(() {
        this._videos.clear();
        this._videos.add(video);
        this._images.clear();
      });
      _videoPlayerController = VideoPlayerController.file(_cameraVideo)
        ..initialize().then((_) {
          setState(() {});
          // _videoPlayerController.play();
        });
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

  Future<http.StreamedResponse> addPost() async {
    setState(() {
      upload = true;
    });
    var request = http.MultipartRequest('POST', Uri.parse(Host + 'add_post'));
    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: "acessToken");
    var headers = {'accessToken': token};
    request.headers.addAll(headers);
    try {
      for (Asset asset in this._images) {
        int MAX_WIDTH = 500; //keep ratio
        int height =
            ((500 * asset.originalHeight) / asset.originalWidth).round();

        ByteData byteData = await asset.getByteData();

        if (byteData != null) {
          List<int> imageData = byteData.buffer.asUint8List();
          http.MultipartFile u = http.MultipartFile.fromBytes(
            'data',
            imageData,
            filename: asset.name,
          );
          request.files.add(u);
          //goi api o day
        }
      }
      for (var video in this._videos) {
        var videoData = await video.readAsBytes();
        http.MultipartFile u = http.MultipartFile.fromBytes(
          'data',
          videoData,
          filename: 'videouser.mp4',
        );
        request.files.add(u);
      }
      if (this._images.length > 0) {
        request.fields.addAll({'type': 'image'});
      } else if (this._videos.length > 0) {
        request.fields.addAll({'type': 'video'});
      }
      request.fields.addAll({'described': _inputController.text});
      if (this.isHasFeeling != null)
        request.fields.addAll({'status': this.isHasFeeling.feeling});
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        response.stream.bytesToString().then((res) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => new MainScreen()));
          print(
              res); // data cua serrverr // lam gi` do' voi data server cho nay`
        });
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
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
                                  )
                                ],
                              );
                            });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text("Tạo bài viết"),
                  actions: [
                    this.upload
                        ? FlatButton(
                            onPressed: null,
                            child: CircularProgressIndicator(
                              backgroundColor: GreyBackgroud,
                            ))
                        : FlatButton(
                            child: Text(
                              "ĐĂNG",
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: this.hasContent
                                ? () {
                                    addPost();
                                  }
                                : null,
                          )
                  ],
                ),
                body: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(top: 15, left: 15, right: 15),
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
                                                    this.isHasFeeling.icon,
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
                          if (this._images.length > 0) buildGridView(),
                          if (this._videos.length > 0) buildVideo(),
                        ]),
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
                                          onTap: loadAssets,
                                          leading: Icon(
                                            Icons.image,
                                            size: 30,
                                            color: PhotoColor,
                                          ),
                                          title: Text("Ảnh",
                                              style: TextStyle(
                                                  color: BlackColor,
                                                  fontSize: 18)),
                                        ),
                                        ListTile(
                                          onTap: () {
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
                                        ListTile(
                                          onTap: () {},
                                          leading: Icon(
                                            Icons.location_on,
                                            size: 30,
                                            color: CheckInColor,
                                          ),
                                          title: Text("Địa điểm",
                                              style: TextStyle(
                                                  color: BlackColor,
                                                  fontSize: 18)),
                                        ),
                                        ListTile(
                                          onTap: () async {
                                            await this._pickVideo();
                                          },
                                          leading: Icon(Icons.camera_alt,
                                              size: 30, color: CameraColor),
                                          title: Text("Video thư viện",
                                              style: TextStyle(
                                                  color: BlackColor,
                                                  fontSize: 18)),
                                        ),
                                        ListTile(
                                          onTap: () async {
                                            await this._pickVideoFromCamera();
                                          },
                                          leading: Icon(Icons.camera_alt,
                                              size: 30, color: CameraColor),
                                          title: Text("Video từ máy ảnh",
                                              style: TextStyle(
                                                  color: BlackColor,
                                                  fontSize: 18)),
                                        ),
                                        ListTile(
                                          onTap: () {},
                                          leading: Icon(
                                            Icons.gif,
                                            size: 30,
                                            color: GIFColor,
                                          ),
                                          title: Text("GIF",
                                              style: TextStyle(
                                                  color: BlackColor,
                                                  fontSize: 18)),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: ListTile(
                          title: Text(
                            "Thêm vào bài đăng",
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
