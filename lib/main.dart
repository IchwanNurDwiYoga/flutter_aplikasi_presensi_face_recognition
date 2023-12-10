import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/RiwayatPresensi.dart';
import 'package:flutter_application_4/pages/homePage.dart';
import 'package:flutter_application_4/pages/splashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreeen(),
    );
  }
}

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  TextEditingController nip = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Align(
          alignment: Alignment(0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nip,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RiwayatPresensiPage(nip: nip.text),
                        ));
                  },
                  child: Text('Cari'))
            ],
          )),
    );
  }
}
