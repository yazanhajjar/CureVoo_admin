import 'package:equatable/equatable.dart';

class AdminPatientItem extends Equatable {
  const AdminPatientItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.raw,
    this.phoneNumber,
    this.age,
    this.sex,
    this.location,
  });

  final String id;
  final String fullName;
  final String email;
  final Map<String, dynamic> raw;
  final String? phoneNumber;
  final int? age;
  final String? sex;
  final String? location;

  AdminPatientItem copyWith({
    String? id,
    String? fullName,
    String? email,
    Map<String, dynamic>? raw,
    String? phoneNumber,
    int? age,
    String? sex,
    String? location,
  }) {
    return AdminPatientItem(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      raw: raw ?? this.raw,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      location: location ?? this.location,
    );
  }

  factory AdminPatientItem.fromJson(Map<String, dynamic> json) {
    final profile = _extractProfile(json);

    return AdminPatientItem(
      id: (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString(),
      fullName: (profile['fullName'] ?? json['fullName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      raw: Map<String, dynamic>.from(json),
      phoneNumber: (profile['phoneNumber'] ?? json['phoneNumber'])?.toString(),
      age: profile['age'] is int
          ? profile['age'] as int
          : (json['age'] is int ? json['age'] as int : int.tryParse('${profile['age'] ?? json['age'] ?? ''}')),
      sex: (profile['sex'] ?? profile['gender'] ?? json['sex'] ?? json['gender'])?.toString(),
      location: (profile['location'] ??
              profile['city'] ??
              profile['address'] ??
              json['location'] ??
              json['city'] ??
              json['address'])?.toString(),
    );
  }

  static Map<String, dynamic> _extractProfile(Map<String, dynamic> json) {
    const keys = <String>[
      'patientProfile',
      'patientprofile',
      'profile',
      'patient',
    ];
    for (final key in keys) {
      final value = json[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return const <String, dynamic>{};
  }

  @override
  List<Object?> get props => [id, fullName, email, raw, phoneNumber, age, sex, location];
}
