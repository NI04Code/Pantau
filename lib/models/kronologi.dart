class Kronologi {
  final DateTime tanggal;
  final String judul;
  final String konten;

  Kronologi({required this.tanggal, required this.judul, required this.konten});

  Map<String, dynamic> toMap() {
    return {
      'tanggal': tanggal.toIso8601String(),
      'judul': judul,
      'konten': konten,
    };
  }

  factory Kronologi.fromMap(Map<String, dynamic> map) {
    return Kronologi(
      tanggal: DateTime.parse(map['tanggal']),
      judul: map['judul'],
      konten: map['konten'],
    );
  }
}
