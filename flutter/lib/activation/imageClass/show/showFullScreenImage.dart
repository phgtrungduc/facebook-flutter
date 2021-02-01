import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class ShowFullImage extends StatelessWidget {
  String linkImage = '';

  ShowFullImage({Key key, this.linkImage}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Color(0xFFFFFFFF),
        ),
      ),
      backgroundColor: Color(0xFF000000),
      extendBodyBehindAppBar: true,
      body: Container(
        child: (this.linkImage != '')
            ? Image.network(
                linkImage,
                fit: BoxFit.contain,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              )
            : Center(
              child: Text('Đã xảy ra lỗi gì đó :(('),
            ),
      ),
    );
  }
}
