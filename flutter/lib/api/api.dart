import 'dart:async';
import 'dart:convert';
import 'package:facebook/const/const.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class API {
  // 10.0.2.2
  String host = '$Host'; //http://10.0.2.2:3001/
  final storage = new FlutterSecureStorage();
  Future<http.Response> registerAPI(String phoneNumber, String password) async {
    return await http.post(
      host + 'signup',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, dynamic>{"phone": phoneNumber, "password": password}),
    );
  }

  Future<http.Response> signUp(String phoneNumber, String password, String name,
      DateTime birthday) async {
    return await http.post(
      host + 'signup',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "phone": phoneNumber,
        "password": password,
        "name": name,
        "birthday": birthday.toString()
      }),
    );
  }

  Future<http.Response> logIn(String phone, String password) async {
    print("login");
    return await http
        .post(
          host + "login",
          headers: <String, String>{
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            "phone": phone,
            "password": password,
          }),
        )
        .timeout(Duration(seconds: 30));
  }

  Future<http.Response> getMyListPosts(
      String userId, int count, int index) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
      host + "get_my_list_posts?user_id=$userId&count=$count&index=$index",
      headers: <String, String>{
        "Accept": "application/json",
        'Content-Type': 'application/json; charset=UTF-8',
        'accessToken': token
      },
    );
  }

  Future<http.Response> getListNotifications(int index, int count) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
      host + "get_list_notify?count=$count&index=$index",
      headers: <String, String>{
        "Accept": "application/json",
        'Content-Type': 'application/json; charset=UTF-8',
        'accessToken': token
      },
    );
  }

  Future<http.Response> getListPost() async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
      host + "get_list_posts",
      headers: <String, String>{
        "Accept": "application/json",
        'Content-Type': 'application/json; charset=UTF-8',
        'accessToken': token
      },
    );
  }

  Future<http.Response> getComment(String id) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
      host + "get_comment?id=" + id,
      headers: <String, String>{
        "Accept": "application/json",
        'Content-Type': 'application/json; charset=UTF-8',
        'accessToken': token
      },
    );
  }

  Future<http.Response> userInfor(String id) async {
    return await http.post(host + 'info_user',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": id,
        }));
  }

  Future<http.Response> set_comment(String id, String comment) async {
    String token = await storage.read(key: "acessToken");
    return await http.post(
      host + "set_comment",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accessToken': token
      },
      body: jsonEncode(<String, dynamic>{
        "id": id,
        "comment": comment,
      }),
    );
  }

  Future<http.Response> like(String id) async {
    String token = await storage.read(key: "acessToken");
    return await http.post(
      host + "like",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accessToken': token
      },
      body: jsonEncode(<String, dynamic>{
        "id": id,
      }),
    );
  }

  Future<http.Response> delete_post(String id) async {
    String token = await storage.read(key: "acessToken");
    return await http.post(
      host + "delete_post",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accessToken': token
      },
      body: jsonEncode(<String, dynamic>{
        "id": id,
      }),
    );
  }

  Future<http.Response> getPost(String id) async {
    return await http.get(
      host + "get_post?id=" + id,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  Future<String> uploadData(String data) async {
    String token = await storage.read(key: "acessToken");
    var headers = {'accessToken': token};
    var request =
        http.MultipartRequest('POST', Uri.parse(host + 'upload_data'));
    request.files.add(await http.MultipartFile.fromPath('data', data));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    return res;
  }

  Future<http.Response> getUserInfor(String id) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(host + 'get_user_info?user_id=$id',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> editPost(String postId, String described,
      List<String> images, String status) async {
    String token = await storage.read(key: "acessToken");
    return await http.post(host + 'edit_post',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        },
        body: jsonEncode(<String, dynamic>{
          "post_id": postId,
          "described": described,
          "images": images,
          "status": status
        }));
  }

  Future<http.Response> reportPost(String postId) async {
    String token = await storage.read(key: "acessToken");
    return await http.post(host + 'report_post',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        },
        body: jsonEncode(<String, dynamic>{
          "id": postId,
        }));
  }

  Future<http.Response> getUserFriends(int index, int count, {userId}) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
        host + 'get_user_friends?index=$index&count=$count&user_id=$userId',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> getListVideos(int index, int count) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(host + 'get_list_videos?index=$index&count=$count',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.StreamedResponse> setAvatar(String imgPath) async {
    String token = await storage.read(key: "acessToken");
    var headers = {'accessToken': token};
    var request = http.MultipartRequest('POST', Uri.parse(host + 'set_avatar'));
    request.files.add(await http.MultipartFile.fromPath('avatar', imgPath));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    return response;
  }

  Future<http.StreamedResponse> setCover(String imgPath) async {
    String token = await storage.read(key: "acessToken");
    var headers = {'accessToken': token};
    var request = http.MultipartRequest('POST', Uri.parse(host + 'set_cover'));
    request.files.add(await http.MultipartFile.fromPath('cover', imgPath));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    return response;
  }

  Future<http.Response> setRequestFriend(String userId) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.post(
        host + 'set_request_friend',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body: jsonEncode(<String, dynamic>{"user_id": userId}),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> delRequestFriend(String userId) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.get(host + 'del_request_friend?user_id=$userId',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "accessToken": token
          });
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> searchUserFriend(
      String userId, String keyword, int count, int index) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.get(
          host +
              'search_user?user_id=$userId&keyword=$keyword&index=$index&count=$count',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "accessToken": token
          });
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> searchUserHome(
      String keyword, int count, int index) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.get(
          host + 'search_user_home?keyword=$keyword&index=$index&count=$count',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "accessToken": token
          });
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> searchPostHome(
      String keyword, int count, int index) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.get(
          host + 'search_post_home?keyword=$keyword&index=$index&count=$count',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "accessToken": token
          });
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> unfriend(String userId) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.get(host + 'unfriend?id=$userId',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "accessToken": token
          });
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> getHistorySearch({count = 10, index = 0}) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(host + 'get_saved_search?count=$count&index=$index',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> getPostOfUser(String userId, String keyword,
      {count = 100, index = 0}) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
        host +
            'search_post?user_id=$userId&keyword=$keyword&count=$count&index=$index',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> getSearch(String keyword,
      {count = 100, index = 0}) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
        host + 'search?keyword=$keyword&count=$count&index=$index',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> delHistorySearch({searchId, all}) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.post(
        host + 'del_saved_search',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body: jsonEncode(<String, dynamic>{"search_id": searchId, "all": all}),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> getRequestedFriends(int index, int count) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(
        host + 'get_requested_friends?index=$index&count=$count',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> setAcceptFriend(int idUser, int isAccept) async {
    String token = await storage.read(key: "acessToken");
    try {
      return await http.post(
        host + 'set_accept_friend',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": idUser,
          "is_accept": isAccept,
        }),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
  }

  Future<http.Response> setBlock(int idUser) async {
    String token = await storage.read(key: "acessToken");
    try {
      return await http.post(
        host + 'set_block',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": idUser,
        }),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
  }

  Future<http.Response> setUnBlock(int idUser) async {
    String token = await storage.read(key: "acessToken");
    try {
      return await http.post(
        host + 'set_unblock',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": idUser,
        }),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
  }

  Future<http.Response> getSuggestFriends() async {
    String token = await storage.read(key: "acessToken");
    return await http.get(host + 'get_list_suggested_friends',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> editAddress(String address) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.post(
        host + 'edit_address',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body: jsonEncode(<String, dynamic>{"address": address}),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> editName(String name) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http
          .post(
            host + 'edit_name',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              "accessToken": token
            },
            body: jsonEncode(<String, dynamic>{"name": name}),
          )
          .timeout(Duration(seconds: 5));
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> changePassword(String oldPass, String newPass) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http
          .post(
            host + 'change_password',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              "accessToken": token
            },
            body: jsonEncode(<String, dynamic>{
              "password": oldPass,
              "new_password": newPass
            }),
          )
          .timeout(Duration(seconds: 5));
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> getListBlocks(int index, int count) async {
    String token = await storage.read(key: "acessToken");
    return await http.get(host + 'get_list_blocks?index=$index&count=$count',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accessToken': token
        });
  }

  Future<http.Response> deleteNotify(int notifyId) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.post(
        host + 'delete_notify',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body: jsonEncode(<String, dynamic>{"id": notifyId}),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }

  Future<http.Response> seenNotify(int notifyId, bool seen) async {
    String token = await storage.read(key: "acessToken");
    var response;
    try {
      response = await http.post(
        host + 'seen_notify',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "accessToken": token
        },
        body:
            jsonEncode(<String, dynamic>{"notify_id": notifyId, 'seen': seen}),
      );
    } on Exception catch (e) {
      print(' Error: $e');
    }
    return response;
  }
}
