class AppUser {
  final int? id;
  final String rmNumber;
  final String nik;
  final String fullName;
  final String email;
  final String phone;
  final String bloodType;
  final String allergies;
  final String bpjsNumber;
  final String role;

  const AppUser({
    this.id,
    required this.rmNumber,
    required this.nik,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.bloodType = 'O+',
    this.allergies = 'Tidak ada alergi obat',
    this.bpjsNumber = '',
    this.role = 'pasien',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num?)?.toInt(),
      rmNumber:
          (json['rm_number'] ?? json['rmNumber'] ?? 'RM-2026-0101').toString(),
      nik: (json['nik'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      bloodType: (json['blood_type'] ?? json['bloodType'] ?? 'O+').toString(),
      allergies:
          (json['allergies'] ?? 'Tidak ada alergi obat').toString(),
      bpjsNumber: (json['bpjs_number'] ?? json['bpjsNumber'] ?? '').toString(),
      role: (json['role'] ?? 'pasien').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rm_number': rmNumber,
      'nik': nik,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'blood_type': bloodType,
      'allergies': allergies,
      'bpjs_number': bpjsNumber,
      'role': role,
    };
  }

  Map<String, String> toClinicProfileMap() {
    return {
      'name': fullName,
      'nik': nik,
      'rmNumber': rmNumber,
      'bloodType': bloodType.isEmpty ? 'O+' : bloodType,
      'allergies': allergies.isEmpty ? 'Tidak ada alergi obat' : allergies,
      'bpjsNumber': bpjsNumber.isEmpty ? '-' : bpjsNumber,
      'phone': phone.isEmpty ? '-' : phone,
    };
  }

  AppUser copyWith({
    int? id,
    String? rmNumber,
    String? nik,
    String? fullName,
    String? email,
    String? phone,
    String? bloodType,
    String? allergies,
    String? bpjsNumber,
    String? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      rmNumber: rmNumber ?? this.rmNumber,
      nik: nik ?? this.nik,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      bpjsNumber: bpjsNumber ?? this.bpjsNumber,
      role: role ?? this.role,
    );
  }
}
