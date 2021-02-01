import 'package:facebook/const/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class NoDataScreen extends StatelessWidget {
  String userId;
  String title = "Không tìm thấy dữ liệu";
  String content;
  String urlImage;
  Future<void> emitParent;
  NoDataScreen(
      {key,
      this.title,
      this.content,
      this.urlImage,
      this.emitParent,
      this.userId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(bottom: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (urlImage != null)
              Center(
                child: Image.asset(urlImage),
              ),
            Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  color: BlackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (this.content != null)
              Padding(
                padding: const EdgeInsets.only(right: 25.0, left: 25.0),
                child: Center(
                  child: Text(
                    this.content,
                    style: TextStyle(
                      color: BlackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            if (this.emitParent != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async => this.emitParent,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 3.0, left: 3.0),
                  ),
                  Text(
                    'Nhấn để thử lại',
                    style: TextStyle(
                      color: BlackColor,
                      fontSize: 16,
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
