import 'package:takeoff_lib/src/domain/gui_message/gui_message.dart';
import 'package:takeoff_lib/src/domain/gui_message/input_type.dart';
import 'package:takeoff_lib/src/domain/gui_message/message_type.dart';
import 'package:test/test.dart';

void main() {
  test("GuiMessage returns a correct GuiMessage type", () {
    GuiMessage guiMessage = GuiMessage(type: MessageType.info, message: 'hello world');
    expect(guiMessage, isA<GuiMessage>());
  });

  test("GuiMessage.info returns a correct GuiMessage type", () {
    expect(GuiMessage.info('Hello World'), isA<GuiMessage>());
  });

  test("GuiMessage.input returns a correct GuiMessage type", () {
    GuiMessage guiMessage = GuiMessage(type: MessageType.info, message: 'hello world');
    expect(GuiMessage.input('Hello World', InputType.text), isA<GuiMessage>());
  });

  test("GuiMessage.success returns a correct GuiMessage type", () {
    expect(GuiMessage.success('Hello World', 'http://www.google.com'), isA<GuiMessage>());
  });
  
  test("GuiMessage.error returns a correct GuiMessage type", () {
    expect(GuiMessage.error('Hello World'), isA<GuiMessage>());
  });
  
  test("GuiMessage.browser returns a correct GuiMessage type", () {
    expect(GuiMessage.browser('Hello World', 'http://www.google.com'), isA<GuiMessage>());
  });

}
