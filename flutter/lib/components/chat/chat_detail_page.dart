import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/model/UserInfor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailPage extends StatefulWidget {
  String ownId;
  UserChatInfor friendChatInfor;
  ChatDetailPage({Key key,this.ownId ,this.friendChatInfor})
      : super(key: key);
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>{
  String mess;
  UserChatInfor ownChatInfor;
  final FocusNode _focusMess = new FocusNode();
  final ScrollController _scrollController = new ScrollController();
  final TextEditingController _sendMessageController =
      new TextEditingController();
  // final  CollectionReference collectionReference;
  var messages = null;
  bool canSend=false;

  bool isLoading=true;
  String chatId;
  void _getOwnInfor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ownChatInfor =
          UserChatInfor.fromJson(json.decode(prefs.getString("information")));
    });
  }

  // void _onFocusChange() {
  //   print("Focus: " + _focusMess.hasFocus.toString());
  // }
  //
  // bool hasKeyBoard() {
  //   return (MediaQuery.of(context).viewInsets.bottom == 0);
  // }

  void initState() {
    super.initState();
    _getOwnInfor();
    Firebase.initializeApp().whenComplete(() {
      FirebaseFirestore.instance
          .collection("chats")
          .where(
        "users", arrayContainsAny: [widget.ownId, widget.friendChatInfor.idMongo],)
          .get().then((res) {
        if (res.docs.length > 0) {
          print("da co");
          setState(() {
            chatId = res.docs[0].reference.id;
          });
          FirebaseFirestore.instance
              .collection("chats")
              .where(
            "users", arrayContainsAny: [widget.ownId, widget.friendChatInfor.idMongo],)
              .snapshots()
              .listen((event) {
            if (mounted) {
              setState(() {
                messages = event.docs[0].data()["listchat"];
                isLoading = false;
              });
            }
          });
        } else {

          print("chua co");
          CollectionReference chatRef = FirebaseFirestore.instance
              .collection("chats");
          String newId = chatRef
              .doc()
              .id;
          setState(() {
            chatId = newId;
          });
          Map<String, dynamic> data = new Map();
          data["users"] = [widget.ownId, widget.friendChatInfor.idMongo];
          data["last_edit"] = FieldValue.serverTimestamp();
          data["listchat"] = [];
          chatRef.doc(newId).set(data);
          chatRef.doc(newId).snapshots().listen((event) {
            if (mounted){
              setState(() {
                messages = event.data()!=null&&event.data().length>0?event.data()["listchat"]:[];
                isLoading = false;
              });
            }
          });

        }
      });
    });

    // _focusMess.addListener(_onFocusChange);
    _sendMessageController.addListener(() {
      if (_sendMessageController.text!=null&&_sendMessageController.text.trim()!=""){
        setState(() {
          canSend = true;
        });
      }else {
        setState(() {
          canSend = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusMess.dispose();
    super.dispose();
  }

  void addMessage(String message) {
    List<dynamic> listchat = this.messages;
    listchat.add(
        <String, dynamic>{"mess": message, "user_send": this.ownChatInfor.idMongo});

    FirebaseFirestore.instance.collection("chats").doc(this.chatId)
        .update(
      {"listchat": listchat, "last_edit": FieldValue.serverTimestamp()},
    ).catchError((e) {
      print(e.toString());
    });
  }

  dynamic getAvatar(String avatar) {
    if (avatar == null) {
      return AssetImage('assets/images/avatar_placeholder.png');
    } else {
      return NetworkImage(Host+avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (this.messages != null&&this.isLoading==false)
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
    return Material(
      child: Scaffold(
        backgroundColor: WhiteColor,
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 1,
          leading: FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: primaryChat,
              )),
          title: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: this.getAvatar(widget.friendChatInfor.avatar),
                        fit: BoxFit.cover)),
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.friendChatInfor.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: BlackColor),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                ],
              )
            ],
          ),
        ),
        body: !this.isLoading?Column(
          children: [
            this.messages != null
                ? Expanded(
                    child: ListView(
                    padding: EdgeInsets.all(10),
                    controller: _scrollController,
                    children: List.generate(this.messages.length, (index) {
                      if (this.messages[index]["user_send"] ==
                          this.ownChatInfor.idMongo) {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 1),
                          child: ChatBubble(
                              isMe: true, //messages[index]['isMe']
                              messageType: 4,
                              message: this.messages[index]['mess'],
                              profileImg: this
                                  .getAvatar(widget.friendChatInfor.avatar)),
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 1),
                          child: ChatBubble(
                              isMe: false, //messages[index]['isMe']
                              messageType: 4,
                              message: this.messages[index]['mess'],
                              profileImg: this
                                  .getAvatar(widget.friendChatInfor.avatar)),
                        );
                      }
                    }),
                  ))
                : SizedBox(height: double.infinity,),
            Container(
              decoration: BoxDecoration(color: WhiteColor),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 20, right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: size.width - 90,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: greyChat,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: TextField(
                                  onTap: () {
                                    MediaQuery.of(context).size;
                                    if (this.messages != null&&this.isLoading==false) _scrollController.jumpTo(_scrollController
                                        .position.maxScrollExtent);
                                  },
                                  focusNode: _focusMess,
                                  cursorColor: BlackColor,
                                  controller: _sendMessageController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Aa",
                                      suffixIcon: Icon(
                                        Icons.face,
                                        color: primaryChat,
                                        size: 35,
                                      )),
                                ),
                              ),
                            ),
                            IconButton(
                                    icon: FaIcon(FontAwesomeIcons.solidPaperPlane,size: 35, color: canSend?primaryChat:GreyTimeAndIcon),
                                    onPressed: canSend?() {
                                      print(widget.ownId);
                                      print(widget.friendChatInfor.idMongo);
                                      this.addMessage(
                                          _sendMessageController.text.trim());
                                      _sendMessageController.text = "";
                                    }:null,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ):Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final dynamic profileImg;
  final String message;
  final int messageType;
  const ChatBubble({
    Key key,
    this.isMe,
    this.profileImg,
    this.message,
    this.messageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: primaryChat,
                    borderRadius: getMessageType(messageType)),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text(
                    message,
                    style: TextStyle(color: WhiteColor, fontSize: 17),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(1.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: profileImg)),
            ),
            SizedBox(
              width: 15,
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: greyChat, borderRadius: getMessageType(messageType)),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text(
                    message,
                    style: TextStyle(color: BlackColor, fontSize: 17),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  getMessageType(messageType) {
    if (isMe) {
      // start message
      if (messageType == 1) {
        return BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // middle message
      else if (messageType == 2) {
        return BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // end message
      else if (messageType == 3) {
        return BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(30),
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30));
      }
      // standalone message
      else {
        return BorderRadius.all(Radius.circular(30));
      }
    }
    // for sender bubble
    else {
      // start message
      if (messageType == 1) {
        return BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // middle message
      else if (messageType == 2) {
        return BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // end message
      else if (messageType == 3) {
        return BorderRadius.only(
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30));
      }
      // standalone message
      else {
        return BorderRadius.all(Radius.circular(30));
      }
    }
  }
}
