import 'package:facebook/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:search_widget/search_widget.dart';

class EditAddressPane2 extends StatefulWidget {
  @override
  _EditAddressPane2State createState() => _EditAddressPane2State();
}

class _EditAddressPane2State extends State<EditAddressPane2> {
  List<LeaderBoard> list = <LeaderBoard>[
    LeaderBoard("An Giang"),
    LeaderBoard("Bà Rịa-Vũng Tàu"),
    LeaderBoard("Bạc Liêu"),
    LeaderBoard("Bắc Kạn"),
    LeaderBoard("Bắc Giang"),
    LeaderBoard("Bắc Ninh"),
    LeaderBoard("Bến Tre"),
    LeaderBoard("Bình Dương"),
    LeaderBoard("Bình Định"),
    LeaderBoard("Bình Phước"),
    LeaderBoard("Bình Thuận"),
    LeaderBoard("Cà Mau"),
    LeaderBoard("Cao Bằng"),
    LeaderBoard("Cần Thơ"),
    LeaderBoard("Đà Nẵng"),
    LeaderBoard("Đắk Lắk"),
    LeaderBoard("Đắk Nông"),
    LeaderBoard("Điện Biên"),
    LeaderBoard("Đồng Nai"),
    LeaderBoard("Đồng Tháp"),
    LeaderBoard("Gia Lai"),
    LeaderBoard("Hà Giang"),
    LeaderBoard("Hà Nam"),
    LeaderBoard("Hà Nội"),
    LeaderBoard("Hà Tây"),
    LeaderBoard("Hà Tĩnh"),
    LeaderBoard("Hải Dương"),
    LeaderBoard("Hải Phòng"),
    LeaderBoard("Hòa Bình"),
    LeaderBoard("Hồ Chí Minh"),
    LeaderBoard("Hậu Giang"),
    LeaderBoard("Hưng Yên"),
    LeaderBoard("Khánh Hòa"),
    LeaderBoard("Kiên Giang"),
    LeaderBoard("Kon Tum"),
    LeaderBoard("Lai Châu"),
    LeaderBoard("Lào Cai"),
    LeaderBoard("Lạng Sơn"),
    LeaderBoard("Lâm Đồng"),
    LeaderBoard("Long An"),
    LeaderBoard("Nam Định"),
    LeaderBoard("Nghệ An"),
    LeaderBoard("Ninh Bình"),
    LeaderBoard("Ninh Thuận"),
    LeaderBoard("Phú Thọ"),
    LeaderBoard("Phú Yên"),
    LeaderBoard("Quảng Bình"),
    LeaderBoard("Quảng Nam"),
    LeaderBoard("Quảng Ngãi"),
    LeaderBoard("Quảng Ninh"),
    LeaderBoard("Quảng Trị"),
    LeaderBoard("Sóc Trăng"),
    LeaderBoard("Sơn La"),
    LeaderBoard("Tây Ninh"),
    LeaderBoard("Thái Bình"),
    LeaderBoard("Thái Nguyên"),
    LeaderBoard("Thanh Hóa"),
    LeaderBoard("Thừa Thiên – Huế"),
    LeaderBoard("Tiền Giang"),
    LeaderBoard("Trà Vinh"),
    LeaderBoard("Tuyên Quang"),
    LeaderBoard("Vĩnh Long"),
    LeaderBoard("Vĩnh Phúc"),
    LeaderBoard("Yên Bái"),
  ];

  LeaderBoard _selectedItem;

  bool _show = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm kiếm địa chỉ',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 0.4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            if (_show)
              SearchWidget<LeaderBoard>(
                dataList: list,
                hideSearchBoxWhenItemSelected: false,
                listContainerHeight: MediaQuery.of(context).size.height / 4,
                queryBuilder: (query, list) {
                  return list
                      .where((item) => item.username
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                },
                popupListItemBuilder: (item) {
                  return PopupListItemWidget(item);
                },
                selectedItemBuilder: (selectedItem, deleteSelectedItem) {
                  return SelectedItemWidget(selectedItem, deleteSelectedItem);
                },
                // widget customization
                noItemsFoundWidget: NoItemsFound(),
                textFieldBuilder: (controller, focusNode) {
                  return MyTextField(controller, focusNode);
                },
                onItemSelected: (item) {
                  _selectItem(item.username, context);
                  print("đã bắn giá trị " + item.username + " sang màn kia !");
                  // Navigator.pop(context);
                  setState(() {
                    _selectedItem = item;
                  });
                },
              ),
            const SizedBox(
              height: 32,
            ),
            Text(
              "${_selectedItem != null ? _selectedItem.username : ""
                  "Chưa chọn địa chỉ nào"}",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _show = !_show;
          });
        },
        child: Icon(Icons.swap_horizontal_circle),
      ),
    );
  }

  void _selectItem(String value, BuildContext context) {
    Navigator.of(context).pop({'selection': value});
  }
}

class LeaderBoard {
  LeaderBoard(this.username);

  final String username;
}

class SelectedItemWidget extends StatelessWidget {
  const SelectedItemWidget(this.selectedItem, this.deleteSelectedItem);

  final LeaderBoard selectedItem;
  final VoidCallback deleteSelectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 4,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              child: Text(
                selectedItem.username,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 22),
            color: Colors.grey[700],
            onPressed: deleteSelectedItem,
          ),
        ],
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  const MyTextField(this.controller, this.focusNode);

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0x4437474F),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          suffixIcon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: "Tìm kiếm ở đây ...",
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            bottom: 14,
          ),
        ),
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.folder_open,
          size: 24,
          color: Colors.grey[900].withOpacity(0.7),
        ),
        const SizedBox(width: 10),
        Text(
          "Không tìm thấy địa chỉ",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[900].withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class PopupListItemWidget extends StatelessWidget {
  const PopupListItemWidget(this.item);

  final LeaderBoard item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        item.username,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
