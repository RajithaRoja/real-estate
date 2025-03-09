import 'package:get/get.dart';
import 'package:realesate/agent_user_list/agent_user_controller.dart';

class AgentUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgentUserPropertyController>(() => AgentUserPropertyController());
  }
}