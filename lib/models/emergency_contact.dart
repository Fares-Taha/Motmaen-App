// models/emergency_contact.dart
class EmergencyContact {
  final int? id;
  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;

  EmergencyContact({
    this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.isPrimary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'isPrimary': isPrimary ? 1 : 0,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'],
      relationship: map['relationship'],
      phone: map['phone'],
      isPrimary: map['isPrimary'] == 1,
    );
  }

  EmergencyContact copyWith({
    int? id,
    String? name,
    String? relationship,
    String? phone,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}