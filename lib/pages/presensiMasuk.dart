import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_4/configs/api.dart';
import 'package:flutter_application_4/faceModule/model.dart';
import 'package:flutter_application_4/faceModule/utils.dart';
import 'package:flutter_application_4/pages/homePage.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quiver/collection.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../faceModule/detector.dart';

class PresensiMasukPage extends StatefulWidget {
  String latitude;
  String longitude;
  String kode_presensi;

  PresensiMasukPage(
      {super.key,
      required this.kode_presensi,
      required this.latitude,
      required this.longitude});

  @override
  State<PresensiMasukPage> createState() => _PresensiMasukPageState();
}

class _PresensiMasukPageState extends State<PresensiMasukPage>
    with WidgetsBindingObserver {
  final _formState = GlobalKey<FormState>();
  final nipController = TextEditingController();
  final lat = TextEditingController();
  final long = TextEditingController();
  late File jsonFile;
  var interpreter;
  dynamic data = {};
  bool _isDetecting = false;
  CameraController? _camera;
  bool loading = true;
  Directory? tempDir;
  bool _faceFound = false;
  String _predRes = '';
  double threshold = 0.9;
  List? e1;
  bool _verify = false;
  dynamic _scanResults;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _start();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    if (_camera != null) {
      await _camera!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      await _camera!.dispose();
      _camera = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Isi Presensi Masuk'),
        automaticallyImplyLeading: false,
      ),
      body: Builder(
        builder: (context) {
          if ((_camera == null || !_camera!.value.isInitialized) || loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SafeArea(
              child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.5,
                child: _camera == null
                    ? Center(
                        child: SizedBox(),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CameraPreview(_camera!),
                          _buildResults()
                        ],
                      ),
              ),
              Stack(children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 4,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 7,
                              offset: Offset(0, 3))
                        ]),
                    child: Form(
                        key: _formState,
                        child: Column(
                          children: [
                            TextFormField(
                              readOnly: true,
                              controller: nipController..text = _predRes,
                              keyboardType: TextInputType.numberWithOptions(),
                              validator: (value) {
                                if (value == null ||
                                    value.toLowerCase() == 'tidak dikenali') {
                                  return ' Tidak Dikenal';
                                }
                              },
                              decoration: InputDecoration(
                                  label: Text('NIP'),
                                  border: OutlineInputBorder()),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_formState.currentState!.validate()) {
                                        updatePresensi().then((value) async {
                                          await Future.delayed(
                                              Duration(seconds: 2));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child:
                                                          Text('Berhasil'))));
                                        });
                                      } else {}
                                    },
                                    child: Text('Masuk'))),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (_camera != null) {
                                        await _camera!.stopImageStream();
                                        await Future.delayed(
                                            const Duration(milliseconds: 1000));
                                        await _camera!.dispose();
                                        await Future.delayed(
                                            const Duration(milliseconds: 1000));
                                        _camera = null;
                                      }
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => Home(),
                                      ));
                                    },
                                    child: Text('Kembali')))
                          ],
                        )),
                  ),
                ),
              ])
            ],
          ));
        },
      ),
    );
  }

  Future updatePresensi() async {
    final response = await http.put(
        Uri.parse(Api().API_END_POINT +
            "/pegawai/presensi/masuk/${widget.kode_presensi}"),
        body: {
          "nip": nipController.text,
          'lat_masuk': widget.latitude,
          'long_masuk': widget.longitude
        });

    return jsonDecode(response.body);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    return directory.path;
  }

  void initialCamera() async {
    CameraDescription description =
        await getCamera(CameraLensDirection.front); //camera depan;

    _camera = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _camera!.initialize();
    await Future.delayed(const Duration(milliseconds: 500));
    loading = false;
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    jsonFile = File(_embPath);
    // jsonFile = await File.fromUri(Uri.parse(
    //     "file:https://presensiapp-facerecognition.my.id/assets/face_db/face.json"));
    if (jsonFile.existsSync()) {
      data = json.decode(jsonFile.readAsStringSync());
    print(data);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _camera!.startImageStream((CameraImage image) async {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        dynamic finalResult = Multimap<String, Face>();

        detect(image, getDetectionMethod()).then((dynamic result) async {
          if (result.length == 0 || result == null) {
            _faceFound = false;
            _predRes = 'Tidak dikenali';
          } else {
            _faceFound = true;
          }

          String res;
          Face _face;

          imglib.Image convertedImage =
              convertCameraImage(image, CameraLensDirection.front);

          for (_face in result) {
            double x, y, w, h;
            x = (_face.boundingBox.left - 10);
            y = (_face.boundingBox.top - 10);
            w = (_face.boundingBox.width + 10);
            h = (_face.boundingBox.height + 10);
            imglib.Image croppedImage = imglib.copyCrop(
                convertedImage, x.round(), y.round(), w.round(), h.round());
            croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
            res = recog(croppedImage);
            finalResult.add(res, _face);
          }

          _scanResults = finalResult;
          _isDetecting = false;
          setState(() {});
        }).catchError(
          (_) async {
            print({'error': _.toString()});
            _isDetecting = false;
            if (_camera != null) {
              await _camera!.stopImageStream();
              await Future.delayed(const Duration(milliseconds: 1000));
              await _camera!.dispose();
              await Future.delayed(const Duration(milliseconds: 1000));
              _camera = null;
            }
            Navigator.pop(context);
          },
        );
      }
    });
  }

  void _start() async {
    interpreter = await loadModel();
    initialCamera();
  }

  String recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1!);
  }

  String compare(List currEmb) {
    //mengembalikan nama pemilik akun
    double minDist = 999;
    double currDist = 0.0;
    _predRes = "Tidak Dikenali";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        _predRes = label;
        if (_verify == false) {
          _verify = true;
        }
      }
    }
    return _predRes;
  }

  Widget _buildResults() {
    Center noResultsText = const Center(
        child: Text('Mohon Tunggu ..',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.white)));
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }
}
