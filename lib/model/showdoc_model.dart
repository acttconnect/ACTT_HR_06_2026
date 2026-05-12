import 'dart:convert';

ShowDocModel showDocModelFromJson(String str) =>
    ShowDocModel.fromJson(json.decode(str));
String showDocModelToJson(ShowDocModel data) => json.encode(data.toJson());

class ShowDocModel {
  ShowDocModel({
    bool? error,
    List<Data>? data,
  }) {
    _error = error;
    _data = data;
  }

  ShowDocModel.fromJson(dynamic json) {
    _error = json['error'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  List<Data>? _data;
  ShowDocModel copyWith({
    bool? error,
    List<Data>? data,
  }) =>
      ShowDocModel(
        error: error ?? _error,
        data: data ?? _data,
      );
  bool? get error => _error;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
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
    String? empId,
    String? documentName,
    dynamic name,
    String? storePath,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _empId = empId;
    _documentName = documentName;
    _name = name;
    _storePath = storePath;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _empId = json['emp_id'];
    _documentName = json['document_name'];
    _name = json['name'];
    _storePath = json['store_path'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _empId;
  String? _documentName;
  dynamic _name;
  String? _storePath;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    num? id,
    String? empId,
    String? documentName,
    dynamic name,
    String? storePath,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        empId: empId ?? _empId,
        documentName: documentName ?? _documentName,
        name: name ?? _name,
        storePath: storePath ?? _storePath,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get empId => _empId;
  String? get documentName => _documentName;
  dynamic get name => _name;
  String? get storePath => _storePath;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['emp_id'] = _empId;
    map['document_name'] = _documentName;
    map['name'] = _name;
    map['store_path'] = _storePath;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
