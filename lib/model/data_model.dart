import 'dart:convert';

DataModel dataModelFromJson(String str) => DataModel.fromJson(json.decode(str));
String dataModelToJson(DataModel data) => json.encode(data.toJson());

class DataModel {
  DataModel({
    bool? status,
    List<EmployeeLeaveData>? employeeLeaveData,
  }) {
    _status = status;
    _employeeLeaveData = employeeLeaveData;
  }

  DataModel.fromJson(dynamic json) {
    _status = json['status'];
    if (json['Employee Leave Data'] != null) {
      _employeeLeaveData = [];
      json['Employee Leave Data'].forEach((v) {
        _employeeLeaveData?.add(EmployeeLeaveData.fromJson(v));
      });
    }
  }
  bool? _status;
  List<EmployeeLeaveData>? _employeeLeaveData;
  DataModel copyWith({
    bool? status,
    List<EmployeeLeaveData>? employeeLeaveData,
  }) =>
      DataModel(
        status: status ?? _status,
        employeeLeaveData: employeeLeaveData ?? _employeeLeaveData,
      );
  bool? get status => _status;
  List<EmployeeLeaveData>? get employeeLeaveData => _employeeLeaveData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_employeeLeaveData != null) {
      map['Employee Leave Data'] =
          _employeeLeaveData?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

EmployeeLeaveData employeeLeaveDataFromJson(String str) =>
    EmployeeLeaveData.fromJson(json.decode(str));
String employeeLeaveDataToJson(EmployeeLeaveData data) =>
    json.encode(data.toJson());

class EmployeeLeaveData {
  EmployeeLeaveData({
    num? id,
    String? empId,
    String? type,
    String? region,
    String? startDate,
    String? endDate,
    String? status,
    dynamic approvedDate,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _empId = empId;
    _type = type;
    _region = region;
    _startDate = startDate;
    _endDate = endDate;
    _status = status;
    _approvedDate = approvedDate;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  EmployeeLeaveData.fromJson(dynamic json) {
    _id = json['id'];
    _empId = json['emp_id'];
    _type = json['type'];
    _region = json['region'];
    _startDate = json['start_date'];
    _endDate = json['end_date'];
    _status = json['status'];
    _approvedDate = json['approved_date'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _empId;
  String? _type;
  String? _region;
  String? _startDate;
  String? _endDate;
  String? _status;
  dynamic _approvedDate;
  String? _createdAt;
  String? _updatedAt;
  EmployeeLeaveData copyWith({
    num? id,
    String? empId,
    String? type,
    String? region,
    String? startDate,
    String? endDate,
    String? status,
    dynamic approvedDate,
    String? createdAt,
    String? updatedAt,
  }) =>
      EmployeeLeaveData(
        id: id ?? _id,
        empId: empId ?? _empId,
        type: type ?? _type,
        region: region ?? _region,
        startDate: startDate ?? _startDate,
        endDate: endDate ?? _endDate,
        status: status ?? _status,
        approvedDate: approvedDate ?? _approvedDate,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get empId => _empId;
  String? get type => _type;
  String? get region => _region;
  String? get startDate => _startDate;
  String? get endDate => _endDate;
  String? get status => _status;
  dynamic get approvedDate => _approvedDate;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['emp_id'] = _empId;
    map['type'] = _type;
    map['region'] = _region;
    map['start_date'] = _startDate;
    map['end_date'] = _endDate;
    map['status'] = _status;
    map['approved_date'] = _approvedDate;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
