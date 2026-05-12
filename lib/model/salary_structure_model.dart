class SalaryStructureResponse {
  final String employeeId;
  final String month;
  final int calendarDays;
  final int payableUnits;
  final double totalSalary;
  final Breakdown breakdown;

  SalaryStructureResponse({
    required this.employeeId,
    required this.month,
    required this.calendarDays,
    required this.payableUnits,
    required this.totalSalary,
    required this.breakdown,
  });

  factory SalaryStructureResponse.fromJson(Map<String, dynamic> json) {
    return SalaryStructureResponse(
      employeeId: json['employee_id'] ?? '',
      month: json['month'] ?? '',
      calendarDays: json['calendar_days'] ?? 0,
      payableUnits: json['payable_units'] ?? 0,
      totalSalary: (json['total_salary'] ?? 0.0).toDouble(),
      breakdown: Breakdown.fromJson(json['breakdown'] ?? {}),
    );
  }
}

class Breakdown {
  final DayType sundays;
  final DayType secondSat;
  final DayType holidays;
  final DayType present;
  final DayType halfDays;
  final DayType absent;

  Breakdown({
    required this.sundays,
    required this.secondSat,
    required this.holidays,
    required this.present,
    required this.halfDays,
    required this.absent,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(
      sundays: DayType.fromJson(json['sundays'] ?? {}),
      secondSat: DayType.fromJson(json['second_sat'] ?? {}),
      holidays: DayType.fromJson(json['holidays'] ?? {}),
      present: DayType.fromJson(json['present'] ?? {}),
      halfDays: DayType.fromJson(json['half_days'] ?? {}),
      absent: DayType.fromJson(json['absent'] ?? {}),
    );
  }
}

class DayType {
  final int count;
  final List<String> dates;

  DayType({
    required this.count,
    required this.dates,
  });

  factory DayType.fromJson(Map<String, dynamic> json) {
    return DayType(
      count: json['count'] ?? 0,
      dates: List<String>.from(json['dates'] ?? []),
    );
  }
} 