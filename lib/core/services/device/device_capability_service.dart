import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/services.dart';

enum DeviceTier { low, mid, upperMid, flagship }

class DeviceCapability {
  final double ramGb;
  final double freeGb;
  final bool isArm64;
  final String model;
  final String brand;
  final DeviceTier tier;

  const DeviceCapability({
    required this.ramGb,
    required this.freeGb,
    required this.isArm64,
    required this.model,
    required this.brand,
    required this.tier,
  });
}

class DeviceCapabilityService {
  static const MethodChannel _channel = MethodChannel('privacy_ai/device');

  Future<DeviceCapability> detect() async {
    final info = DeviceInfoPlugin();
    final android = await info.androidInfo;

    final totalRamBytes = await _getTotalRamBytes();
    final ramGb = (totalRamBytes / (1024 * 1024 * 1024)).toDouble();

    final freeGb = (await DiskSpace.getFreeDiskSpace) ?? 0.0;
    final isArm64 = android.supportedAbis.any((abi) => abi == 'arm64-v8a');

    return DeviceCapability(
      ramGb: _round1(ramGb),
      freeGb: _round1(freeGb),
      isArm64: isArm64,
      model: android.model ?? 'Unknown',
      brand: android.brand ?? 'Unknown',
      tier: _tierForRam(ramGb),
    );
  }

  DeviceTier _tierForRam(double ramGb) {
    if (ramGb < 4.0) return DeviceTier.low;
    if (ramGb < 6.0) return DeviceTier.mid;
    if (ramGb < 8.0) return DeviceTier.upperMid;
    return DeviceTier.flagship;
  }

  Future<int> _getTotalRamBytes() async {
    try {
      final bytes = await _channel.invokeMethod<int>('getTotalRam');
      return bytes ?? 0;
    } catch (_) {
      return 0;
    }
  }

  double _round1(double value) => (value * 10).roundToDouble() / 10;
}
