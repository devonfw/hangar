import 'package:takeoff_lib/src/domain/application_end.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/pipeline/create_pipeline_exception.dart';
import 'package:takeoff_lib/src/controllers/cloud/common/hangar/pipeline/pipeline_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/language/language.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/build_pipeline.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/deploy_pipeline.dart';
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
      String? registryLocation}) async {
    String buildPipelineName = "build-$projectName-${appEnd.name}";
    String qaPipelineName = "qa-$projectName-${appEnd.name}";
    String testPipelineName = "test-$projectName-${appEnd.name}";

    if (!await execute(BuildPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/build/build-pipeline.cfg",
        pipelineName: buildPipelineName,
        languageVersion: languageVersion,
        registryLocation: registryLocation,
        language: language,
        localDirectory: localDir))) {
      throw CreatePipelineException(
          "Build pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(TestPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/test/test-pipeline.cfg",
        pipelineName: "test-$projectName-${appEnd.name}",
        language: language,
        languageVersion: languageVersion,
        localDirectory: localDir,
        registryLocation: registryLocation,
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
        languageVersion: languageVersion,
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
      pipelineName: "package-$projectName-${appEnd.name}",
      language: language,
      languageVersion: languageVersion,
      localDirectory: localDir,
      buildPipelineName: buildPipelineName,
      qualityPipelineName: qaPipelineName,
      registryLocation: registryLocation,
      imageName: "$projectName-${appEnd.name}-image",
    ))) {
      throw CreatePipelineException(
          "Package pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(DeployPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/deploy-cloud-run/deploy-cloud-run-pipeline.cfg",
        pipelineName: "deploy-$projectName-${appEnd.name}",
        language: language,
        languageVersion: languageVersion,
        localDirectory: localDir,
        registryLocation: registryLocation,
        gCloudRegion: googleCloudRegion,
        serviceName: "$projectName-${appEnd.name}-service"))) {
      throw CreatePipelineException(
          "Deploy pipeline could not be created for ${appEnd.name}");
    }
  }
}
