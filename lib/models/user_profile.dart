// models/user_profile.dart
class UserProfile {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final double targetGlucoseMin;
  final double targetGlucoseMax;
  final int dailyCaloriesTarget;
  final DateTime memberSince;
  final String? phoneNumber;
  final String? emergencyContact;
  final String? medicalConditions;
  final String? medications;
  final String? profilePhotoPath;
  final String? allergies;
  final String? bloodType;
  final String? insuranceInfo;
  final String? doctorName;
  final String? doctorPhone;

  UserProfile({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.targetGlucoseMin,
    required this.targetGlucoseMax,
    required this.dailyCaloriesTarget,
    required this.memberSince,
    this.phoneNumber,
    this.emergencyContact,
    this.medicalConditions,
    this.medications,
    this.profilePhotoPath,
    this.allergies,
    this.bloodType,
    this.insuranceInfo,
    this.doctorName,
    this.doctorPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'targetGlucoseMin': targetGlucoseMin,
      'targetGlucoseMax': targetGlucoseMax,
      'dailyCaloriesTarget': dailyCaloriesTarget,
      'memberSince': memberSince.toIso8601String(),
      'phoneNumber': phoneNumber,
      'emergencyContact': emergencyContact,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'profilePhotoPath': profilePhotoPath,
      'allergies': allergies,
      'bloodType': bloodType,
      'insuranceInfo': insuranceInfo,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
      age: map['age'],
      gender: map['gender'],
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      targetGlucoseMin: map['targetGlucoseMin']?.toDouble(),
      targetGlucoseMax: map['targetGlucoseMax']?.toDouble(),
      dailyCaloriesTarget: map['dailyCaloriesTarget'],
      memberSince: DateTime.parse(map['memberSince']),
      phoneNumber: map['phoneNumber'],
      emergencyContact: map['emergencyContact'],
      medicalConditions: map['medicalConditions'],
      medications: map['medications'],
      profilePhotoPath: map['profilePhotoPath'],
      allergies: map['allergies'],
      bloodType: map['bloodType'],
      insuranceInfo: map['insuranceInfo'],
      doctorName: map['doctorName'],
      doctorPhone: map['doctorPhone'],
    );
  }

  UserProfile copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    int? age,
    String? gender,
    double? weight,
    double? height,
    double? targetGlucoseMin,
    double? targetGlucoseMax,
    int? dailyCaloriesTarget,
    DateTime? memberSince,
    String? phoneNumber,
    String? emergencyContact,
    String? medicalConditions,
    String? medications,
    String? profilePhotoPath,
    String? allergies,
    String? bloodType,
    String? insuranceInfo,
    String? doctorName,
    String? doctorPhone,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      targetGlucoseMin: targetGlucoseMin ?? this.targetGlucoseMin,
      targetGlucoseMax: targetGlucoseMax ?? this.targetGlucoseMax,
      dailyCaloriesTarget: dailyCaloriesTarget ?? this.dailyCaloriesTarget,
      memberSince: memberSince ?? this.memberSince,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      allergies: allergies ?? this.allergies,
      bloodType: bloodType ?? this.bloodType,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
    );
  }
}