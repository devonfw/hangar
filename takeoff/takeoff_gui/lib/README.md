To test create project without using the facade methods,
add the next function in features/create/controllers/create_controller.dart:
```
Future<void> fakeProcess(StreamController<GuiMessage> outputStream,
      StreamController<String> inputStream) async {
    String receivedData;
    await Future.delayed(const Duration(seconds: 1));

    outputStream.add(GuiMessage.info("test1"));
    await Future.delayed(const Duration(seconds: 4));

    outputStream.add(GuiMessage.browser("test2", "https://www.google.com"));
    receivedData = await inputStream.stream.take(1).last;
    await Future.delayed(const Duration(seconds: 5));

    outputStream.add(
        GuiMessage.input("test3 $receivedData. text field", InputType.text));
    receivedData = await inputStream.stream.take(1).last;
    await Future.delayed(const Duration(seconds: 5));

    outputStream.add(
        GuiMessage.input("test3 $receivedData number field", InputType.number));
    receivedData = await inputStream.stream.take(1).last;
    await Future.delayed(const Duration(seconds: 5));

    outputStream.add(GuiMessage.success(
        "Success building your project", "https://www.google.com"));
  }
```

 and replace the createProject method with the following lines:

```
void createProject() async {
    monitorController.monitorProcess(() async => fakeProcess(
        monitorController.outputChannel, monitorController.inputChannel));
}
```

remember to import dart:async