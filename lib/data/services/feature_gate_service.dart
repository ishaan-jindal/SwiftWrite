import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:writer/data/services/auth_service.dart';

enum AppMode { undecided, offlineOnly, cloudEnabled }

class FeatureGateService extends GetxService {
  static const String _appModeKey = 'appMode';
  final Box _settingsBox = Hive.box('settings');

  final Rx<AppMode> _appMode = AppMode.undecided.obs;

  @override
  void onInit() {
    super.onInit();
    _appMode.value = _readModeFromStorage();
  }

  AppMode get appMode => _appMode.value;
  Rx<AppMode> get appModeRx => _appMode;

  bool get hasSelectedAppMode => appMode != AppMode.undecided;
  bool get isOfflineOnlyMode => appMode == AppMode.offlineOnly;
  bool get isCloudEnabledMode => appMode == AppMode.cloudEnabled;

  bool get hasCloudSession =>
      Get.isRegistered<AuthService>() && Get.find<AuthService>().isSignedIn;

  bool get canUseInternetFeatures => hasCloudSession;
  bool get canUseCodeExecution => hasCloudSession;
  bool get canUseCloudSync => hasCloudSession;
  bool get canUseCloudShare => canUseCloudSync;

  Future<void> setAppMode(AppMode mode) async {
    await _settingsBox.put(_appModeKey, mode.name);
    _appMode.value = mode;
  }

  Future<void> clearAppMode() async {
    await _settingsBox.delete(_appModeKey);
    _appMode.value = AppMode.undecided;
  }

  AppMode _readModeFromStorage() {
    final rawValue = _settingsBox.get(_appModeKey);
    if (rawValue is! String) {
      return AppMode.undecided;
    }

    return AppMode.values.firstWhere(
      (mode) => mode.name == rawValue,
      orElse: () => AppMode.undecided,
    );
  }
}
