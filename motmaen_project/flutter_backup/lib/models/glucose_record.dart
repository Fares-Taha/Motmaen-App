class GlucoseRecord {
  int? id;
  double glucoseLevel;
  String measurementTime; // Fasting, After Meal, etc.
  DateTime dateTime;
  String? notes;

  GlucoseRecord({
    this.id,
    required this.glucoseLevel,
    required this.measurementTime,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'glucoseLevel': glucoseLevel,
      'measurementTime': measurementTime,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory GlucoseRecord.fromMap(Map<String, dynamic> map) {
    return GlucoseRecord(
      id: map['id'],
      glucoseLevel: map['glucoseLevel'],
      measurementTime: map['measurementTime'],
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }
}