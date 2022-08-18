import 'dart:async';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:location/location.dart';

class LocationDetector {
  static PermissionStatus? _grantedPermission;
  static bool _serviceEnabled = false;
  static Location? _location;
  static StreamSubscription<LocationData>? _positionStream;
  static List<Function?>? _callbackFunctionList;
  bool _changedSetting = false;

  static final LocationDetector instance =
  LocationDetector._privateConstructor();

  LocationDetector._privateConstructor();

  void initialize() async {
    _location = Location();
    // _changeSetting();

    _grantedPermission = null;
    _serviceEnabled = false;
    _positionStream = null;
    _callbackFunctionList ??= [];
  }

  Future<void> _changeSetting() async {
    if (!_changedSetting) {
      _changedSetting = true;
      await _location!.changeSettings(
        accuracy: LocationAccuracy.high,
        // timeInterval: Miliseconds
        interval: 2000,
        // distanceFilter: Meters
        distanceFilter: 100,
      );
    }
  }

  Future<LocationData?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await checkServiceStatus();
      if (_grantedPermission == null || !serviceEnabled || _location == null) {
        return null;
      }
      // if (_grantedPermission == PermissionStatus.granted) {
      //   await _changeSetting();
      // }
      return await _location?.getLocation();
    } on Exception catch (e) {
      printDefault("_parseMessage error ${e.toString()}");
      return null;
    }
  }

  Future<PermissionStatus?> checkPermissionStatus() async {
    if (_location == null) return null;
    _grantedPermission = await _location?.hasPermission();
    return _grantedPermission;
  }

  Future<PermissionStatus?> requestPermission() async {
    if (_location == null) return null;
    _grantedPermission = await _location?.requestPermission();
    return _grantedPermission;
  }

  Future<bool> checkServiceStatus() async {
    if (_location == null) return false;
    _serviceEnabled = await _location!.serviceEnabled();
    return _serviceEnabled;
  }

  Future<bool> requestService() async {
    if (_location == null) return false;
    return await _location!.requestService();
  }

  Future<PermissionStatus?> requestPermissionAndService() async {
    if (_location == null ||
        (_grantedPermission != null &&
            _grantedPermission == PermissionStatus.deniedForever)) {
      return null;
    }

    bool serviceStatus = await checkServiceStatus();
    if (!serviceStatus) serviceStatus = await requestService();

    if (serviceStatus) {
      PermissionStatus? permission = await checkPermissionStatus();
      if (permission == null || permission == PermissionStatus.denied) {
        permission = await requestPermission();
      }
      return permission;
    }

    return null;
  }

  int addCallbackFunctionForListen(
      void Function(LocationData position) getPositionChanged) {
    int index = -1;

    _callbackFunctionList ??= [];

    index = _callbackFunctionList!.length;
    _callbackFunctionList!.add(getPositionChanged);

    return index;
  }

  void removeCallbackFunctionForListen(int? index) {
    if (_callbackFunctionList == null) return;
    if (index == null || index < 0 || index >= _callbackFunctionList!.length) {
      return;
    }
    _callbackFunctionList![index] = null;
  }

  bool removeListenPositionChanged() {
    if (_positionStream != null) {
      _callbackFunctionList?.clear();
      _callbackFunctionList = null;
      _positionStream?.cancel();
      _positionStream = null;
      return true;
    }
    return false;
  }

  void listenPositionChanged() {
    if (_grantedPermission == null ||
        !_serviceEnabled ||
        _positionStream != null ||
        _location == null) return;

    _positionStream = _location?.onLocationChanged.listen((LocationData? result) {
      if (result != null && _callbackFunctionList?.length != 0) {
        for (int i = 0; i < (_callbackFunctionList?.length ?? 0); ++i) {
          if (_callbackFunctionList?[i] != null) {
            _callbackFunctionList?[i]!(result);
          }
        }
      }
    });
  }

  bool pauseListenPositionChanged() {
    if (_positionStream != null && !_positionStream!.isPaused) {
      _positionStream!.pause();
      return true;
    }
    return false;
  }

  bool resumeListenPositionChanged() {
    if (_positionStream != null && _positionStream!.isPaused) {
      _positionStream!.resume();
      return true;
    }
    return false;
  }

  bool isListeningPositionChanged() {
    return !(_positionStream == null || _positionStream!.isPaused);
  }

  bool isServiceEnabled() {
    return _serviceEnabled;
  }

  PermissionStatus? isGrantedPermission() {
    return _grantedPermission;
  }

  bool? isGrantedPermissionResult() {
    return _grantedPermission == PermissionStatus.granted;
  }
}
