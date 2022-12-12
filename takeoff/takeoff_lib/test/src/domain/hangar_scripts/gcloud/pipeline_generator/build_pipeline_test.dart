import 'package:takeoff_lib/src/domain/hangar_scripts/common/language/language.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/common/machine_type.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/build_pipeline.dart';
import 'package:test/test.dart';

void main() {
  test("BuildPipelineGCloud to command generates the arguments correctly", () {
    BuildPipelineGCloud buildPipelineGCloud = BuildPipelineGCloud(configFile: "configFile", pipelineName: "pipelineName", language: Language.flutter, localDirectory: "localDirectory");
    expect(buildPipelineGCloud.toCommand(), ['/scripts/pipelines/gcloud/pipeline_generator.sh','-c','configFile','-n','pipelineName','--local-directory','localDirectory','-l','flutter']);
  });

  test("BuildPipelineGCloud to command with all the parameters generates the arguments correctly", () {
    BuildPipelineGCloud buildPipelineGCloud = BuildPipelineGCloud(configFile: "configFile", pipelineName: "pipelineName", language: Language.flutter, localDirectory: "localDirectory", registryLocation: "registryLocation", targetDirectory: "targetDirectory", machineType: MachineType.E2_HIGHCPU_32);
    expect(buildPipelineGCloud.toCommand(), ['/scripts/pipelines/gcloud/pipeline_generator.sh','-c','configFile','-n','pipelineName','--local-directory','localDirectory','-l','flutter','--registry-location','registryLocation','-t','targetDirectory','-m','E2_HIGHCPU_32']);
  }); 

}
