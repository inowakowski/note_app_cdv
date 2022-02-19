class Settings {
  int _id;
  String _restoreDate;
  String _lastSyncDate;
  String _userName;

  Settings(
    // this.id,
    this._restoreDate,
    this._lastSyncDate,
    this._userName,
  );

  Settings.withId(
      this._id, this._restoreDate, this._lastSyncDate, this._userName);

  int get id => _id;

  String get restoreDate => _restoreDate;

  String get lastSyncDate => _lastSyncDate;

  String get userName => _userName;

  set restoreDate(String newRestoreDate) {
    if (newRestoreDate.length < 255) {
      this._restoreDate = newRestoreDate;
    }
  }

  set lastSyncDate(String newLastSyncDate) {
    if (newLastSyncDate.length < 255) {
      this._lastSyncDate = newLastSyncDate;
    }
  }

  set userName(String newUserName) {
    if (newUserName.length < 255) {
      this._userName = newUserName;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['restore_date'] = _restoreDate;
    map['last_sync_date'] = _lastSyncDate;
    map['username'] = _userName;
    return map;
  }

  Settings.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._restoreDate = map['restore_date'];
    this._lastSyncDate = map['last_sync_date'];
    this._userName = map['username'];
  }
}
