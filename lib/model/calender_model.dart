import 'dart:convert';

CalenderModel calenderModelFromJson(String str) =>
    CalenderModel.fromJson(json.decode(str));
String calenderModelToJson(CalenderModel data) => json.encode(data.toJson());

class CalenderModel {
  CalenderModel({
    bool? status,
    List<Data>? data,
  }) {
    _status = status;
    _data = data;
  }

  CalenderModel.fromJson(dynamic json) {
    _status = json['status'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _status;
  List<Data>? _data;
  CalenderModel copyWith({
    bool? status,
    List<Data>? data,
  }) =>
      CalenderModel(
        status: status ?? _status,
        data: data ?? _data,
      );
  bool? get status => _status;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
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
    String? employeeId,
    String? employeeName,
    String? date,
    String? day,
    String? checkin,
    String? checkinLocation,
    String? checkout,
    String? checkoutLocation,
    String? workingHours,
    String? monthName,
    String? workStatus,
    String? createdAt,
    String? updatedAt,
    String? compareDate,
  }) {
    _id = id;
    _empId = empId;
    _employeeId = employeeId;
    _employeeName = employeeName;
    _date = date;
    _day = day;
    _checkin = checkin;
    _checkinLocation = checkinLocation;
    _checkout = checkout;
    _checkoutLocation = checkoutLocation;
    _workingHours = workingHours;
    _monthName = monthName;
    _workStatus = workStatus;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _compareDate = compareDate;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _empId = json['emp_id'];
    _employeeId = json['employee_id'];
    _employeeName = json['employee_name'];
    _date = json['date'];
    _day = json['day'];
    _checkin = json['checkin'];
    _checkinLocation = json['checkin_location'];
    _checkout = json['checkout'];
    _checkoutLocation = json['checkout_location'];
    _workingHours = json['working_hours'];
    _monthName = json['month_name'];
    _workStatus = json['work_status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _compareDate = json['compare_date'];
  }
  num? _id;
  String? _empId;
  String? _employeeId;
  String? _employeeName;
  String? _date;
  String? _day;
  String? _checkin;
  String? _checkinLocation;
  String? _checkout;
  String? _checkoutLocation;
  String? _workingHours;
  String? _monthName;
  String? _workStatus;
  String? _createdAt;
  String? _updatedAt;
  String? _compareDate;
  Data copyWith({
    num? id,
    String? empId,
    String? employeeId,
    String? employeeName,
    String? date,
    String? day,
    String? checkin,
    String? checkinLocation,
    String? checkout,
    String? checkoutLocation,
    String? workingHours,
    String? monthName,
    String? workStatus,
    String? createdAt,
    String? updatedAt,
    String? compareDate,
  }) =>
      Data(
        id: id ?? _id,
        empId: empId ?? _empId,
        employeeId: employeeId ?? _employeeId,
        employeeName: employeeName ?? _employeeName,
        date: date ?? _date,
        day: day ?? _day,
        checkin: checkin ?? _checkin,
        checkinLocation: checkinLocation ?? _checkinLocation,
        checkout: checkout ?? _checkout,
        checkoutLocation: checkoutLocation ?? _checkoutLocation,
        workingHours: workingHours ?? _workingHours,
        monthName: monthName ?? _monthName,
        workStatus: workStatus ?? _workStatus,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        compareDate: compareDate ?? _compareDate,
      );
  num? get id => _id;
  String? get empId => _empId;
  String? get employeeId => _employeeId;
  String? get employeeName => _employeeName;
  String? get date => _date;
  String? get day => _day;
  String? get checkin => _checkin;
  String? get checkinLocation => _checkinLocation;
  String? get checkout => _checkout;
  String? get checkoutLocation => _checkoutLocation;
  String? get workingHours => _workingHours;
  String? get monthName => _monthName;
  String? get workStatus => _workStatus;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get compareDate => _compareDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['emp_id'] = _empId;
    map['employee_id'] = _employeeId;
    map['employee_name'] = _employeeName;
    map['date'] = _date;
    map['day'] = _day;
    map['checkin'] = _checkin;
    map['checkin_location'] = _checkinLocation;
    map['checkout'] = _checkout;
    map['checkout_location'] = _checkoutLocation;
    map['working_hours'] = _workingHours;
    map['month_name'] = _monthName;
    map['work_status'] = _workStatus;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['compare_date'] = _compareDate;
    return map;
  }
}
