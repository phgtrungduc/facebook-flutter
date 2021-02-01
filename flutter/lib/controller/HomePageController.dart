import 'package:facebook/api/api.dart';
import 'package:facebook/controller/QueryPreferences.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
class HomepageController{
  API api;
  QueryPreferences _queryPreferences;
  HomepageController(){
    api = new API();
    _queryPreferences = new QueryPreferences();
  }
  Future<http.Response> getListPost() async{
    return await api.getListPost();
  }
}