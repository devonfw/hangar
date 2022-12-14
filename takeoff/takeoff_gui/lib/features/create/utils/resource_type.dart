import 'package:takeoff_lib/takeoff_lib.dart';

class ResourceType {
  static List<Resource> resource = [
    Resource.ide,
    Resource.pipeline,
    Resource.feRepo,
    Resource.beRepo
  ];
  static Map<Resource, List<String>> typeOfResource = {
    Resource.ide: ["ide"],
    Resource.pipeline: ["pipeline"],
    Resource.feRepo: ["fe repo"],
    Resource.beRepo: ["be repo"],
  };
}
