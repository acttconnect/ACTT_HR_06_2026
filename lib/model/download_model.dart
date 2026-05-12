import 'dart:convert';

DownloadModel downloadModelFromJson(String str) =>
    DownloadModel.fromJson(json.decode(str));
String downloadModelToJson(DownloadModel data) => json.encode(data.toJson());

class DownloadModel {
  DownloadModel({
    bool? error,
    List<Data>? data,
  }) {
    _error = error;
    _data = data;
  }

  DownloadModel.fromJson(dynamic json) {
    _error = json['error'];
    if (json['Data'] != null) {
      _data = [];
      json['Data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  List<Data>? _data;
  DownloadModel copyWith({
    bool? error,
    List<Data>? data,
  }) =>
      DownloadModel(
        error: error ?? _error,
        data: data ?? _data,
      );
  bool? get error => _error;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    if (_data != null) {
      map['Data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    num? id,
    String? title,
    String? empId,
    String? doc,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _title = title;
    _empId = empId;
    _doc = doc;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _empId = json['emp_id'];
    _doc = json['doc'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _title;
  String? _empId;
  String? _doc;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    num? id,
    String? title,
    String? empId,
    String? doc,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        title: title ?? _title,
        empId: empId ?? _empId,
        doc: doc ?? _doc,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get title => _title;
  String? get empId => _empId;
  String? get doc => _doc;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['emp_id'] = _empId;
    map['doc'] = _doc;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
