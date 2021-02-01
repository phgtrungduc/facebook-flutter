import 'package:facebook/components/homepage/post/post.dart';
import 'package:facebook/const/const.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImagesPost extends StatelessWidget {
  PostModel postModel;
  ImagesPost({this.postModel});
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: GreyBackgroud,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: Container(
                    color: WhiteColor,
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        PostHeader(
                          name: this.postModel.author.name,
                          avatar: this.postModel.author.avatar,
                          status: this.postModel.status,
                          created_at: this.postModel.created_at,
                          isOwn: false,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(this.postModel.described,style: TextStyle(fontSize: 17),),

                      ],
                    ),
                  )

              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  //Post post = post[index]; dung lam tham so truyen vao cac PostTimeLine
                  return Column(children: [
                      SizedBox(height: 5,),
                      SingleImage(this.postModel.images[index]),
                      SizedBox(height: 5,)
                    ],
                  ); //Truyen tham so vao day
                }, childCount: this.postModel.images.length),
              )
            ],
          ),
        ),
      ),
    );
  }
}
Widget SingleImage(String url){
  return Container(
    padding: EdgeInsets.symmetric(vertical: 22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: WhiteColor,
    ),
    child: Image.network(Host+url),
  );
}