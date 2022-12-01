import 'package:takeoff_lib/src/domain/gui_message/message_type.dart';

import 'input_type.dart';

class GuiMessage {
  MessageType type;
  String message;
  String? url;
  InputType? inputType;

  GuiMessage(
      {required this.type, required this.message, this.url, this.inputType});

  factory GuiMessage.info(String message) {
    return GuiMessage(type: MessageType.info, message: message);
  }

  factory GuiMessage.input(String message, InputType inputType) {
    return GuiMessage(
        type: MessageType.input, message: message, inputType: inputType);
  }

  factory GuiMessage.success(String message, String url) {
    return GuiMessage(type: MessageType.success, message: message, url: url);
  }

  factory GuiMessage.error(String message) {
    return GuiMessage(type: MessageType.error, message: message);
  }

  factory GuiMessage.browser(String message, String url) {
    return GuiMessage(type: MessageType.browser, message: message, url: url);
  }
}
