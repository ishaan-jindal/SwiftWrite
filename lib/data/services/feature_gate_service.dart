import 'package:get/get.dart';
import 'package:writer/data/services/auth_service.dart';

class FeatureGateService extends GetxService {
  bool get hasCloudSession =>
      Get.isRegistered<AuthService>() && Get.find<AuthService>().isSignedIn;

  bool get canUseInternetFeatures => hasCloudSession;
  bool get canUseCodeExecution => hasCloudSession;
  bool get canUseCloudSync => hasCloudSession;
  bool get canUseCloudShare => canUseCloudSync;
}
