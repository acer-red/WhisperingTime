import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:whispering_time/util/path.dart';

class Device {
  Map<String, dynamic> data = {};

  Device() {
    _build();
  }

  void _build() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo platform = await deviceInfo.androidInfo;
      data = {
        'model': platform.model,
        'brand': platform.brand,
        'device': platform.device,
        'androidVersion': platform.version.release,
        'board': platform.board,
        'bootloader': platform.bootloader,
        'display': platform.display,
        'fingerprint': platform.fingerprint,
        'hardware': platform.hardware,
        'host': platform.host,
        'id': platform.id,
        'manufacturer': platform.manufacturer,
        'product': platform.product,
        'name': platform.name,
        'supported32BitAbis': platform.supported32BitAbis,
        'supported64BitAbis': platform.supported64BitAbis,
        'supportedAbis': platform.supportedAbis,
        'tags': platform.tags,
        'type': platform.type,
        'isPhysicalDevice': platform.isPhysicalDevice,
        'systemFeatures': platform.systemFeatures,
        'isLowRamDevice': platform.isLowRamDevice,
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo platform = await deviceInfo.iosInfo;
      data = {
        'model': platform.utsname.machine,
        'systemName': platform.systemName,
        'systemVersion': platform.systemVersion,
        'name': platform.name,
        'modelName': platform.modelName,
        'localizedModel': platform.localizedModel,
        'identifierForVendor': platform.identifierForVendor,
        'isPhysicalDevice': platform.isPhysicalDevice,
        'isiOSAppOnMac': platform.isiOSAppOnMac,
        'utsname': platform.utsname,
      };
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo platform = await deviceInfo.macOsInfo;
      data = {
        'computerName': platform.computerName,
        'hostName': platform.hostName,
        'arch,': platform.arch,
        'model': platform.model,
        'modelName': platform.modelName,
        'kernelVersion': platform.kernelVersion,
        'osRelease': platform.osRelease,
        'majorVersion': platform.majorVersion,
        'minorVersion': platform.minorVersion,
        'patchVersion': platform.patchVersion,
        'activeCPUs': platform.activeCPUs,
        'memorySize': platform.memorySize,
        'cpuFrequency': platform.cpuFrequency,
        'systemGUID': platform.systemGUID,
      };
    } else if (Platform.isWindows) {
      WindowsDeviceInfo platform = await deviceInfo.windowsInfo;

      data = {
        'computerName': platform.computerName,
        'numberOfCores': platform.numberOfCores,
        'systemMemoryInMegabytes': platform.systemMemoryInMegabytes,
        'userName': platform.userName,
        'majorVersion': platform.majorVersion,
        'minorVersion': platform.minorVersion,
        'buildNumber': platform.buildNumber,
        'platformId': platform.platformId,
        'csdVersion': platform.csdVersion,
        'servicePackMajor': platform.servicePackMajor,
        'servicePackMinor': platform.servicePackMinor,
        'suitMask': platform.suitMask,
        'productType': platform.productType,
        'reserved': platform.reserved,
        'buildLab': platform.buildLab,
        'buildLabEx': platform.buildLabEx,
        'digitalProductId': platform.digitalProductId,
        'displayVersion': platform.displayVersion,
        'editionId': platform.editionId,
        'installDate': platform.installDate,
        'productId': platform.productId,
        'productName': platform.productName,
        'registeredOwner': platform.registeredOwner,
        'releaseId': platform.releaseId,
        'deviceId': platform.deviceId,
      };
    } else if (Platform.isLinux) {
      LinuxDeviceInfo platform = await deviceInfo.linuxInfo;
      data = {
        'version': platform.version,
        'id': platform.id,
        'idLike': platform.idLike,
        'versionCodename': platform.versionCodename,
        'versionId': platform.versionId,
        'prettyName': platform.prettyName,
        'buildId': platform.buildId,
        'variant': platform.variant,
        'variantId': platform.variantId,
        'machineId': platform.machineId,
      };
    }
  }

  Future<String> write() async {
    Directory cacheDir = await getTempDir();
    String savePath = path.join(cacheDir.path, 'device_info.json');
    File file = File(savePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(data.toString());
    return savePath;
  }
}
