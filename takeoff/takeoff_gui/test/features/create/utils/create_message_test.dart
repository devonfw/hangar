import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/features/create/utils/create_message.dart';
import 'package:takeoff_gui/features/create/utils/type_message.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

void main() async {
  TypeMessage typeMessage;
  String message;

  setUpAll(() async {});

  test("Test create message", () async {
    typeMessage = TypeMessage.info;
    message = "Test message - Info";
    CreateMessage createMessage = CreateMessage(typeMessage, message);
    expect(createMessage.typeMessage, typeMessage);
    expect(createMessage.message, message);

    typeMessage = TypeMessage.error;
    message = "Test message - Error";
    createMessage = CreateMessage(typeMessage, message);
    expect(createMessage.typeMessage, typeMessage);
    expect(createMessage.message, message);
  });

  test("Test create message factory", () async {
    typeMessage = TypeMessage.error;
    message = "Test message - Error";
    GuiMessage guiMessage =
        GuiMessage(type: MessageType.error, message: message);

    CreateMessage createMessage = CreateMessage.fromGuiMessage(guiMessage);
    expect(createMessage.typeMessage, typeMessage);
    expect(createMessage.message, message);

    typeMessage = TypeMessage.success;
    message = "Test message - Success";
    guiMessage = GuiMessage(type: MessageType.success, message: message);

    createMessage = CreateMessage.fromGuiMessage(guiMessage);
    expect(createMessage.typeMessage, typeMessage);
    expect(createMessage.message, message);

    typeMessage = TypeMessage.info;
    message = "Test message - Info";
    guiMessage = GuiMessage(type: MessageType.info, message: message);

    createMessage = CreateMessage.fromGuiMessage(guiMessage);
    expect(createMessage.typeMessage, typeMessage);
    expect(createMessage.message, message);

    typeMessage = TypeMessage.action;
    message = "Test message - Action";
    guiMessage = GuiMessage(type: MessageType.input, message: message);

    createMessage = CreateMessage.fromGuiMessage(guiMessage);
    expect(createMessage.typeMessage, typeMessage);
    expect(createMessage.message, message);
  });
}
