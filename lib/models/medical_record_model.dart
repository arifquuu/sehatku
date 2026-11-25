class MedicalRecord {
  final int? id;
  final String patientName;
  final String medicalRecordNumber;
  final String visitDate;
  final String poli;
  final String doctorName;
  final String diagnosis;
  final String symptoms;
  final String treatmentAndPrescription;
  final String bloodPressure;
  final double bodyWeightKg;
  final String nextControlDate;
  final String notes;
  final String? documentPhotoPath;

  const MedicalRecord({
    this.id,
    required this.patientName,
    required this.medicalRecordNumber,
    required this.visitDate,
    required this.poli,
    required this.doctorName,
    required this.diagnosis,
    required this.symptoms,
    required this.treatmentAndPrescription,
    required this.bloodPressure,
    required this.bodyWeightKg,
    required this.nextControlDate,
    required this.notes,
    this.documentPhotoPath,
  });

  MedicalRecord copyWith({
    int? id,
    String? patientName,
    String? medicalRecordNumber,
    String? visitDate,
    String? poli,
    String? doctorName,
    String? diagnosis,
    String? symptoms,
    String? treatmentAndPrescription,
    String? bloodPressure,
    double? bodyWeightKg,
    String? nextControlDate,
    String? notes,
    String? documentPhotoPath,
    bool clearDocumentPhoto = false,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      medicalRecordNumber: medicalRecordNumber ?? this.medicalRecordNumber,
      visitDate: visitDate ?? this.visitDate,
      poli: poli ?? this.poli,
      doctorName: doctorName ?? this.doctorName,
      diagnosis: diagnosis ?? this.diagnosis,
      symptoms: symptoms ?? this.symptoms,
      treatmentAndPrescription:
          treatmentAndPrescription ?? this.treatmentAndPrescription,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
      nextControlDate: nextControlDate ?? this.nextControlDate,
      notes: notes ?? this.notes,
      documentPhotoPath: clearDocumentPhoto
          ? null
          : (documentPhotoPath ?? this.documentPhotoPath),
    );
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    final rawPhoto = map['document_photo_path']?.toString();
    return MedicalRecord(
      id: (map['id'] as num?)?.toInt(),
      patientName: map['patient_name']?.toString() ?? '',
      medicalRecordNumber:
          map['medical_record_number']?.toString() ?? 'RM-2026-0001',
      visitDate: map['visit_date']?.toString() ?? '',
      poli: map['poli']?.toString() ?? 'Poli Umum',
      doctorName: map['doctor_name']?.toString() ?? '',
      diagnosis: map['diagnosis']?.toString() ?? '',
      symptoms: map['symptoms']?.toString() ?? '',
      treatmentAndPrescription:
          map['treatment_prescription']?.toString() ?? '',
      bloodPressure: map['blood_pressure']?.toString() ?? '120/80 mmHg',
      bodyWeightKg: (map['body_weight_kg'] as num?)?.toDouble() ?? 60.0,
      nextControlDate: map['next_control_date']?.toString() ?? '-',
      notes: map['notes']?.toString() ?? '',
      documentPhotoPath:
          (rawPhoto != null && rawPhoto.isNotEmpty) ? rawPhoto : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'patient_name': patientName,
      'medical_record_number': medicalRecordNumber,
      'visit_date': visitDate,
      'poli': poli,
      'doctor_name': doctorName,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'treatment_prescription': treatmentAndPrescription,
      'blood_pressure': bloodPressure,
      'body_weight_kg': bodyWeightKg,
      'next_control_date': nextControlDate,
      'notes': notes,
      'document_photo_path': documentPhotoPath,
    };
  }
}
