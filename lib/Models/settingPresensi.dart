import 'dart:convert';

import 'package:flutter_application_4/configs/api.dart';
import 'package:http/http.dart' as http;

class SettingPresensi {
  SettingPresensi({required this.jam_masuk, required this.jam_pulang});
  String? jam_masuk;
  String? jam_pulang;

  factory SettingPresensi.fromJson(Map<String, dynamic> json) {
    return SettingPresensi(
        jam_masuk: json['jam_masuk'], jam_pulang: json['jam_pulang']);
  }
}

Future<SettingPresensi> fetchSettingPresensi() async {
  final response = await http.get(Uri.parse(Api().API_END_POINT + "/setting"));
  if (response.statusCode == 200) {
    return SettingPresensi.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 522) {
    throw Exception('Keneksi Kehabisan Waktu');
  } else {
    throw Exception('Gagal');
  }
}
