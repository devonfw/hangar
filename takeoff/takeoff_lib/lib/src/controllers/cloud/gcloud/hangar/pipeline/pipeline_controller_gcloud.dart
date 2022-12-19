import 'package:takeoff_lib/src/domain/application_end.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/pipeline/create_pipeline_exception.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/pipeline/pipeline_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/common/machine_type.dart';
import 'package:takeoff_lib/src/domain/language.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/build_pipeline.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/deploy_pipeline.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/flutter_web_renderer.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/package_pipeline.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/quality_pipeline.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/test_pipeline.dart';

/// Controller for the pipelines in Google Cloud.
class PipelineControllerGCloud extends PipelineController {
  /// Builds all the pipelines for a given [projectName] in Google Cloud
  ///
  /// It requires the [ApplicationEnd], the [Language], the repository [localDir]
  /// and the [googleCloudRegion] to deploy.
  Future<void> buildPipelines(
      {required String projectName,
      required ApplicationEnd appEnd,
      required Language language,
      String? languageVersion,
      required String localDir,
      required String googleCloudRegion,
      required String sonarUrl,
      required String sonarToken,
      String? registryLocation,
      String? deployServiceName,
      String targetBranch = "develop",
      bool? androidFlutterPlatform,
      bool? webFlutterPlatform,
      FlutterWebRenderer? flutterWebRenderer}) async {
    String buildPipelineName = "build-$projectName-${appEnd.name}";
    String qaPipelineName = "qa-$projectName-${appEnd.name}";
    String testPipelineName = "test-$projectName-${appEnd.name}";
    String packagePipelineName = "package-$projectName-${appEnd.name}";
    String deployPipelineName = "deploy-$projectName-${appEnd.name}";
    MachineType? machineType =
        (language == Language.flutter) ? MachineType.E2_HIGHCPU_8 : null;

    if (!await execute(BuildPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/build/build-pipeline.cfg",
        pipelineName: buildPipelineName,
        languageVersion: languageVersion,
        registryLocation: registryLocation,
        targetBranch: targetBranch,
        language: language,
        machineType: machineType,
        localDirectory: localDir))) {
      throw CreatePipelineException(
          "Build pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(TestPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/test/test-pipeline.cfg",
        pipelineName: testPipelineName,
        language: language,
        languageVersion: languageVersion,
        localDirectory: localDir,
        targetBranch: targetBranch,
        registryLocation: registryLocation,
        machineType: machineType,
        buildPipelineName: buildPipelineName))) {
      throw CreatePipelineException(
          "Test pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(QualityPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/quality/quality-pipeline.cfg",
        pipelineName: qaPipelineName,
        language: language,
        localDirectory: localDir,
        buildPipelineName: buildPipelineName,
        targetBranch: targetBranch,
        languageVersion: languageVersion,
        machineType: machineType,
        testPipelineName: testPipelineName,
        sonarUrl: sonarUrl,
        sonarToken: sonarToken,
        registryLocation: registryLocation))) {
      throw CreatePipelineException(
          "Quality pipeline could not be created for ${appEnd.name}");
    }
    if (!await execute(PackagePipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/package/package-pipeline.cfg",
        pipelineName: packagePipelineName,
        language: language,
        languageVersion: languageVersion,
        localDirectory: localDir,
        buildPipelineName: buildPipelineName,
        qualityPipelineName: qaPipelineName,
        targetBranch: targetBranch,
        registryLocation: registryLocation,
        machineType: machineType,
        imageName:
            "$googleCloudRegion-docker.pkg.dev/$projectName/${appEnd.name}/${appEnd.name}",
        webFlutterPlatform: webFlutterPlatform,
        androidFlutterPlatform: androidFlutterPlatform,
        flutterWebRenderer: flutterWebRenderer))) {
      throw CreatePipelineException(
          "Package pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(DeployPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/deploy-cloud-run/deploy-cloud-run-pipeline.cfg",
        pipelineName: deployPipelineName,
        language: language,
        languageVersion: languageVersion,
        targetBranch: targetBranch,
        localDirectory: localDir,
        machineType: machineType,
        registryLocation: registryLocation,
        gCloudRegion: googleCloudRegion,
        serviceName:
            deployServiceName ?? "$projectName-${appEnd.name}-service"))) {
      throw CreatePipelineException(
          "Deploy pipeline could not be created for ${appEnd.name}");
    }
  }
}