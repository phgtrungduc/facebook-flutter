class CommentModel{
  String comment;
  DateTime created_at;

  CommentModel({this.comment,this.created_at});

  factory CommentModel.fromJson(Map<String, dynamic> json){
    return CommentModel(
        comment:json["comment"],
        created_at:DateTime.parse(json["created_at"])
    );
  }
}