import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_4/pages/homePage.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/collection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../faceModule/detector.dart';
import '../faceModule/model.dart';
import '../faceModule/utils.dart';

class FaceRecognitionView extends StatefulWidget {
  String nip;
  FaceRecognitionView({Key? key, required this.nip});

  @override
  State<FaceRecognitionView> createState() => _FaceRecognitionViewState();
}

class _FaceRecognitionViewState extends State<FaceRecognitionView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _start();
  }

  void _start() async {
    interpreter = await loadModel();
    initialCamera();
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

  late File jsonFile;
  // late File jsonFace = Json;
  var interpreter;
  CameraController? _camera;
  dynamic data = {};
  bool _isDetecting = false;
  double threshold = 0.9;
  dynamic _scanResults;
  String _predRes = '';
  bool isStream = true;
  CameraImage? _cameraimage;
  Directory? tempDir;
  bool _faceFound = false;
  bool _verify = false;
  List? e1;
  bool loading = true;
  final TextEditingController _name = TextEditingController(text: '');
  final _formState = GlobalKey<FormState>();

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
    // jsonFile = await File.fromUri(
    //     Uri.https("presensiapp-facerecognition.my.id/assets/face_db/face.json"));
    if (jsonFile.existsSync()) {
      data = json.decode(jsonFile.readAsStringSync());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Pendaftaran Wajah'),
        leading: BackButton(
          onPressed: () async {
            if (_camera != null) {
              await _camera!.stopImageStream();
              await Future.delayed(const Duration(milliseconds: 1000));
              await _camera!.dispose();
              await Future.delayed(const Duration(milliseconds: 1000));
              _camera = null;
            }
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (contextDialog) {
                  return AlertDialog(
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Form(
                        key: _formState,
                        child: TextFormField(
                          readOnly: true,
                          controller: _name..text = widget.nip,
                          validator: (value) {
                            if (value == null || value == '') {
                              return 'Harus Diisi!';
                            } else if (_name == _predRes) {
                              return "data sudah ada";
                            }
                          },
                          decoration: InputDecoration(
                              label: Text('NIP'), border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Batal')),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                if (_formState.currentState!.validate()) {
                                  Navigator.pop(contextDialog);
                                  await Future.delayed(
                                      const Duration(milliseconds: 1000));
                                  data[_name.text] = e1;
                                  jsonFile.writeAsStringSync(json.encode(data));
                                  if (_camera != null) {
                                    await _camera!.stopImageStream();
                                    await Future.delayed(
                                        const Duration(milliseconds: 1000));
                                    await _camera!.dispose();
                                    await Future.delayed(
                                        const Duration(milliseconds: 1000));
                                    _camera = null;
                                  }
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Simpan')),
                        ],
                      )
                    ]),
                  );
                });
          },
          child: const Icon(Icons.add)),
      body: Builder(builder: (context) {
        if ((_camera == null || !_camera!.value.isInitialized) || loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          constraints: const BoxConstraints.expand(),
          padding: EdgeInsets.only(
              top: 0, bottom: MediaQuery.of(context).size.height * 0.2),
          child: _camera == null
              ? const Center(child: SizedBox())
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(_camera!),
                    _buildResults(),
                  ],
                ),
        );
      }),
    );
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
