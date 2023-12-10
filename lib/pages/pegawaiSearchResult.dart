import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_4/Models/Pegawai.dart';
import 'package:flutter_application_4/configs/api.dart';
import 'package:flutter_application_4/pages/face_recognition.dart';
import 'package:http/http.dart' as http;

class PegawaiSearchResultPage extends StatefulWidget {
  String nip;
  PegawaiSearchResultPage({super.key, required this.nip});

  @override
  State<PegawaiSearchResultPage> createState() =>
      _PegawaiSearchResultPageState();
}

class _PegawaiSearchResultPageState extends State<PegawaiSearchResultPage> {
  late List<Pegawai> _list = [];
  var loading = false;
  bool isButtonActive = false;
  Future<Null> fetchData() async {
    setState(() {
      loading = true;
    });
    final response = await http
        .get(Uri.parse(Api().API_END_POINT + "/pegawai/cari/" + widget.nip));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (Map i in data) {
          _list.add(Pegawai.fromJson(i));
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Cari Pegawai'),
      ),
      body: SafeArea(
          child: Container(
              child: loading
                  ? Align(
                      alignment: Alignment(0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          Text('Memuat Data...')
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        final a = _list[index];
                        return Container(
                          margin: EdgeInsets.all(10),
                          child: Card(
                            elevation: 5,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              // decoration: BoxDecoration(color: Colors.grey),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Nama'),
                                      Text('NIP'),
                                      Text('Jenis Kelamin'),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(' : '),
                                      Text(' : '),
                                      Text(' : '),
                                    ],
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(a.nama),
                                        Text(a.nip),
                                        Text(a.jenis_kelamin),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width:
                                  //       MediaQuery.of(context).size.width / 20,
                                  // ),
                                  Container(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (a.nip.toLowerCase() ==
                                              'tidak ditemukan') {
                                            setState(() {
                                              null;
                                            });
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FaceRecognitionView(
                                                          nip: a.nip),
                                                ));
                                          }
                                        },
                                        child: Image.asset(
                                          'assets/icon/face-id.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              25,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ))),
    );
  }
}
