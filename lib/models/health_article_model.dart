class HealthArticle {
  final int id;
  final String title;
  final String summary;
  final List<String> tags;
  final int views;

  const HealthArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.tags,
    required this.views,
  });

  static const List<Map<String, String>> _indonesianMedicalTopics = [
    {
      'title': 'Panduan Persiapan Pemeriksaan Laboratorium & Puasa Medis',
      'tag': 'Edukasi Klinik',
    },
    {
      'title': 'Pentingnya Kontrol Tekanan Darah Rutin bagi Pasien Hipertensi',
      'tag': 'Penyakit Dalam',
    },
    {
      'title': 'Jadwal Imunisasi Dasar Lengkap Anak Usia 0–24 Bulan',
      'tag': 'Poli Anak',
    },
    {
      'title': 'Cara Menjaga Kesehatan Email Gigi & Pencegahan Karang Gigi',
      'tag': 'Poli Gigi',
    },
    {
      'title': 'Tips Mengatasi Gejala Maag & GERD Saat Aktivitas Padat',
      'tag': 'Gaya Hidup',
    },
    {
      'title': 'Kapan Harus Periksa THT & Mata Akibat Paparan Layar Gawai?',
      'tag': 'Mata & THT',
    },
  ];

  factory HealthArticle.fromApiJson(Map<String, dynamic> json, {int index = 0}) {
    final topic =
        _indonesianMedicalTopics[index % _indonesianMedicalTopics.length];
    final rawBody = (json['body'] ?? '').toString();
    final rawId = (json['id'] as num?)?.toInt() ?? (index + 1);
    final rawViews = (json['views'] as num?)?.toInt() ?? (120 + index * 35);
    final apiTags = json['tags'] is List
        ? (json['tags'] as List).map((e) => e.toString()).toList()
        : <String>[];

    return HealthArticle(
      id: rawId,
      title: topic['title']!,
      summary: rawBody.isNotEmpty
          ? 'Referensi API (#$rawId): $rawBody'
          : 'Pastikan Anda membawa kartu identitas/BPJS dan datang 15 menit sebelum sesi praktik dimulai.',
      tags: [topic['tag']!, ...apiTags.take(2)],
      views: rawViews,
    );
  }
}
