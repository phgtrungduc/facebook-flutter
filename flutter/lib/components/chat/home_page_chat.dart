import 'dart:convert';
import 'dart:core';
import 'package:facebook/api/api.dart';
import 'package:facebook/components/chat/header_chat.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/components/data/data.dart';
import 'package:facebook/components/chat/chat_detail_page.dart';
import 'package:facebook/model/UserInfor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class HomePageChat extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePageChat> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  bool isLoading = true;
  final storage = new FlutterSecureStorage();
  final api = new API();
  List<UserChatInfor> listUser;
  String ID;
  String name;
  String otherName;
  String accessToken;
  Map data;
  String chatId;
  void loadToken() async {
    String value = await storage.read(key: "acessToken");
    accessToken = value;
  }

  // void addData() {
  //   print("add data");
  //   Map<String, dynamic> map = {"name": "Phương Trung abcd", "age": "20"};
  //   collectionReference.add(map).then((res) {
  //     print(
  //         "Thêm dữ liệu thành công"); //res là dữ liệu đã thêm sau khi thêm thành công trả về docment đó
  //   });
  // }

  /*5f735dd0ca729904f881dfd1  5f92f32a8bfccb1f38b05302*/

  // void updateData() async {
  //   print("update data");
  //   QuerySnapshot querySnapshot = await collectionReference.get();
  //   querySnapshot.docs[5].reference.update({"age": 16});
  // }

  void _onRefresh() async {
    // if failed,use refreshFailed()
    loadData();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // await this.getUserInfo(widget.userId);
    // // if failed,use loadFailed(),if no data return,use LoadNodata()
    // if (mounted) setState(() {});
    // _refreshController.loadComplete();
  }

  void _getPreShare() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ID = prefs.getString("id_user");
      name = prefs.getString("name");
    });
  }
  void loadData(){
    if (mounted){
      setState(() {
        listUser = [];
        isLoading = true;
      });


    List<UserChatInfor> listTemp = List<UserChatInfor>();
    Firebase.initializeApp().whenComplete(() {
      FirebaseFirestore.instance
          .collection("chats")
          .where("users", arrayContains: this.ID)
          .orderBy('last_edit', descending: true)
          .get().then( (res){
        res.docs.forEach((element) async {

            var user = element.data()["users"];
            UserChatInfor temp = await getUserInfor(user);
            temp.chatId = element.reference.id;
            listTemp.add(temp);
            setState(() {
              listUser = listTemp;
            });

        });
        setState(() {
          isLoading = false;
        });
      });
    });
    }
  }
  void initState() {
    loadToken();
    _getPreShare();
    loadData();
  }

  Future<String> getName(user) async {
    String name;
    if (user[0] != this.ID) {
      await api.userInfor(user[0]).then((value) {
        name = jsonDecode(value.body)["data"]["name"];
      });
    } else {
      await api.userInfor(user[1]).then((value) {
        name = jsonDecode(value.body)["data"]["name"];
      });
    }
    return name;
  }

  Future<UserChatInfor> getUserInfor(user) async {
    UserChatInfor userInfor;
    if (user[0] != this.ID) {
      await api.userInfor(user[0]).then((value) {
        userInfor = UserChatInfor.fromJson(jsonDecode(value.body)["data"]);
      });
    } else {
      await api.userInfor(user[1]).then((value) {
        userInfor = UserChatInfor.fromJson(jsonDecode(value.body)["data"]);
      });
    }
    return userInfor;
  }

  @override
  Widget build(BuildContext context) {
    print(this.listUser);
    return Material(
        child: this.isLoading?SafeArea(child: Center(child:_Loading() ,),)
            :SafeArea(
          child:SmartRefresher(
              enablePullDown: true,
              header: MaterialClassicHeader(
                distance: 30.0,
                color: CircularColor,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
                child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: <Widget>[
                  HeaderChat(),
                  SizedBox(
                    height: 30,
                  ),
                  // RaisedButton(
                  //   child: Text("Press here"),
                  //   onPressed: () async {
                  //     var  ID = this.listChat[0].data()["users"];
                  //     String res =await this.getName(ID);
                  //     print( res);
                  //   },
                  // ),
                  //cac doan chat
                  this.listUser!=null&&this.listUser.length!=0?Column(
                    children: List.generate(this.listUser.length, (index) {
                      return InkWell(
                        onLongPress: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.restore_from_trash),
                                      title: Text("Xóa cuộc trò chuyện này?"),
                                    )
                                  ],
                                );
                              });
                        },
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => new ChatDetailPage(
                                ownId:this.ID,
                                friendChatInfor: this.listUser[index],
                              )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 75,
                                height: 75,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: this.listUser[index].avatar ==
                                                  null
                                              ? AssetImage(
                                                  'assets/images/avatar_placeholder.png')
                                              : NetworkImage(
                                                  Host+this.listUser[index].avatar),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(this.listUser[index].name,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500)),

                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ):Container(child: NoDataScreen(title:"Bạn chưa chat với ai cả",content:"Hãy lựa chọn một người và bắt đầu trò chuyện",urlImage: "assets/images/conversation.png",),)
                ],
              )))
            );
  }
}

Widget _Loading() {
  return SingleChildScrollView(
    child: Column(
      children: [
        for (int i = 0; i < 5; i++)
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
  );
}
