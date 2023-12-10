import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_4/pages/pegawaiSearchResult.dart';

class PegawaiSearchPage extends StatefulWidget {
  const PegawaiSearchPage({super.key});

  @override
  State<PegawaiSearchPage> createState() => _PegawaiSearchPageState();
}

class _PegawaiSearchPageState extends State<PegawaiSearchPage> {
  var nip = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cari Pegawai'),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'Cek NIP Anda Dahulu',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: nip,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), label: Text('NIP')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PegawaiSearchResultPage(nip: nip.text),
                          ));
                    } else {}
                  },
                  child: Text('Cari NIP')),
            )
          ],
        ),
      )),
    );
  }
}
