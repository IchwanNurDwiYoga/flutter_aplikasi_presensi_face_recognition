import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_4/pages/CekRiwayatPresensi.dart';
import 'package:flutter_application_4/pages/PegawaiSearchPage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PegawaiSearchPage(),
                        ));
                  },
                  child: Card(
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/icon/face-id.svg'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Pendaftaran Wajah',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CekRiwayatPresensi(),
                        ));
                  },
                  child: Card(
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(Icons.date_range_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Riwayat Presensi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )),
            )
          ],
        ),
      )),
    );
  }
}
