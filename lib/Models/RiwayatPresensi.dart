class RiwayatPresensi {
  String nip;
  String? tgl_presensi;
  String? presensi_masuk;
  int? status_masuk;
  String? presensi_pulang;
  int? status_pulang;
  String? izin;
  int? status_izin;
  String? alasan;

  RiwayatPresensi({
    required this.nip,
    required this.tgl_presensi,
    required this.presensi_masuk,
    required this.status_masuk,
    required this.presensi_pulang,
    required this.status_pulang,
    required this.izin,
    required this.status_izin,
    required this.alasan,
  });

  factory RiwayatPresensi.fromJson(Map<dynamic, dynamic> json) {
    return new RiwayatPresensi(
        nip: json['nip'],
        tgl_presensi: json['tgl_presensi'],
        presensi_masuk: json['presensi_masuk'],
        status_masuk: json['status_masuk'],
        presensi_pulang: json['presensi_pulang'],
        status_pulang: json['status_pulang'],
        izin: json['izin'],
        status_izin: json['status_izin'],
        alasan: json['alasan'],
        );
  }
}
