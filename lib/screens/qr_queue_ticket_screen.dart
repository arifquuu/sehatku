import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/booking_model.dart';
import '../providers/clinic_data_provider.dart';
import '../services/notification_service.dart';
import '../theme/sehatku_theme.dart';

class QrQueueTicketScreen extends StatelessWidget {
  final BookingAppointment booking;

  const QrQueueTicketScreen({
    super.key,
    required this.booking,
  });

  static String buildQrPayload(
    BookingAppointment booking, {
    String rmNumber = '',
  }) {
    return jsonEncode({
      'app': 'SehatKu',
      'queue': booking.queueNumber,
      if (rmNumber.isNotEmpty) 'rm': rmNumber,
      'patient': booking.patientName,
      'nik': booking.patientNik,
      'doctor': booking.doctorName,
      'poli': booking.poli,
      'room': booking.room,
      'date': booking.visitDate,
      'session': booking.sessionTime,
      'payment': booking.paymentType,
      'status': booking.status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rmNumber = context.select<ClinicDataProvider, String>(
      (p) => p.patientProfile['rmNumber'] ?? '',
    );
    final payload = buildQrPayload(booking, rmNumber: rmNumber);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPad = SehatKuResponsive.horizontalPadding(width);
    final subtleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);

    return Scaffold(
      appBar: AppBar(title: const Text('Tiket QR Antrean Klinik')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPad, 20, horizontalPad, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: SehatKuColors.primaryDark,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NOMOR ANTREAN',
                                    style: TextStyle(
                                      color: Color(0xFFCCFBF1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    booking.queueNumber,
                                    key: const Key('qr_queue_number_text'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${booking.poli} (${booking.room})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                booking.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // White quiet zone keeps QR scannable in dark mode.
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: QrImageView(
                                key: const Key('qr_queue_image'),
                                data: payload,
                                version: QrVersions.auto,
                                size: 210,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Color(0xFF0F172A),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tunjukkan kode QR ini di meja registrasi klinik untuk check-in otomatis tanpa antre ulang.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: subtleColor,
                              ),
                            ),
                            const Divider(height: 28),
                            _detailRow('Pasien', booking.patientName, subtleColor),
                            if (rmNumber.isNotEmpty)
                              _detailRow('No. Rekam Medis', rmNumber, subtleColor),
                            _detailRow('NIK', booking.patientNik, subtleColor),
                            _detailRow('Dokter', booking.doctorName, subtleColor),
                            _detailRow(
                              'Tanggal & Sesi',
                              '${booking.visitDate}, ${booking.sessionTime}',
                              subtleColor,
                            ),
                            _detailRow(
                              'Penjamin',
                              booking.paymentType,
                              subtleColor,
                            ),
                            _detailRow('Keluhan', booking.complaint, subtleColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          key: const Key('qr_copy_button'),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text:
                                    'Tiket Antrean ${booking.queueNumber} - ${booking.doctorName} (${booking.poli}, ${booking.visitDate} ${booking.sessionTime})',
                              ),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kode antrean disalin ke clipboard.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          label: const Text('Salin Kode'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          key: const Key('qr_notify_button'),
                          onPressed: () async {
                            final result = await NotificationService.instance
                                .showBookingNotification(booking);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result.message)),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_active_outlined,
                            size: 18,
                          ),
                          label: const Text('Ingatkan'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
