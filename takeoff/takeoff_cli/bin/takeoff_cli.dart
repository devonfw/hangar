import 'package:stack_trace/stack_trace.dart';
import 'package:takeoff_cli/takeoff_cli.dart';

void main(List<String> arguments) async {
  // Avoid display the trace
  Chain.capture(() {
    TakeOffCli().run(arguments);
  }, onError: (error, stackChain) {
    print(error);
  });
}
