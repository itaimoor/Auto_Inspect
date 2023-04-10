import 'package:get/get.dart';

class ObsController extends GetxController {
  var isLoading = false.obs;
  var loadingContent = ''.obs;
}

class DarkModeController extends GetxController {
  var darkMode = false.obs;
}
