class Doctor {
  final String id;
  final String name;
  final String poli;
  final String specialistTitle;
  final String strNumber;
  final String scheduleDays;
  final String scheduleTime;
  final List<String> availableSessions;
  final String room;
  final int consultationFee;
  final double rating;
  final int experienceYears;
  final int quota;
  final String imageUrl;
  final String alumniUniversity;
  final String bio;
  final bool isFromApi;

  const Doctor({
    required this.id,
    required this.name,
    required this.poli,
    required this.specialistTitle,
    required this.strNumber,
    required this.scheduleDays,
    required this.scheduleTime,
    required this.availableSessions,
    required this.room,
    required this.consultationFee,
    required this.rating,
    required this.experienceYears,
    required this.quota,
    required this.imageUrl,
    required this.alumniUniversity,
    required this.bio,
    this.isFromApi = false,
  });

  static const List<Map<String, dynamic>> _apiPoliPresets = [
    {
      'poli': 'Poli Umum',
      'title': 'Dokter Umum Klinik',
      'suffix': '',
      'prefix': 'dr.',
      'days': 'Senin - Jumat',
      'time': '08:00 - 14:00 WIB',
      'sessions': ['08:00 - 10:00', '10:00 - 12:00', '12:30 - 14:00'],
      'room': 'R-101',
      'fee': 50000,
    },
    {
      'poli': 'Poli Gigi & Mulut',
      'title': 'Dokter Gigi Umum & Konservasi',
      'suffix': '',
      'prefix': 'drg.',
      'days': 'Selasa, Kamis, Sabtu',
      'time': '09:00 - 15:00 WIB',
      'sessions': ['09:00 - 11:00', '11:00 - 13:00', '13:30 - 15:00'],
      'room': 'R-104',
      'fee': 85000,
    },
    {
      'poli': 'Poli Anak',
      'title': 'Spesialis Kesehatan Anak',
      'suffix': ', Sp.A',
      'prefix': 'dr.',
      'days': 'Senin, Rabu, Jumat',
      'time': '08:30 - 13:00 WIB',
      'sessions': ['08:30 - 10:00', '10:00 - 11:30', '11:30 - 13:00'],
      'room': 'R-102',
      'fee': 95000,
    },
    {
      'poli': 'Poli Penyakit Dalam',
      'title': 'Spesialis Penyakit Dalam',
      'suffix': ', Sp.PD',
      'prefix': 'dr.',
      'days': 'Senin - Kamis',
      'time': '13:00 - 17:00 WIB',
      'sessions': ['13:00 - 14:30', '14:30 - 16:00', '16:00 - 17:00'],
      'room': 'R-201',
      'fee': 110000,
    },
    {
      'poli': 'Poli KIA & Kandungan',
      'title': 'Spesialis Obstetri & Ginekologi',
      'suffix': ', Sp.OG',
      'prefix': 'dr.',
      'days': 'Rabu, Jumat, Sabtu',
      'time': '09:00 - 14:00 WIB',
      'sessions': ['09:00 - 10:30', '10:30 - 12:00', '12:30 - 14:00'],
      'room': 'R-203',
      'fee': 115000,
    },
    {
      'poli': 'Poli Mata & THT',
      'title': 'Spesialis THT-KL & Mata',
      'suffix': ', Sp.THT-KL',
      'prefix': 'dr.',
      'days': 'Selasa & Jumat',
      'time': '14:00 - 18:00 WIB',
      'sessions': ['14:00 - 15:30', '15:30 - 17:00', '17:00 - 18:00'],
      'room': 'R-205',
      'fee': 100000,
    },
  ];

  /// Parsing JSON dari REST API publik (DummyJSON /users) ke model class Doctor
  factory Doctor.fromApiJson(Map<String, dynamic> json, {int index = 0}) {
    final preset = _apiPoliPresets[index % _apiPoliPresets.length];
    final firstName = (json['firstName'] ?? 'Dokter').toString();
    final lastName = (json['lastName'] ?? 'Mitra').toString();
    final rawId = json['id']?.toString() ?? '${index + 100}';
    final age = (json['age'] is num) ? (json['age'] as num).toInt() : 36;
    final expYears = (age - 25).clamp(3, 25);
    final university =
        (json['university'] ?? 'Fakultas Kedokteran Universitas Tanjungpura')
            .toString();

    return Doctor(
      id: 'api-$rawId',
      name: '${preset['prefix']} $firstName $lastName${preset['suffix']}',
      poli: preset['poli'] as String,
      specialistTitle: preset['title'] as String,
      strNumber: '31.2.1.${100 + index}.2.24.00$rawId',
      scheduleDays: preset['days'] as String,
      scheduleTime: preset['time'] as String,
      availableSessions: List<String>.from(preset['sessions'] as List),
      room: preset['room'] as String,
      consultationFee: preset['fee'] as int,
      rating: double.parse((4.6 + ((index % 4) * 0.1)).toStringAsFixed(1)),
      experienceYears: expYears,
      quota: 6 + (index % 7),
      imageUrl: (json['image'] ?? '').toString(),
      alumniUniversity: university,
      bio:
          'Dokter mitra jejaring klinik SehatKu lulusan $university dengan pengalaman praktik klinis $expYears tahun di bidang ${preset['poli']}.',
      isFromApi: true,
    );
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      poli: map['poli']?.toString() ?? 'Poli Umum',
      specialistTitle: map['specialistTitle']?.toString() ?? '',
      strNumber: map['strNumber']?.toString() ?? '',
      scheduleDays: map['scheduleDays']?.toString() ?? '',
      scheduleTime: map['scheduleTime']?.toString() ?? '',
      availableSessions: map['availableSessions'] is List
          ? List<String>.from(map['availableSessions'] as List)
          : ['08:00 - 10:00', '10:00 - 12:00'],
      room: map['room']?.toString() ?? 'R-101',
      consultationFee: (map['consultationFee'] as num?)?.toInt() ?? 50000,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 5,
      quota: (map['quota'] as num?)?.toInt() ?? 10,
      imageUrl: map['imageUrl']?.toString() ?? '',
      alumniUniversity: map['alumniUniversity']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      isFromApi: map['isFromApi'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'poli': poli,
      'specialistTitle': specialistTitle,
      'strNumber': strNumber,
      'scheduleDays': scheduleDays,
      'scheduleTime': scheduleTime,
      'availableSessions': availableSessions,
      'room': room,
      'consultationFee': consultationFee,
      'rating': rating,
      'experienceYears': experienceYears,
      'quota': quota,
      'imageUrl': imageUrl,
      'alumniUniversity': alumniUniversity,
      'bio': bio,
      'isFromApi': isFromApi,
    };
  }
}
