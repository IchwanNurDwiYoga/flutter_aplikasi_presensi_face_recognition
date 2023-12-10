import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_4/pages/PengajuanIzin.dart';
import 'package:flutter_application_4/pages/menu.dart';
import 'package:flutter_application_4/pages/presensiMasuk.dart';
import 'package:flutter_application_4/pages/presensiPulang.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:trust_location/trust_location.dart';

import '../Models/Presensi.dart';
import '../Models/settingPresensi.dart';
import '../services/locationPermission.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _latitude = 0;
  double _longitude = 0;
  bool isLoading = true;
  String? _address;
  final MapController _mapController = MapController();
  late Future<Presensi> futurePresensi;
  late Future<SettingPresensi> futureSettingPresensi;

  Future<void> getLocation() async {
    final hasPermisson = await requestPermission();
    if (hasPermisson != null) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Permission Denied'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const [
                    Text(
                        "Tanpa izin penggunaan lokasi aplikasi ini tidak dapat digunakan dengan baik. Apa anda yakin menolak izin pengaktifan lokasi?",
                        style: TextStyle(fontSize: 18.0)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('COBA LAGI'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    requestPermission();
                  },
                ),
                TextButton(
                  child: const Text('SAYA YAKIN'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else {
      //get Location
      TrustLocation.start(5);
      try {
        TrustLocation.onChange.listen((values) {
          var mockStatus = values.isMockLocation;
          if (mockStatus == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Fake GPS terdeteksi. Mohon non aktifkan fitur Fake GPS Anda'),
            ));
            TrustLocation.stop();
            return;
          }

          if (mounted) {
            setState(() {
              isLoading = false;
              _latitude = double.parse(values.latitude.toString());
              _longitude = double.parse(values.longitude.toString());

              _mapController.move(LatLng(_latitude, _longitude), 13);

              getPlace();
            });
          }
        });
      } on PlatformException catch (e) {
        debugPrint('PlatformException $e');
      }
    }
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  void initState() {
    requestPermission();
    getLocation();
    futurePresensi = fetchPresensi();
    futureSettingPresensi = fetchSettingPresensi();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget displayMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
          center: LatLng(_latitude, _longitude), zoom: 15, maxZoom: 19),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(markers: [
          Marker(
            height: 40.0,
            width: 40.0,
            point: LatLng(_latitude, _longitude),
            builder: (context) => Icon(
              Icons.fmd_good,
              color: Colors.redAccent,
              size: 20.0,
            ),
          )
        ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Stack(children: [
            Container(
              margin: EdgeInsets.all(0),
              height: screenSize.height / 1.5,
              child: displayMap(),
            ),
          ]),
          Stack(
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuPage(),
                              ));
                        },
                        icon: const Icon(Icons.list),
                        label: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              "Menu",
                              style: TextStyle(fontSize: 16),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlue,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Home(),
                              ));
                          setState(() {
                            isLoading = true;
                          });
                        },
                        icon: const Icon(Icons.replay_rounded),
                        label: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              "Muat Ulang Halaman",
                              style: TextStyle(fontSize: 16),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: screenSize.height / 3.5,
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 60),
                      decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3))
                          ]),
                      child: Center(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: isLoading ? true : false,
                              child: const CircularProgressIndicator(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            isLoading
                                ? Text("Sedang mencari lokasi...")
                                : Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat.yMMMMEEEEd('en_US')
                                                .format(DateTime.now()),
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FutureBuilder<SettingPresensi>(
                                            future: futureSettingPresensi,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          snapshot
                                                              .data!.jam_masuk
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 28,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          'Jam Masuk',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              5,
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          snapshot
                                                              .data!.jam_pulang
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 28,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          'Jam Pulang',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    "${snapshot.hasError}");
                                              }
                                              return Column(
                                                children: [
                                                  const CircularProgressIndicator(),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FutureBuilder<Presensi>(
                                                future: futurePresensi,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    if (snapshot.data!
                                                            .kode_presensi !=
                                                        null) {
                                                      return Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PresensiMasukPage(
                                                                            kode_presensi:
                                                                                snapshot.data!.kode_presensi.toString(),
                                                                            latitude:
                                                                                _latitude.toString(),
                                                                            longitude:
                                                                                _longitude.toString(),
                                                                          ),
                                                                        ));
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green),
                                                                  child: Text(
                                                                    'Hadir',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )),
                                                              SizedBox(
                                                                // child: Text(snapshot
                                                                //     .data!
                                                                //     .kode_presensi!),
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    5,
                                                              ),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) => PresensiPulangPage(
                                                                              kode_presensi: snapshot.data!.kode_presensi.toString(),
                                                                              latitude: _latitude.toString(),
                                                                              longitude: _longitude.toString()),
                                                                        ));
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red),
                                                                  child: Text(
                                                                    'Pulang',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )),
                                                            ],
                                                          ),
                                                          Align(
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  1.7,
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .push(MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PengajuanIzinPage(kode_presensi: snapshot.data!.kode_presensi.toString()),
                                                                        ));
                                                                      },
                                                                      style: ElevatedButton.styleFrom(
                                                                          backgroundColor: Colors.amber[
                                                                              600]),
                                                                      child:
                                                                          Text(
                                                                        'Izin',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )),
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    } else {
                                                      return Column(
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                              'Menunggu daftar presensi dibuat...')
                                                        ],
                                                      );
                                                    }
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Container();
                                                  } else {
                                                    return Text('');
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment(0, 0.3),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  // child:
                ),
              ),
              Align(
                alignment: Alignment(0, 0.15),
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  // hild:
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void getPlace() async {
    List<Placemark> newPlace =
        await placemarkFromCoordinates(_latitude, _longitude);

    Placemark placemark = newPlace[0];
    String name = placemark.name.toString();
    String sublocality = placemark.subLocality.toString();
    String locality = placemark.locality.toString();
    String administrativeArea = placemark.administrativeArea.toString();
    String address = "$name, $sublocality, $locality, $administrativeArea";

    setState(() {
      _address = address;
    });
  }
}
