class CreateAdminPatientRequest {
  const CreateAdminPatientRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.age,
  });

  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final int? age;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
    };
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      map['phoneNumber'] = phoneNumber;
    }
    if (age != null) {
      map['age'] = age;
    }
    return map;
  }
}

class UpdateAdminPatientRequest {
  const UpdateAdminPatientRequest({
    this.fullName,
    this.phoneNumber,
    this.age,
    this.sex,
    this.location,
  });

  final String? fullName;
  final String? phoneNumber;
  final int? age;
  final String? sex;
  final String? location;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null && fullName!.isNotEmpty) map['fullName'] = fullName;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) map['phoneNumber'] = phoneNumber;
    if (age != null) map['age'] = age;
    if (sex != null && sex!.isNotEmpty) map['sex'] = sex;
    if (location != null && location!.isNotEmpty) map['address'] = location;
    return map;
  }
}
