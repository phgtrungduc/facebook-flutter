import 'package:facebook/model/UserInfor.dart';

class PostModel {
  int like;
  int comment;
  List<dynamic> images;
  bool is_liked;
  List<dynamic> video;
  String status;
  bool modified;
  String id;
  UserChatInfor author;
  DateTime created_at;
  String described;
  PostModel(
      {this.like,
      this.comment,
      this.images,
      this.is_liked,
      this.video,
        this.status,
      this.modified,
      this.id,this.author,this.created_at,this.described});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        like: json['like'],
        comment: json['comment'],
        images: json['images'],
        is_liked: json['is_liked'],
        video: json['video'],
        status : json['status'],
        modified: json['modified'],
        id: json['id'].toString(),
        author: UserChatInfor.fromJson(json["author"]),
        created_at:DateTime.parse(json["created_at"]),
        described:json["described"]);
  }
}

class SingleChat {
  String user;
  String mess;
  SingleChat({this.mess, this.user});
}
