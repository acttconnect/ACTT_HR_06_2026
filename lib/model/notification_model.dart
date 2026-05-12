import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));
String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  NotificationModel({
    bool? error,
    List<Notifiication>? notifiication,
  }) {
    _error = error;
    _notifiication = notifiication;
  }

  NotificationModel.fromJson(dynamic json) {
    _error = json['error'];
    if (json['Notifiication'] != null) {
      _notifiication = [];
      json['Notifiication'].forEach((v) {
        _notifiication?.add(Notifiication.fromJson(v));
      });
    }
  }
  bool? _error;
  List<Notifiication>? _notifiication;
  NotificationModel copyWith({
    bool? error,
    List<Notifiication>? notifiication,
  }) =>
      NotificationModel(
        error: error ?? _error,
        notifiication: notifiication ?? _notifiication,
      );
  bool? get error => _error;
  List<Notifiication>? get notifiication => _notifiication;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    if (_notifiication != null) {
      map['Notifiication'] = _notifiication?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Notifiication notifiicationFromJson(String str) =>
    Notifiication.fromJson(json.decode(str));
String notifiicationToJson(Notifiication data) => json.encode(data.toJson());

class Notifiication {
  Notifiication({
    num? id,
    String? employeeId,
    String? docList,
    String? msg,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _employeeId = employeeId;
    _docList = docList;
    _msg = msg;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Notifiication.fromJson(dynamic json) {
    _id = json['id'];
    _employeeId = json['employee_id'];
    _docList = json['doc_list'];
    _msg = json['msg'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _employeeId;
  String? _docList;
  String? _msg;
  String? _createdAt;
  String? _updatedAt;
  Notifiication copyWith({
    num? id,
    String? employeeId,
    String? docList,
    String? msg,
    String? createdAt,
    String? updatedAt,
  }) =>
      Notifiication(
        id: id ?? _id,
        employeeId: employeeId ?? _employeeId,
        docList: docList ?? _docList,
        msg: msg ?? _msg,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get employeeId => _employeeId;
  String? get docList => _docList;
  String? get msg => _msg;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['employee_id'] = _employeeId;
    map['doc_list'] = _docList;
    map['msg'] = _msg;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
