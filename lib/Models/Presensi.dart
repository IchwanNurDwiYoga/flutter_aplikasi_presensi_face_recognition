import 'dart:convert';
import 'package:flutter_application_4/configs/api.dart';
import 'package:http/http.dart' as http;

class Presensi {
  Presensi({required this.kode_presensi});
  String? kode_presensi;

  factory Presensi.fromJson(Map<String, dynamic> json) {
    return Presensi(kode_presensi: json['kode_presensi']);
  }
}

Future<Presensi> fetchPresensi() async {
  final response =
      await http.get(Uri.parse(Api().API_END_POINT + "/pegawai/presensi/"));

  if (response.statusCode == 200) {
    return Presensi.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal');
  }
}
