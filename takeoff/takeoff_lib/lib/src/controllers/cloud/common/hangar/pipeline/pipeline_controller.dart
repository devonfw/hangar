import 'package:get_it/get_it.dart';
import 'package:takeoff_lib/src/controllers/docker/docker_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/pipeline_generator/pipeline_generator.dart';

/// Executes the create pipeline scripts
class PipelineController<T extends PipelineGenerator> {
  /// Executes the pipeline [script].
  ///
  /// Whether or not the process succeed.
  Future<bool> execute(T script) async {
    DockerController controller = GetIt.I.get<DockerController>();

    if (!await controller.executeCommand([], script.toCommand())) {
      return false;
    }

    return true;
  }
}
