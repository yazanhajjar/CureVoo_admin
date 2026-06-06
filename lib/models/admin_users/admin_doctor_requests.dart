class CreateAdminDoctorRequest {
  const CreateAdminDoctorRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.age,
    required this.specialization,
    required this.workingAt,
    required this.experience,
    required this.location,
    required this.languages,
  });

  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final int age;
  final String specialization;
  final String workingAt;
  final int experience;
  final String location;
  final List<String> languages;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'age': age,
        'specialization': specialization,
        'workplace': workingAt,
        'experience': experience,
        'location': location,
        'languages': languages,
      };
}

class UpdateAdminDoctorRequest {
  const UpdateAdminDoctorRequest({
    this.fullName,
    this.phoneNumber,
    this.age,
    this.specialization,
    this.workingAt,
    this.location,
    this.languages,
    this.qualifications,
    this.experience,
    this.bio,
    this.photoUrl,
    this.consultationFee,
    this.isActive,
  });

  final String? fullName;
  final String? phoneNumber;
  final int? age;
  final String? specialization;
  final String? workingAt;
  final String? location;
  final List<String>? languages;
  final String? qualifications;
  final int? experience;
  final String? bio;
  final String? photoUrl;
  final double? consultationFee;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null && fullName!.isNotEmpty) map['fullName'] = fullName;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) map['phoneNumber'] = phoneNumber;
    if (age != null) map['age'] = age;
    if (specialization != null && specialization!.isNotEmpty) map['specialization'] = specialization;
    if (workingAt != null && workingAt!.isNotEmpty) {
      map['workplace'] = workingAt;
    }
    if (location != null && location!.isNotEmpty) map['location'] = location;
    if (languages != null) map['languages'] = languages;
    if (qualifications != null && qualifications!.isNotEmpty) map['qualifications'] = qualifications;
    if (experience != null) map['experience'] = experience;
    if (bio != null && bio!.isNotEmpty) map['bio'] = bio;
    if (photoUrl != null && photoUrl!.isNotEmpty) map['photoUrl'] = photoUrl;
    if (consultationFee != null) map['consultationFee'] = consultationFee;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}
