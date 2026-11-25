import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehatku/utils/patient_validator.dart';
import 'package:sehatku/widgets/clinic_prep_checklist_widget.dart';

void main() {
  group('Tugas 13 — Unit Test Validasi & Kalkulasi Pasien (Evan)', () {
    test('Unit Test 1: Validasi NIK 16 digit dan nama lengkap pasien', () {
      expect(PatientValidator.validateNik('6171031504040001'), isNull);
      expect(PatientValidator.validateNik(''), isNotNull);
      expect(PatientValidator.validateNik('12345'), contains('16 digit'));
      expect(PatientValidator.validateNik('617103150404ABCD'), contains('16 digit'));

      expect(PatientValidator.validatePatientName('Evan Pratama'), isNull);
      expect(PatientValidator.validatePatientName(' '), isNotNull);
      expect(PatientValidator.validatePatientName('Ev'), contains('minimal 3'));
    });

    test('Unit Test 2: Hitung estimasi biaya konsultasi & waktu tunggu antrean', () {
      expect(
        PatientValidator.calculateConsultationEstimate(
          baseFee: 85000,
          isBpjs: false,
        ),
        95000,
      );
      expect(
        PatientValidator.calculateConsultationEstimate(
          baseFee: 85000,
          isBpjs: true,
        ),
        0,
      );
      expect(
        () => PatientValidator.calculateConsultationEstimate(
          baseFee: -5000,
          isBpjs: false,
        ),
        throwsArgumentError,
      );

      expect(PatientValidator.estimateQueueWaitMinutes(queuesAhead: 4), 40);
      expect(PatientValidator.estimateQueueWaitMinutes(queuesAhead: 0), 0);
    });

    test('Unit Test 3: Cek ketersediaan jadwal & sisa kuota dokter', () {
      expect(
        PatientValidator.isScheduleSlotAvailable(
          remainingQuota: 5,
          isDoctorAvailable: true,
        ),
        isTrue,
      );
      expect(
        PatientValidator.isScheduleSlotAvailable(
          remainingQuota: 0,
          isDoctorAvailable: true,
        ),
        isFalse,
      );
      expect(
        PatientValidator.isScheduleSlotAvailable(
          remainingQuota: 10,
          isDoctorAvailable: false,
        ),
        isFalse,
      );
    });

    test('TDD Test: formatQueueNumber memformat kode poli & padding 3 digit', () {
      expect(
        PatientValidator.formatQueueNumber(poliCode: 'a', sequenceNumber: 7),
        'A-007',
      );
      expect(
        PatientValidator.formatQueueNumber(poliCode: ' c ', sequenceNumber: 25),
        'C-025',
      );
      expect(
        () => PatientValidator.formatQueueNumber(
          poliCode: '',
          sequenceNumber: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => PatientValidator.formatQueueNumber(
          poliCode: 'B',
          sequenceNumber: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Tugas 13 — Widget Test Komponen setState Evan', () {
    testWidgets(
      'ClinicPrepChecklistWidget memperbarui badge checklist, estimasi antrean, dan collapse',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ClinicPrepChecklistWidget(),
              ),
            ),
          ),
        );

        // Kondisi awal: 1 dari 3 item tercentang, 3 antrean = 30 menit
        expect(find.byKey(const Key('evan_clinic_prep_card')), findsOneWidget);
        expect(find.text('1/3 siap'), findsOneWidget);
        expect(find.text('Antrean di depan: 3 • Est. 30 menit'), findsOneWidget);

        // Centang item kedua -> menjadi 2/3 siap
        await tester.tap(
          find.byKey(
            const Key('evan_check_Kartu BPJS / Rujukan (jika peserta JKN)'),
          ),
        );
        await tester.pump();
        expect(find.text('2/3 siap'), findsOneWidget);

        // Tambah antrean di depan -> menjadi 4 antrean (40 menit)
        await tester.tap(find.byKey(const Key('evan_queue_plus_btn')));
        await tester.pump();
        expect(find.text('Antrean di depan: 4 • Est. 40 menit'), findsOneWidget);

        // Kurangi antrean -> kembali 3 antrean (30 menit)
        await tester.tap(find.byKey(const Key('evan_queue_minus_btn')));
        await tester.pump();
        expect(find.text('Antrean di depan: 3 • Est. 30 menit'), findsOneWidget);

        // Collapse detail checklist
        await tester.tap(find.byKey(const Key('evan_prep_expand_btn')));
        await tester.pump();
        expect(
          find.byKey(const Key('evan_wait_estimate_text')),
          findsNothing,
        );
      },
    );
  });
}
