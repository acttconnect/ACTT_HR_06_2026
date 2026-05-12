import 'dart:convert';

EventsData eventsDataFromJson(String str) =>
    EventsData.fromJson(json.decode(str));
String eventsDataToJson(EventsData data) => json.encode(data.toJson());

class EventsData {
  EventsData({
    bool? error,
    String? message,
    List<Data>? data,
  }) {
    _error = error;
    _message = message;
    _data = data;
  }

  EventsData.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  List<Data>? _data;
  EventsData copyWith({
    bool? error,
    String? message,
    List<Data>? data,
  }) =>
      EventsData(
        error: error ?? _error,
        message: message ?? _message,
        data: data ?? _data,
      );
  bool? get error => _error;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    num? id,
    String? type,
    String? title,
    String? des,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _type = type;
    _title = title;
    _des = des;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _type = json['type'];
    _title = json['title'];
    _des = json['des'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _type;
  String? _title;
  String? _des;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    num? id,
    String? type,
    String? title,
    String? des,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        type: type ?? _type,
        title: title ?? _title,
        des: des ?? _des,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get type => _type;
  String? get title => _title;
  String? get des => _des;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['type'] = _type;
    map['title'] = _title;
    map['des'] = _des;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
