import 'package:location/location.dart' as locatin2;
locatin2.Location lokasi = locatin2.Location();

Future<bool?> requestPermission() async {
  bool serviceEnabled;
  locatin2.PermissionStatus permissionGranted;
  serviceEnabled = await lokasi.serviceEnabled();

  if (!serviceEnabled) {
    serviceEnabled = await lokasi.requestService();
    if (!serviceEnabled) {
      return false;
    }
  }

  permissionGranted = await lokasi.hasPermission();
  if (permissionGranted == locatin2.PermissionStatus.denied) {
    permissionGranted = await lokasi.requestPermission();
  }
  if (permissionGranted != locatin2.PermissionStatus.granted) {
    return false;
  }
}
