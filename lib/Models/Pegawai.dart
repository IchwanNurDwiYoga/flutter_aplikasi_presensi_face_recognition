class Pegawai {
  String nip;
  String nama;
  String jenis_kelamin;

  Pegawai({
    required this.nip,
    required this.nama,
    required this.jenis_kelamin,
  });

  factory Pegawai.fromJson(Map<dynamic, dynamic> json) {
    return new Pegawai(
        nip: json['nip'],
        nama: json['nama'],
        jenis_kelamin: json['jenis_kelamin']);
  }
}
