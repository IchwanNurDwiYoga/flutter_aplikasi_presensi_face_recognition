import 'dart:convert';
import 'package:flutter_application_4/configs/api.dart';
import 'package:http/http.dart' as http;

class PresensiMasuk {
  String nip;
  String lat;
  String long;
  String kode_presensi;

  PresensiMasuk({required this.nip, required this.lat, required this.long, required this.kode_presensi});

  
}
