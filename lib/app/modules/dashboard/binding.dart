

import 'package:get/get.dart';
import 'package:legalsteward/app/modules/dashboard/controller.dart';

class dashBoardBinding extends Bindings{
  @override
  void dependencies() {
    
    Get.put(DashBoardController());
  }
}
