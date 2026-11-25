class BookingAppointment {
  final int? id;
  final String queueNumber;
  final String doctorId;
  final String doctorName;
  final String poli;
  final String room;
  final String patientName;
  final String patientNik;
  final String visitDate;
  final String sessionTime;
  final String paymentType;
  final String complaint;
  final String status;
  final String createdAt;

  const BookingAppointment({
    this.id,
    required this.queueNumber,
    required this.doctorId,
    required this.doctorName,
    required this.poli,
    required this.room,
    required this.patientName,
    required this.patientNik,
    required this.visitDate,
    required this.sessionTime,
    required this.paymentType,
    required this.complaint,
    this.status = 'Terjadwal',
    required this.createdAt,
  });

  BookingAppointment copyWith({
    int? id,
    String? status,
  }) {
    return BookingAppointment(
      id: id ?? this.id,
      queueNumber: queueNumber,
      doctorId: doctorId,
      doctorName: doctorName,
      poli: poli,
      room: room,
      patientName: patientName,
      patientNik: patientNik,
      visitDate: visitDate,
      sessionTime: sessionTime,
      paymentType: paymentType,
      complaint: complaint,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory BookingAppointment.fromMap(Map<String, dynamic> map) {
    return BookingAppointment(
      id: (map['id'] as num?)?.toInt(),
      queueNumber: map['queue_number']?.toString() ?? 'A-001',
      doctorId: map['doctor_id']?.toString() ?? '',
      doctorName: map['doctor_name']?.toString() ?? '',
      poli: map['poli']?.toString() ?? 'Poli Umum',
      room: map['room']?.toString() ?? 'R-101',
      patientName: map['patient_name']?.toString() ?? '',
      patientNik: map['patient_nik']?.toString() ?? '',
      visitDate: map['visit_date']?.toString() ?? '',
      sessionTime: map['session_time']?.toString() ?? '',
      paymentType: map['payment_type']?.toString() ?? 'BPJS Kesehatan',
      complaint: map['complaint']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Terjadwal',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'queue_number': queueNumber,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'poli': poli,
      'room': room,
      'patient_name': patientName,
      'patient_nik': patientNik,
      'visit_date': visitDate,
      'session_time': sessionTime,
      'payment_type': paymentType,
      'complaint': complaint,
      'status': status,
      'created_at': createdAt,
    };
  }
}
