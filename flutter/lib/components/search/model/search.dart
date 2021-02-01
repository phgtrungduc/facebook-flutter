class SearchInfo {
  String _content = "";
  int _searchId = 0;
  SearchInfo(this._content, this._searchId);
  String get content => _content;
  int get searchId => _searchId;
}

class UserResult {
  Map<String, dynamic> _user;
  UserResult(this._user);
  Map get user => _user;
}

class PostResult {
  Map<String, dynamic> _post;
  PostResult(this._post);
  Map get post => _post;
}
