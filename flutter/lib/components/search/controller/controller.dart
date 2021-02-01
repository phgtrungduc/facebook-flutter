import 'dart:convert';

import 'package:facebook/api/api.dart';
import 'package:facebook/components/search/model/search.dart';
import 'package:facebook/model/PostModel.dart';
import 'package:flutter/cupertino.dart';

class SearchController with ChangeNotifier {
  /// Singleton Factory
  factory SearchController() {
    if (_this == null) _this = SearchController._();
    return _this;
  }

  static SearchController _this;

  SearchController._();

  /// Allow for easy access to 'the Controller' throughout the application.
  static SearchController get con => _this;

  List<SearchInfo> searchHistory = [];

  List<UserResult> userResult = [];

  List<PostModel> postResult = [];

  Future<dynamic> getSearchHistory({count, index}) async {
    if (count == null) {
      count = 20;
    }
    if (index == null) {
      index = 0;
    }
    API api = new API();
    try {
      bool status = false;
      await api.getHistorySearch(index: index, count: count).then((res) {
        var response = json.decode(res.body);
        if (response['code'] == 1000) {
          // print(response);
          if (index == 0) {
            searchHistory.clear();
          }
          for (int i = 0; i < response['data'].length; i++) {
            var item = response['data'][i];
            searchHistory.add(SearchInfo(item['keyword'], item['search_id']));
          }
          status = true;
        }
      });
      if (status) {
        return 1;
      } else {
        return 0;
      }
    } on Exception {
      return -1;
    }
  }

  Future<dynamic> delSearchHistory({searchId, all}) async {
    if (searchId == null && all == null) {
      return 0;
    }
    if (all == null) {
      all = 0;
    }
    API api = new API();
    try {
      bool status = false;
      await api.delHistorySearch(searchId: searchId, all: all).then((res) {
        var response = json.decode(res.body);
        if (response['code'] == 1000) {
          // searchHistory.
          if (all == 0) {
            searchHistory.removeWhere((item) => item.searchId == searchId);
          } else {
            searchHistory.clear();
          }
          status = true;
          notifyListeners();
        }
      });
      if (status) {
        return 1;
      } else {
        return 0;
      }
    } on Exception {
      return -1;
    }
  }

  Future<dynamic> searchUserHome(String keyword, {count, index}) async {
    if (count == null) {
      count = 100;
    }
    if (index == null) {
      index = 0;
    }
    API api = new API();
    try {
      bool status = false;
      await api.searchUserHome(keyword, count, index).then((res) {
        var response = json.decode(res.body);
        if (response['code'] == 1000) {
          if (index == 0) {
            userResult.clear();
          }
          for (int i = 0; i < response['data'].length; i++) {
            var item = response['data'][i]['info'];
            userResult.add(UserResult(item));
          }
          status = true;
        }
      });
      if (status) {
        return userResult;
      } else {
        return 0;
      }
    } on Exception {
      return -1;
    }
  }

  Future<dynamic> searchPostHome(String keyword, {count, index}) async {
    if (count == null) {
      count = 100;
    }
    if (index == null) {
      index = 0;
    }
    API api = new API();
    try {
      bool status = false;
      await api.searchPostHome(keyword, count, index).then((res) {
        var response = json.decode(res.body);
        if (response['code'] == 1000) {
          if (index == 0) {
            postResult.clear();
          }
          jsonDecode(res.body)["data"].forEach((element) {
            PostModel postModel = PostModel.fromJson(element);
            postResult.add(postModel);
          });
          status = true;
        }
      });
      if (status) {
        return postResult;
      } else {
        return 0;
      }
    } on Exception {
      return -1;
    }
  }

  void dispose() {
    searchHistory = [];
    userResult = [];
    postResult = [];
  }
}
