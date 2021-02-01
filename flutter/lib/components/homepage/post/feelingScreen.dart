import 'package:facebook/const/const.dart';
import 'package:facebook/const/feelingInNewPost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef void SetFeeling(FeelingInNewPost newFeeling);
typedef void CancelFeeling();

class FeelingScreen extends StatefulWidget {
  final SetFeeling setFeeling;
  final CancelFeeling cancelFeeling;
  final FeelingInNewPost nowFeeling;
  FeelingScreen(
      {@required this.setFeeling,
      @required this.cancelFeeling,
      this.nowFeeling});
  @override
  _FeelingScreenState createState() => _FeelingScreenState();
}

class _FeelingScreenState extends State<FeelingScreen> {
  final TextEditingController _inputController = new TextEditingController();
  FeelingInNewPost nowFeeling;
  List<FeelingInNewPost> _listFeeling;
  SetFeeling setFeeling;
  CancelFeeling cancelFeeling;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setFeeling = widget.setFeeling;
    cancelFeeling = widget.cancelFeeling;
    nowFeeling = widget.nowFeeling;
    _listFeeling = listFeelingInNewPost;
    _inputController.addListener(findFeeling);
  }

  void findFeeling() {
    String text = _inputController.text;
    if (text.trim() == "" || text.trim() == null) {
      setState(() {
        _listFeeling = listFeelingInNewPost;
      });
    } else {
      List<FeelingInNewPost> temp = new List<FeelingInNewPost>();
      for (int i = 0; i < listFeelingInNewPost.length; i++) {
        if (listFeelingInNewPost[i].feeling.contains(text.trim()))
          temp.add(listFeelingInNewPost[i]);
      }
      setState(() {
        _listFeeling = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          title: Text("Bạn đang cảm thấy thế nào?"),
        ),
        body: Column(
          children: [
            this.nowFeeling == null
                ? Container(
                    decoration: BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: GreyTimeAndIcon))),
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm",
                        icon: Icon(
                          Icons.search,
                          color: GreyFontColor,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  )
                : Container(
                decoration: BoxDecoration(
                    border:
                    Border(bottom: BorderSide(color: GreyTimeAndIcon))),
                    child: ListTile(
                    leading: FaIcon(
                      this.nowFeeling.icon,
                      size: 35,
                      color: Colors.amber,
                    ),
                    title: Text("Đang cảm thấy "+this.nowFeeling.feeling,
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      trailing: IconButton(
                        icon: Icon(Icons.close,color: BlackColor,),
                        onPressed: (){
                          setState(() {
                            nowFeeling=null;
                          });
                          this.cancelFeeling();
                        },
                      ),
                  ),
            ),
            _listFeeling != null
                ? Expanded(
                    child: GridView.count(
                      childAspectRatio: 3.5,
                      crossAxisCount: 2,
                      children: List.generate(_listFeeling.length, (index) {
                        return Container(
                          padding: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: GreyTimeAndIcon),
                                  right: index % 2 == 0
                                      ? BorderSide(color: GreyTimeAndIcon)
                                      : BorderSide.none)),
                          height: 50,
                          child: GestureDetector(
                            onTap: () {
                              this.setFeeling(_listFeeling[index]);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  _listFeeling[index].icon,
                                  size: 35,
                                  color: Colors.amber,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  _listFeeling[index].feeling,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  )
                : Text("Xin lỗi không có gì để hiển thị")
          ],
        ));
  }
}
