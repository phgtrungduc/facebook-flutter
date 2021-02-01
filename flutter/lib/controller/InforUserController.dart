import 'package:facebook/api/api.dart';
import 'package:facebook/controller/QueryPreferences.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
class InforUserController{
  API api;
  QueryPreferences _queryPreferences;
  InforUserController(){
    api = new API();
    _queryPreferences = new QueryPreferences();
  }

   Future<http.Response> getUserInfor ()async {
    String id ;
     await _queryPreferences.getPreShare("id_icre").then((value) {
       id = value;
     });
      return await api.getUserInfor(id);
  }
}