import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  static Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return '${android.brand} ${android.model}';
    }

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.name;
    }

    if (Platform.isMacOS) {
      final mac = await deviceInfo.macOsInfo;
      return mac.computerName;
    }

    if (Platform.isWindows) {
      final win = await deviceInfo.windowsInfo;
      return win.computerName;
    }

    return 'Unknown Device';
  }
}
