import 'package:shared_preferences/shared_preferences.dart';

class QueryPreferences{
  savePreShare(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
   Future<String> getPreShare(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}