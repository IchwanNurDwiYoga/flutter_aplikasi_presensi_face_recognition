import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_4/Models/RiwayatPresensi.dart';
import 'package:flutter_application_4/configs/api.dart';
import 'package:http/http.dart' as http;

class RiwayatPresensiPage extends StatefulWidget {
  String nip;
  RiwayatPresensiPage({super.key, required this.nip});

  @override
  State<RiwayatPresensiPage> createState() => _RiwayatPresensiPageState();
}

class _RiwayatPresensiPageState extends State<RiwayatPresensiPage> {
  late List<RiwayatPresensi> _list = [];
  var loading = false;

  Future<Null> fetchData() async {
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(
        Api().API_END_POINT + "/pegawai/riwayat/" + widget.nip.toString()));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map i in data) {
          _list.add(RiwayatPresensi.fromJson(i));
          loading = false;
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Riwayat Presensi'),
          bottom: TabBar(tabs: [
            Tab(child: Text('Presensi Masuk')),
            Tab(child: Text('Presensi Pulang')),
            Tab(child: Text('Pengajuan Izin')),
          ]),
        ),
        floatingActionButton: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiwayatPresensiPage(nip: widget.nip),
                  ));
            },
            child: Icon(Icons.refresh)),
        body: SafeArea(
          child: Container(
            alignment: Alignment(0, 0),
            child: loading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text("Memuat Data")
                    ],
                  )
                : TabBarView(children: [
                    ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        final a = _list[index];
                        return Container(
                          child: Card(
                            elevation: 5,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Tanggal'),
                                          Text('NIP'),
                                          Text('Masuk'),
                                          Text('Status Masuk'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(" : "),
                                          Text(" : "),
                                          Text(" : "),
                                          Text(" : "),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(a.tgl_presensi.toString()),
                                          Text(a.nip),
                                          Text((() {
                                            if (a.presensi_masuk.toString() !=
                                                'null') {
                                              return a.presensi_masuk
                                                  .toString();
                                            }
                                            return 'Belum masuk';
                                          })()),
                                          Text((() {
                                            if (a.status_masuk.toString() ==
                                                '1') {
                                              return "terlambat";
                                            } else if (a.status_masuk
                                                    .toString() ==
                                                '0') {
                                              return 'Tepat Waktu';
                                            }
                                            return "Belum Masuk";
                                          })()),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        final a = _list[index];
                        return Container(
                          child: Card(
                            elevation: 5,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Tanggal'),
                                          Text('NIP'),
                                          Text('Pulang'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(" : "),
                                          Text(" : "),
                                          Text(" : "),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(a.tgl_presensi.toString()),
                                          Text(a.nip),
                                          Text((() {
                                            if (a.presensi_pulang.toString() !=
                                                'null') {
                                              return a.presensi_pulang
                                                  .toString();
                                            }
                                            return 'Belum pulang';
                                          })()),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        final a = _list[index];
                        return Container(
                          child: Card(
                            elevation: 5,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Tanggal'),
                                          Text('NIP'),
                                          Text('Pengajuan Izin'),
                                          Text('Status Pengajuan'),
                                          Text('Alasan'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(" : "),
                                          Text(" : "),
                                          Text(" : "),
                                          Text(" : "),
                                          Text(" : "),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(a.tgl_presensi.toString()),
                                          Text(a.nip),
                                          Text((() {
                                            if (a.izin.toString() != 'null') {
                                              return a.izin.toString();
                                            }
                                            return 'Tidak Mengajukan Izin';
                                          })()),
                                          Text((() {
                                            if (a.status_izin.toString() ==
                                                '1') {
                                              return "Menunggu Persetujuan";
                                            } else if (a.status_izin
                                                    .toString() ==
                                                '2') {
                                              return 'Diterima';
                                            } else if (a.status_izin
                                                    .toString() ==
                                                '3') {
                                              return 'Ditolak';
                                            }
                                            return "Tidak Mengajukan Izin";
                                          })()),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Text(
                                              (() {
                                                if (a.alasan != null) {
                                                  return a.alasan!;
                                                }
                                                return '-';
                                              })(),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}
