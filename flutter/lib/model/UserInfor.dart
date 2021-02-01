class UserChatInfor{
  String idMongo;
  String name;
  String avatar;
  String chatId;
  String id;

  UserChatInfor({this.name,this.avatar,this.idMongo,this.id});

  factory UserChatInfor.fromJson(Map<String, dynamic> json){
    return UserChatInfor(
      name:json['name'],
      avatar: json['avatar'],
        idMongo:json['_id'],
      id:json['id'].toString()
    );
  }
}
class SingleChat{
  String user;
  String mess;
  SingleChat({this.mess,this.user});
}