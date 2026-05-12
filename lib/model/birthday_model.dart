import 'dart:convert';

BirthdayModel birthdayModelFromJson(String str) =>
    BirthdayModel.fromJson(json.decode(str));
String birthdayModelToJson(BirthdayModel data) => json.encode(data.toJson());

class BirthdayModel {
  BirthdayModel({
    bool? error,
    String? message,
    List<Data>? data,
  }) {
    _error = error;
    _message = message;
    _data = data;
  }

  BirthdayModel.fromJson(dynamic json) {
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
  BirthdayModel copyWith({
    bool? error,
    String? message,
    List<Data>? data,
  }) =>
      BirthdayModel(
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
    String? name,
    String? dob,
    String? empid,
    String? number,
    String? image,
    String? email,
    String? designation,
    String? department,
    dynamic parentMobile,
    dynamic bloodGroup,
    dynamic permanentAdd,
    dynamic corresAdd,
    dynamic file,
    dynamic storePath,
    dynamic emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _name = name;
    _dob = dob;
    _empid = empid;
    _number = number;
    _image = image;
    _email = email;
    _designation = designation;
    _department = department;
    _parentMobile = parentMobile;
    _bloodGroup = bloodGroup;
    _permanentAdd = permanentAdd;
    _corresAdd = corresAdd;
    _file = file;
    _storePath = storePath;
    _emailVerifiedAt = emailVerifiedAt;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _dob = json['dob'];
    _empid = json['empid'];
    _number = json['number'];
    _image = json['image'];
    _email = json['email'];
    _designation = json['designation'];
    _department = json['department'];
    _parentMobile = json['parent_mobile'];
    _bloodGroup = json['blood_group'];
    _permanentAdd = json['permanent_add'];
    _corresAdd = json['corres_add'];
    _file = json['file'];
    _storePath = json['store_path'];
    _emailVerifiedAt = json['email_verified_at'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _name;
  String? _dob;
  String? _empid;
  String? _number;
  String? _image;
  String? _email;
  String? _designation;
  String? _department;
  dynamic _parentMobile;
  dynamic _bloodGroup;
  dynamic _permanentAdd;
  dynamic _corresAdd;
  dynamic _file;
  dynamic _storePath;
  dynamic _emailVerifiedAt;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    num? id,
    String? name,
    String? dob,
    String? empid,
    String? number,
    String? image,
    String? email,
    String? designation,
    String? department,
    dynamic parentMobile,
    dynamic bloodGroup,
    dynamic permanentAdd,
    dynamic corresAdd,
    dynamic file,
    dynamic storePath,
    dynamic emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        name: name ?? _name,
        dob: dob ?? _dob,
        empid: empid ?? _empid,
        number: number ?? _number,
        image: image ?? _image,
        email: email ?? _email,
        designation: designation ?? _designation,
        department: department ?? _department,
        parentMobile: parentMobile ?? _parentMobile,
        bloodGroup: bloodGroup ?? _bloodGroup,
        permanentAdd: permanentAdd ?? _permanentAdd,
        corresAdd: corresAdd ?? _corresAdd,
        file: file ?? _file,
        storePath: storePath ?? _storePath,
        emailVerifiedAt: emailVerifiedAt ?? _emailVerifiedAt,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get name => _name;
  String? get dob => _dob;
  String? get empid => _empid;
  String? get number => _number;
  String? get image => _image;
  String? get email => _email;
  String? get designation => _designation;
  String? get department => _department;
  dynamic get parentMobile => _parentMobile;
  dynamic get bloodGroup => _bloodGroup;
  dynamic get permanentAdd => _permanentAdd;
  dynamic get corresAdd => _corresAdd;
  dynamic get file => _file;
  dynamic get storePath => _storePath;
  dynamic get emailVerifiedAt => _emailVerifiedAt;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['dob'] = _dob;
    map['empid'] = _empid;
    map['number'] = _number;
    map['image'] = _image;
    map['email'] = _email;
    map['designation'] = _designation;
    map['department'] = _department;
    map['parent_mobile'] = _parentMobile;
    map['blood_group'] = _bloodGroup;
    map['permanent_add'] = _permanentAdd;
    map['corres_add'] = _corresAdd;
    map['file'] = _file;
    map['store_path'] = _storePath;
    map['email_verified_at'] = _emailVerifiedAt;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
