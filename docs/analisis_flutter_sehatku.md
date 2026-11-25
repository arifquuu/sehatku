# Analisis Pemilihan Teknologi Flutter & Manajemen State — SehatKu

**Disusun oleh:** Evan (QA, Dokumentasi & Fitur Dasar — Kelompok 4)  
**Mata Kuliah:** Pengembangan Aplikasi Perangkat Bergerak (A) — FMIPA UNTAN  

---

## 1. Alasan Memilih Flutter untuk Aplikasi SehatKu

Aplikasi **SehatKu** dirancang untuk melayani pendaftaran antrean poliklinik dan pencatatan rekam medis ringkas di klinik pratama. Kebutuhan utama klinik mencakup ketersediaan aplikasi pada perangkat pasien (**Android**) sekaligus akses cepat di meja administrasi atau peramban (**Flutter Web**). Flutter dipilih karena alasan teknis berikut:

1. **Single Codebase Multi-Platform (Android & Web):** Dengan satu basis kode Dart di folder `lib/`, tim dapat membangun APK Android (`v1.0.0`) sekaligus bundel Flutter Web tanpa menulis ulang logika bisnis maupun antarmuka.
2. **Konsistensi Desain Material 3 & Responsivitas:** Flutter menyediakan sistem widget deklaratif (`Scaffold`, `LayoutBuilder`, `GridView`, `ListView`, `NavigationBar`) yang memudahkan penerapan tema warna klinis (`SehatKuColors.primary` Teal `#0D9488`) serta mode terang/gelap (`SehatKuTheme.lightTheme` & `darkTheme`) pada layar sempit (390 px) hingga tablet/desktop (`>= 650 px`).
3. **Ekosistem Paket Siap Produksi:** Kebutuhan SehatKu terpenuhi langsung oleh paket komunitas yang matang, seperti `provider` (state management), `sqflite` & `hive_flutter` (penyimpanan lokal *offline-first*), `http` (REST API & backend PHP/MySQL), `flutter_local_notifications` (pengingat kontrol), `image_picker` (lampiran foto dokumen medis), dan `qr_flutter` (tiket antrean QR).
4. **Hot Reload & Produktivitas Tim Paralel:** Sistem kerja berderet paralel antara Lead Developer (Arif), UI/UX & Data (Fajri), serta QA & Fitur Dasar (Evan) sangat terbantu oleh *hot reload* untuk menguji tata letak responsif dan perbaikan bug UI secara cepat.

---

## 2. Perbandingan Flutter vs Native (Kotlin/Android Studio) vs Framework Lain

| Aspek Penilaian | Flutter (Dart) | Native Android (Kotlin / Jetpack Compose) | React Native (JavaScript / TypeScript) | Ionic / Hybrid WebView |
| :--- | :--- | :--- | :--- | :--- |
| **Target Platform** | Android, iOS, Web, Desktop dari 1 kode | Hanya Android (butuh Swift/Web terpisah) | Android & iOS (Web butuh konfigurasi ekstra) | Web & Mobile via WebView |
| **Performa Rendering** | Tinggi (Impeller / Skia langsung ke GPU) | Tertinggi (akses langsung API OS Android) | Baik, namun bergantung *bridge*/JSI | Sedang (terbatas performa WebView) |
| **Konsistensi UI** | Identik di semua perangkat & versi OS | Mengikuti komponen Material/OEM perangkat | Mengikuti komponen native masing-masing OS | Mengikuti CSS/HTML browser |
| **Kesiapan Offline-First & DB** | Sangat baik (`sqflite`, `hive`, `shared_preferences`) | Sangat baik (Room, DataStore) | Baik (SQLite/MMKV pihak ketiga) | Terbatas (IndexedDB / Capacitor plugin) |
| **Efisiensi Tim 3 Orang** | **Optimal** untuk proyek PBL 1 semester | Memerlukan usaha ganda jika butuh versi Web | Cukup baik, namun rawan konflik dependensi native | Cepat untuk web, kurang terasa native |

**Kesimpulan Pemilihan:** Untuk skala proyek **SehatKu** dengan tim 3 mahasiswa yang membutuhkan rilis Android APK sekaligus Web demo, **Flutter** memberikan keseimbangan terbaik antara kecepatan pengembangan, konsistensi UI, dan performa.

---

## 3. Analisis Manajemen State: Kapan `setState` Cukup dan Kapan Tidak (Tugas 6)

Pada aplikasi SehatKu, manajemen state dibagi menjadi dua tingkatan sesuai cakupan datanya:

### A. Kapan `setState` Cukup?
`setState` sudah cukup untuk **ephemeral state** (state lokal sementara) yang hanya memengaruhi satu widget mandiri dan tidak perlu dibagikan ke halaman lain.  
Contoh di SehatKu adalah **`ClinicPrepChecklistWidget`** (`lib/widgets/clinic_prep_checklist_widget.dart`) pada halaman Detail Dokter & Booking:
- Menyimpan status centang checklist persiapan berkas (KTP, kartu BPJS, daftar obat).
- Mengatur angka simulasi antrean di depan (`_queuesAhead`) untuk menghitung estimasi waktu tunggu.
- Mengatur status buka/tutup panel (`_expanded`).

Data tersebut bersifat lokal di kartu tersebut, sehingga memakai `StatefulWidget` + `setState` jauh lebih ringkas, mudah diuji lewat widget test, dan tidak membebani state global.

### B. Kapan `setState` Tidak Cukup?
`setState` **tidak cukup** apabila data harus:
1. **Dibagikan lintas halaman (Shared App State):** Misalnya status login pasien (`AuthProvider`), daftar booking aktif yang muncul di Beranda sekaligus Tab Antrean & Tiket QR, atau daftar dokter favorit yang berubah di Beranda/Jadwal dan harus langsung sinkron di Tab Profil.
2. **Terhubung ke I/O Persisten & Jaringan:** Seperti sinkronisasi SQLite, Hive, SharedPreferences, dan REST API yang membutuhkan *loading state*, *error state*, serta notifikasi pembaruan ke banyak widget sekaligus.

Untuk kebutuhan tersebut, SehatKu menggunakan **`ChangeNotifier` + `MultiProvider`** (`AuthProvider` dan `ClinicDataProvider`) dengan `context.watch` / `Consumer` / `Selector` agar perubahan data di satu layar otomatis memperbarui layar lain secara konsisten.
