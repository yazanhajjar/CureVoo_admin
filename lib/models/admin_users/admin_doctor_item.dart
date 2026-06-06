import 'package:equatable/equatable.dart';

class AdminDoctorItem extends Equatable {
  const AdminDoctorItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.raw,
    this.phoneNumber,
    this.specialization,
    this.location,
    this.isActive,
  });

  final String id;
  final String fullName;
  final String email;
  final Map<String, dynamic> raw;
  final String? phoneNumber;
  final String? specialization;
  final String? location;
  final bool? isActive;

  AdminDoctorItem copyWith({
    String? id,
    String? fullName,
    String? email,
    Map<String, dynamic>? raw,
    String? phoneNumber,
    String? specialization,
    String? location,
    bool? isActive,
  }) {
    return AdminDoctorItem(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      raw: raw ?? this.raw,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specialization: specialization ?? this.specialization,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
    );
  }

  factory AdminDoctorItem.fromJson(Map<String, dynamic> json) {
    final profile = json['doctorProfile'] is Map
        ? Map<String, dynamic>.from(json['doctorProfile'] as Map)
        : const <String, dynamic>{};

    return AdminDoctorItem(
      id: (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString(),
      fullName: (profile['fullName'] ?? json['fullName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      raw: Map<String, dynamic>.from(json),
      phoneNumber: json['phoneNumber']?.toString(),
      specialization: (profile['specialization'] ?? json['specialization'])?.toString(),
      location: (profile['location'] ?? json['location'])?.toString(),
      isActive: profile['isActive'] is bool
          ? profile['isActive'] as bool
          : (json['isActive'] is bool ? json['isActive'] as bool : null),
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, raw, phoneNumber, specialization, location, isActive];
}
