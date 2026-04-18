import 'package:get/get.dart';


import '../../core/services/connectivity_service.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../features/home/controller/todo_controller.dart';

/// Initial GetX bindings — registers services and controllers.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services (permanent — survive navigation)
    Get.put(ConnectivityService(), permanent: true);

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<TodoController>(() => TodoController(), fenix: true);
  }
}
