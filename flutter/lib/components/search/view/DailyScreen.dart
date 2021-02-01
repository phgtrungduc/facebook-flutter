import 'package:connectivity/connectivity.dart';
import 'package:facebook/components/notifyComponents/notifyScreen.dart';
import 'package:facebook/components/search/controller/controller.dart';
import 'package:facebook/const/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class DailyScreen extends StatefulWidget {
  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;
  int count = 20;

  bool isLoading = false;
  bool hasData = false;
  bool isLoadingMore = false;
  bool internet = true;

  ScrollController _scrollController;
  final _searchController = SearchController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          if (_searchController.searchHistory.length == 0) {
            this.hasData = false;
          }
        });
      }
    });
    _scrollController = ScrollController()..addListener(_loadMore);
    this.getHistorySearch(count: this.count, index: this.index);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  _loadMore() {
    if (isLoadingMore) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (mounted) {
        setState(() {
          this.isLoadingMore = true;
        });
      }
      this.count = _searchController.searchHistory.length + 20;
      this.index = _searchController.searchHistory.length;
      this.getHistorySearch(
          count: this.count, index: this.index, loadmore: true);
      setState(() {
        this.isLoadingMore = false;
      });
    }
  }

  Future<void> hasInternet() async {
    print('checking');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        this.internet = false;
      });
    } else {
      if (mounted) {
        setState(() {
          this.internet = true;
        });
      }
    }
    return;
  }

  Future<dynamic> getHistorySearch(
      {count = 20, index = 0, loadmore = false}) async {
    await this.hasInternet();
    if (this.internet == false) return;
    if (mounted && !loadmore) {
      setState(() {
        isLoading = true;
      });
    }
    print('total len result: $count');
    var res =
        await _searchController.getSearchHistory(count: count, index: index);
    // print(res);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    if (res == -1 || res == 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Kết nối mạng không ổn định hoặc server không phản hồi'),
        duration: Duration(seconds: 5),
      ));
      return;
    }
    if (_searchController.searchHistory.length != 0) {
      setState(() {
        this.hasData = true;
      });
    }
    // print(listSearchHistory);
  }

  Future<dynamic> delHistorySearch({searchId, all}) async {
    this._showLoadingAjax();
    var res =
        await _searchController.delSearchHistory(searchId: searchId, all: all);
    Navigator.of(context).pop();
    if (res == -1 || res == 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Kết nối mạng không ổn định hoặc server không phản hồi'),
        duration: Duration(seconds: 5),
      ));
      return;
    }
  }

  Future<void> _showLoadingAjax() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          children: [
            Image.asset(PopupLoading),
          ],
        );
      },
    );
  }

  void _onRefresh() async {
    await this.getHistorySearch(count: 20, index: 0);
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // await this.getUserInfo(widget.userId);
    // // if failed,use loadFailed(),if no data return,use LoadNodata()
    // if (mounted) setState(() {});
    // _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      header: MaterialClassicHeader(
        distance: 30.0,
        color: CircularColor,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: WhiteColor,
        appBar: AppBar(
          title: Text('Nhật kí hoạt động'),
          elevation: 0.8,
        ),
        body: this.internet
            ? !isLoading
                ? ListView(controller: _scrollController, children: [
                    ListTile(
                      title: Center(
                        child: GestureDetector(
                          onTap: hasData
                              ? () {
                                  this.delHistorySearch(all: 1);
                                }
                              : null,
                          child: hasData
                              ? Text(
                                  'Xóa tất cả các tìm kiếm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: blue_story,
                                  ),
                                )
                              : Text(
                                  '.',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: GreyFontColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Divider(
                      color: GreyFontColor.withOpacity(0.3),
                      height: 1,
                      indent: 15,
                      endIndent: 15,
                      thickness: 1,
                    ),
                    for (var item in _searchController.searchHistory)
                      oneSearch(item.content, item.searchId),
                    if (this.isLoadingMore)
                      Container(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('đang tải...'),
                          ),
                        ),
                      )
                  ])
                : ListView(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Column(
                        children: [
                          for (int i = 0; i < 5; i++)
                            Shimmer.fromColors(
                              baseColor: BaseColor,
                              highlightColor: HighlightColor,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: BaseColor,
                                ),
                                title: Container(
                                  height: 20,
                                  color: BaseColor,
                                ),
                                subtitle: Container(
                                  height: 12,
                                  color: BaseColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ])
            : NoDataScreen(
                title: 'Không có kết nối mạng',
                content: 'Hãy kiểm tra lại đường truyền và thử lại sau',
                emitParent:
                    this.getHistorySearch(count: this.count, index: this.index),
              ),
      ),
    );
  }

  ListTile oneSearch(String content, int searchId) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: blue_story,
        child: Icon(
          Icons.search,
          size: 28,
          color: WhiteColor,
        ),
      ),
      title: Text(
        'Bạn đã tìm kiếm trên facebook',
        style: TextStyle(
          color: BlackColor,
          fontSize: 18,
        ),
      ),
      isThreeLine: true,
      subtitle: Wrap(
        children: [
          Text("'$content'"),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.close,
          size: 20,
          color: Color(0xFF757575),
        ),
        onPressed: () {
          this.delHistorySearch(searchId: searchId, all: 0);
        },
      ),
    );
  }
}
