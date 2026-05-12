class Holiday {
  final String? id;
  final String name;
  final DateTime date;
  final String? type;

  Holiday({this.id, required this.name, required this.date, this.type});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id']?.toString(),
      name: json['name'] ?? json['type'] ?? 'Holiday',
      date: DateTime.parse(json['date']),
      type: json['type']?.toString(),
    );
  }
} 