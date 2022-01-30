class Settings {
  int id;
  String restoreDate;
  String lastSyncDate;

  Settings({this.id, this.restoreDate, this.lastSyncDate});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['restore_date'] = restoreDate;
    map['last_sync_date'] = lastSyncDate;
    return map;
  }

  Settings.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.restoreDate = map['restore_date'];
    this.lastSyncDate = map['last_sync_date'];
  }
}
