import 'dart:async';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SystemMonitor {
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  // Get device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'androidVersion': androidInfo.version.release,
        'sdkVersion': androidInfo.version.sdkInt,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'product': androidInfo.product,
        'hardware': androidInfo.hardware,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'name': iosInfo.name,
        'model': iosInfo.model,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'localizedModel': iosInfo.localizedModel,
        'identifierForVendor': iosInfo.identifierForVendor,
      };
    } else {
      // For web or other platforms
      final webInfo = await _deviceInfo.webBrowserInfo;
      return {
        'browserName': webInfo.browserName,
        'platform': webInfo.platform,
        'userAgent': webInfo.userAgent,
      };
    }
  }

  // Battery status
  Future<double> getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    return level.toDouble();
  }

  // CPU usage (mock data for now)
  Future<double> getCpuUsage() async {
    // In a real implementation, we'd use platform channels
    return Future.value(45.0); // Mock 45% CPU usage
  }

  // Memory usage
  Future<Map<String, double>> getMemoryStatus() async {
    return {
      'total': 8192.0, // Mock 8GB total
      'used': 4096.0, // Mock 4GB used
      'free': 4096.0 // Mock 4GB free
    };
  }

  // Network connectivity
  Future<bool> isNetworkAvailable() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Get network connection type
  Future<String> getNetworkType() async {
    final result = await _connectivity.checkConnectivity();
    switch (result) {
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  // Device temperature (mock data)
  Future<double> getDeviceTemperature() async {
    return Future.value(35.5); // Mock 35.5°C
  }

  // Get system status summary
  Future<Map<String, dynamic>> getSystemStatus() async {
    final deviceInfo = await getDeviceInfo();
    final batteryLevel = await getBatteryLevel();
    final networkAvailable = await isNetworkAvailable();
    final networkType = await getNetworkType();
    final cpuUsage = await getCpuUsage();
    final memoryStatus = await getMemoryStatus();
    final temperature = await getDeviceTemperature();

    return {
      'device': deviceInfo,
      'battery': {
        'level': batteryLevel,
        'percentage': '$batteryLevel%',
      },
      'network': {
        'available': networkAvailable,
        'type': networkType,
      },
      'performance': {
        'cpu': cpuUsage,
        'memory': memoryStatus,
        'temperature': temperature,
      },
    };
  }
}
