import 'package:takeoff_lib/src/controllers/hangar/pipeline/application_end.dart';
import 'package:takeoff_lib/src/controllers/hangar/pipeline/create_pipeline_exception.dart';
import 'package:takeoff_lib/src/controllers/hangar/pipeline/pipeline_controller.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/language.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/pipeline_generator/build_pipeline.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/pipeline_generator/deploy_pipeline.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/pipeline_generator/package_pipeline.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/pipeline_generator/quality_pipeline.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/pipeline_generator/test_pipeline.dart';

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
      required String sonarToken}) async {
    String buildPipelineName = "build_${projectName}_${appEnd.name}";
    String qaPipelineName = "qa_${projectName}_${appEnd.name}";
    String testPipelineName = "test_${projectName}_${appEnd.name}";

    if (!await execute(BuildPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/build/build-pipeline.cfg",
        pipelineName: buildPipelineName,
        languageVersion: languageVersion,
        language: language,
        localDirectory: localDir))) {
      throw CreatePipelineException(
          "Build pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(TestPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/test/test-pipeline.cfg",
        pipelineName: "test_${projectName}_backend",
        language: language,
        languageVersion: languageVersion,
        localDirectory: localDir,
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
        sonarToken: sonarToken))) {
      throw CreatePipelineException(
          "Quality pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(PackagePipelineGCloud(
      configFile:
          "/scripts/pipelines/gcloud/templates/package/package-pipeline.cfg",
      pipelineName: "package_${projectName}_backend",
      language: language,
      localDirectory: localDir,
      buildPipelineName: buildPipelineName,
      qualityPipelineName: qaPipelineName,
      imageName: "${projectName}_${appEnd.name}_image",
    ))) {
      throw CreatePipelineException(
          "Package pipeline could not be created for ${appEnd.name}");
    }

    if (!await execute(DeployPipelineGCloud(
        configFile:
            "/scripts/pipelines/gcloud/templates/build/build-pipeline.cfg",
        pipelineName: "deploy_${projectName}_backend",
        language: language,
        localDirectory: localDir,
        gCloudRegion: googleCloudRegion,
        serviceName: "${projectName}_${appEnd.name}_service"))) {
      throw CreatePipelineException(
          "Deploy pipeline could not be created for ${appEnd.name}");
    }
  }
}
