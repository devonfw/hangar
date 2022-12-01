import 'package:takeoff_gui/features/create/utils/type_message.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class CreateMessage {
  final TypeMessage typeMessage;
  final String message;

  CreateMessage(this.typeMessage, this.message);

  factory CreateMessage.fromGuiMessage(GuiMessage message) {
    switch (message.type) {
      case MessageType.info:
        return CreateMessage(TypeMessage.info, message.message);
      case MessageType.success:
        return CreateMessage(TypeMessage.success, message.message);
      case MessageType.error:
        return CreateMessage(TypeMessage.error, message.message);
      default:
        return CreateMessage(TypeMessage.action, message.message);
    }
  }
}
