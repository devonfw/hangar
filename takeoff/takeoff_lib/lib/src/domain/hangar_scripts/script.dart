/// Interface of the script classes
abstract class Script {
  List<String> toCommand();
  Map<int, String> get errors;
}
