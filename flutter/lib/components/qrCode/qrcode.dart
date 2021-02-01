import 'package:facebook/activation/Sheet/bottom/bottomSheet.dart';
import 'package:facebook/components/UserWallInfor/userProfile.dart';
import 'package:facebook/components/animationRouteClass/ScaleAnimation.dart';
import 'package:facebook/components/animationRouteClass/SlideAnimation.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';

class QRcodeOptions extends StatefulWidget {
  @override
  _QRcodeOptionsState createState() => _QRcodeOptionsState();
}

class _QRcodeOptionsState extends State<QRcodeOptions> {
  String userId = '';
  String resultOfQrCode = "";

  _scan() async {
    ///mau` cua ma qrcode
    ///ten cua? nut' cancel
    ///co' su? dung den` hay khong
    ///quet' ma qr hay bar code
    ///qrcode or barcode
    await FlutterBarcodeScanner.scanBarcode(
            '#ff000000', 'Hủy', true, ScanMode.QR)
        .then((value) {
      var tmp = value.split(" ");
      setState(() {
        this.resultOfQrCode = tmp[tmp.length - 1];
      });
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(shape: BoxShape.circle, color: GreyIcon),
      child: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.qrcode,
          color: BlackColor,
          size: 20,
        ),
        onPressed: () {
          showSlideBottomSheet(
            context,
            listOptions: [
              singleOption(
                'Quét mã QR để kết bạn',
                context: context,
                iconOption: Icons.code,
                callbackFunction: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  this.userId = prefs.getString("id_icre");
                  Navigator.pop(context);
                  await _scan();
                  if (this.resultOfQrCode == '-1') return;
                  bool isOwner = this.resultOfQrCode == this.userId;
                  Navigator.push(
                    context,
                    SlideRightToLeftRoute(
                      page: UserWall(
                        userId: this.resultOfQrCode,
                        isOwner: isOwner,
                      ),
                    ),
                  );
                },
              ),
              singleOption(
                'Hiển thị mã QR của riêng bạn',
                context: context,
                iconOption: FontAwesomeIcons.qrcode,
                callbackFunction: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  this.userId = prefs.getString("id_icre");
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    ScaleAnimationRoute(
                      page: GenerateQrCode(
                        userId: 'Your_id_facebook_is ${this.userId}',
                      ),
                    ),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}

class GenerateQrCode extends StatelessWidget {
  final String userId;

  const GenerateQrCode({Key key, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFFFF),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Center(
          child: (userId == "" || userId == null)
              ? Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      'Có gì đó sai sai, bạn hãy kiểm tra kết nối rồi thử lại sau.\nChúng tôi xin lỗi vì sự bất tiện này.'),
                )
              : Container(
                  child: QrImage(data: userId),
                ),
        ),
      ),
    );
  }
}
