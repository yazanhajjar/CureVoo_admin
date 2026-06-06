class CreateAdminAccountRequest {
  const CreateAdminAccountRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.age,
    this.bio,
    this.specialization,
    this.workPlace,
    this.languages,
    this.location,
    this.experience,
    this.qualifications,
    this.consultationFee,
  });

  final String email;
  final String password;
  final String fullName;
  final String role;

  final String? phoneNumber;
  final int? age;
  final String? bio;
  final String? specialization;
  final String? workPlace;
  final List<String>? languages;
  final String? location;
  final String? experience;
  final String? qualifications;
  final double? consultationFee;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
    };

    if (phoneNumber != null && phoneNumber!.isNotEmpty) map['phoneNumber'] = phoneNumber;
    if (age != null) map['age'] = age;
    if (bio != null && bio!.isNotEmpty) map['bio'] = bio;
    if (specialization != null && specialization!.isNotEmpty) map['specialization'] = specialization;
    if (workPlace != null && workPlace!.isNotEmpty) {
      map['workPlace'] = workPlace;
      map['workplace'] = workPlace;
    }
    if (languages != null && languages!.isNotEmpty) map['languages'] = languages;
    if (location != null && location!.isNotEmpty) map['location'] = location;
    if (experience != null && experience!.isNotEmpty) map['experience'] = experience;
    if (qualifications != null && qualifications!.isNotEmpty) map['qualifications'] = qualifications;
    if (consultationFee != null) map['consultationFee'] = consultationFee;

    return map;
  }
}
