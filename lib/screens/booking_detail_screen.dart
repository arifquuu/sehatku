import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/doctor_model.dart';
import '../providers/clinic_data_provider.dart';
import '../routing/app_router.dart';
import '../services/notification_service.dart';
import '../theme/sehatku_theme.dart';

class BookingDetailScreen extends StatefulWidget {
  static const String routeName = '/booking';
  final Doctor doctor;

  const BookingDetailScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nikController;
  final TextEditingController _complaintController = TextEditingController();

  late DateTime _selectedDate;
  late String _selectedSession;
  String _paymentType = 'BPJS Kesehatan';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ClinicDataProvider>().patientProfile;
    _nameController = TextEditingController(text: profile['name'] ?? '');
    _nikController = TextEditingController(text: profile['nik'] ?? '');
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedSession = widget.doctor.availableSessions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final provider = context.read<ClinicDataProvider>();
    final created = await provider.createBooking(
      doctor: widget.doctor,
      patientName: _nameController.text.trim(),
      patientNik: _nikController.text.trim(),
      visitDate: _formatDate(_selectedDate),
      sessionTime: _selectedSession,
      paymentType: _paymentType,
      complaint: _complaintController.text.trim(),
    );

    if (provider.reminderEnabled) {
      await NotificationService.instance.showBookingNotification(created);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: SehatKuColors.success, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Booking Berhasil!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SehatKuColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'NOMOR ANTREAN KLINIK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: SehatKuColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    created.queueNumber,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: SehatKuColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Dokter: ${created.doctorName}'),
            Text('Poli: ${created.poli} (${created.room})'),
            Text('Jadwal: ${created.visitDate} • ${created.sessionTime}'),
            Text('Penjamin: ${created.paymentType}'),
            const SizedBox(height: 8),
            const Text(
              'Data pendaftaran telah disimpan ke database lokal SQLite dan tetap tersimpan meski aplikasi ditutup.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(
                context,
                AppRouter.qrTicket,
                arguments: created,
              );
            },
            icon: const Icon(Icons.qr_code_2_rounded, size: 18),
            label: const Text('Lihat QR Antrean'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(created);
            },
            child: const Text('Selesai & Kembali'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicDataProvider>();
    final doc = widget.doctor;
    final isFav = provider.isDoctorFavorite(doc.id);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPad = SehatKuResponsive.horizontalPadding(width);
    final currencyFmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Dokter & Booking'),
        actions: [
          IconButton(
            tooltip: isFav ? 'Hapus dari Favorit' : 'Simpan Dokter Favorit',
            onPressed: () => provider.toggleFavoriteDoctor(doc.id),
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? const Color(0xFFFFCDD2) : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPad, 18, horizontalPad, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Profil Lengkap Dokter
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 78,
                                  height: 78,
                                  color: SehatKuColors.primarySoft,
                                  child: doc.imageUrl.isNotEmpty
                                      ? Image.network(
                                          doc.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Image.asset(
                                            'assets/images/doctor_avatar.png',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/doctor_avatar.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${doc.specialistTitle} • ${doc.poli}',
                                      style: const TextStyle(
                                        color: SehatKuColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No. STR: ${doc.strNumber}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Alumni: ${doc.alumniUniversity}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            doc.bio,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Divider(height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _infoBadge(
                                Icons.meeting_room_outlined,
                                doc.room,
                              ),
                              _infoBadge(
                                Icons.work_history_outlined,
                                '${doc.experienceYears} Tahun Praktik',
                              ),
                              _infoBadge(
                                Icons.payments_outlined,
                                '${currencyFmt.format(doc.consultationFee)} / BPJS',
                              ),
                              _infoBadge(
                                Icons.people_outline,
                                'Kuota Harian: ${doc.quota} Pasien',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pilih Tanggal & Sesi Jam Praktik
                  Text(
                    '1. Pilih Jadwal Kunjungan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hari Praktik Reguler: ${doc.scheduleDays} (${doc.scheduleTime})',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: SehatKuColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _pickVisitDate,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Tanggal Kunjungan',
                                prefixIcon: Icon(Icons.event),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(_selectedDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'Ubah Tanggal',
                                    style: TextStyle(
                                      color: SehatKuColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Pilih Sesi Jam Praktik:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: doc.availableSessions.map((session) {
                              final selected = _selectedSession == session;
                              return ChoiceChip(
                                label: Text(session),
                                selected: selected,
                                selectedColor: SehatKuColors.primary,
                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedSession = session);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Pendaftaran Pasien
                  Text(
                    '2. Data Pendaftaran Pasien',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            key: const Key('booking_name_field'),
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap Pasien',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().length < 3) {
                                return 'Nama pasien minimal 3 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const Key('booking_nik_field'),
                            controller: _nikController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'NIK Pasien (16 Digit)',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().length < 8) {
                                return 'Masukkan NIK atau Nomor identitas yang valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Jenis Penjamin Layanan:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: ['BPJS Kesehatan', 'Pasien Umum'].map((
                              type,
                            ) {
                              final selected = _paymentType == type;
                              return ChoiceChip(
                                label: Text(type),
                                selected: selected,
                                selectedColor: SehatKuColors.primary,
                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _paymentType = type);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const Key('booking_complaint_field'),
                            controller: _complaintController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Keluhan Utama / Tujuan Kontrol',
                              hintText:
                                  'Contoh: Demam 2 hari, kontrol tekanan darah, atau pembersihan karang gigi...',
                              alignLabelWithHint: true,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Mohon tuliskan keluhan singkat pasien';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      key: const Key('submit_booking_button'),
                      onPressed: _isSubmitting ? null : _submitBooking,
                      icon: const Icon(Icons.confirmation_number_outlined),
                      label: Text(
                        _isSubmitting
                            ? 'Menyimpan Pendaftaran...'
                            : 'Konfirmasi Booking & Ambil Nomor Antrean',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: SehatKuColors.primary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
