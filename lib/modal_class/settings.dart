class Settings {
  int id;
  String restoreDate;
  String lastSyncDate;
  bool isLogin;
  String userName;

  Settings({
    this.id,
    this.restoreDate,
    this.lastSyncDate,
    this.isLogin,
    this.userName,
  });

  get username => null;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['restore_date'] = restoreDate;
    map['last_sync_date'] = lastSyncDate;
    map['is_login'] = isLogin;
    map['user_name'] = userName;
    return map;
  }

  Settings.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.restoreDate = map['restore_date'];
    this.lastSyncDate = map['last_sync_date'];
    this.isLogin = map['is_login'];
    this.userName = map['user_name'];
  }
}
