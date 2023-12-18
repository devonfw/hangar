"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.WebviewPanelCreator = void 0;
const vscode = __importStar(require("vscode"));
class WebviewPanelCreator {
    createWebviewPanel() {
        const panel = vscode.window.createWebviewPanel('scriptDocu', 'Scripts documentation', vscode.ViewColumn.One, {});
        panel.webview.html = this.getWebviewContent();
    }
    getWebviewContent() {
        return `<!DOCTYPE html>
			<html lang="en">
			<head>
				<meta charset="UTF-8">
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<title>Scripts documentation</title>
			</head>
			<body>
				<h1>Scripts documentation</h1>
				<h2>Index</h2>
    			<ul>
        			<li><a href="#create-repo">🆙 create-repo.sh</a></li>
        			<li><a href="#pipeline-generator">⏩ pipeline_generator.sh</a></li>
    			</ul>
				<hr>
				<h2 id="create-repo">🆙 create-repo.sh</h2>
				<p>
				Creates or imports a repository on GitHub, Azure Devops or Google Cloud.<br>
				It allows you to, based on action flag, either:<br>
				<ul>
					<li>Create an empty repository with just a README file and clone it to your computer into the directory you set. Useful when starting a project from scratch.</li>
					<li>Import an already existing directory or Git repository into your project giving a path or an URL. Useful for taking to GitHub the development of an existing project.</li>
				</ul>
				</p>
				<h3>Documentation link/s:</h3>
				<ul>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/github/setup-repository-script.asciidoc" target="_blank">Set up a repository on GitHub</a></li>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/azure-devops/setup-repository-script.asciidoc" target="_blank">Set up a repository on Azure Devops</a></li>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/gcloud/setup-repository-script.asciidoc" target="_blank">Set up a repository on Google Cloud</a></li>
				</ul>
				<h3>Flags</h3>
				<pre>
				<code>
	-a, --action                [Required] Use case to fulfil: create, import.
	-d, --directory             [Required] Path to the directory where your repository will be cloned or initialized.
	-n, --name                             Name for the GitHub repository. By default, the source repository or directory name (either new or existing, depending on use case) is used.
	-g, --source-git-url                   Source URL of the Git repository to import.
	-b, --source-branch                    Source branch to be used as a basis to initialize the repository on import, as master branch.
	-r, --remove-other-branches            Removes branches other than the (possibly new) default one.
	-s, --setup-branch-strategy            Creates branches and policies required for the desired workflow. Requires -b on import. Accepted values: gitflow.
	-f, --force                            Skips any user confirmation.
		--subpath                          When combined with -g and -r, imports only the specified subpath of the source Git repository.
	-u, --public                           Sets repository scope to public. Private otherwise.
				</code>
				</pre>
				<hr>

				<h2 id="pipeline-generator">⏩ pipeline_generator.sh</h2>
				<p>
				Generates a workflow on github based on the given definition.<br>
				</p>
				<h3>Documentation link/s:</h3>
				<ul>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/github/setup-build-pipeline.asciidoc" target="_blank">Setting up a Build workflow on GitHub</a></li>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/github/setup-ci-pipeline.asciidoc" target="_blank">Setting up a CI workflow on GitHub</a></li>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/github/setup-package-pipeline.asciidoc" target="_blank">Setting up a Package workflow on GitHub</a></li>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/github/setup-quality-pipeline.asciidoc" target="_blank">Setting up a Quality workflow on GitHub</a></li>
					<li><a href="https://github.com/hec-stbt/hangar/blob/feature/vscode-extension/documentation/github/setup-test-pipeline.asciidoc" target="_blank">Setting up a Test workflow on GitHub</a></li>
				</ul>
				<h3>Common flags</h3>
				<pre>
				<code>
	-c, --config-file           [Required] Configuration file containing workflow definition.
	-n, --pipeline-name         [Required] Name that will be set to the workflow.
	-d, --local-directory       [Required] Local directory of your project.
	-a, --artifact-path                    Path to be persisted as an artifact after workflow execution, e.g. where the application stores logs or any other blob on runtime.
	-b, --target-branch                    Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided.
	-w                                     Open the Pull Request on the web browser if it cannot be automatically merged. Requires -b flag.
				</code>
				</pre>
				<h3>Build workflow flags</h3>
				<pre>
				<code>
	-l, --language              [Required] Language or framework of the project.
	-t, --target-directory                 Target directory of build process. Takes precedence over the language/framework default one.
		--language-version      [Required, if Flutter or Python] Language or framework version.
				</code>
				</pre>
				<h3>Quality workflow flags</h3>
				<pre>
				<code>
	-l, --language              [Required] Language or framework of the project.
		--language-version      [Required, if Flutter or Python] Language or framework version.
		--sonar-url             [Required] Sonarqube URL.
		--sonar-token           [Required] Sonarqube token.
				</code>
				</pre>
				<h3>CI pipeline flags</h3>
				<pre>
				<code>
	--build-pipeline-name   [Required] Name of the job calling the build workflow.
	--test-pipeline-name               Name of the job calling the test workflow.
	--quality-pipeline-name            Name of the job calling the quality workflow.
				</code>
				</pre>
				<h3>Package workflow flags</h3>
				<pre>
				<code>
	-l, --language              [Required, if dockerfile not set] Language or framework of the project.
		--language-version      [Required, if Flutter or Python] Language or framework version.
		--flutter-web-platform  [Required, if Flutter] Compile Web platform.
		--flutter-android-platform  [Required, if Flutter] Compile Android platform.
		--flutter-web-renderer             Flutter web renderer. Accepted values: auto (default), canvaskit, html.
		--dockerfile            [Required, if language not set] Path from the root of the project to its Dockerfile. Takes precedence over the language/framework default one.
		--ci-pipeline-name      [Required] CI workflow name.
	-i, --image-name            [Required] Name (excluding tag) for the generated container image.
	-u, --registry-user         [Required, unless AWS or GCP] Container registry login user.
	-p, --registry-password     [Required, unless AWS or GCP] Container registry login password.
		--aws-access-key        [Required, if AWS] AWS account access key ID. Takes precedence over registry credentials.
		--aws-secret-access-key [Required, if AWS] AWS account secret access key.
		--aws-region            [Required, if AWS] AWS region for ECR.
				</code>
				</pre>
				<h3>Library package workflow flags</h3>
				<pre>
				<code>
	-l, --language              [Required] Language or framework of the project.
				</code>
				</pre>
				<h3>Azure AKS provisioning workflow flags</h3>
				<pre>
				<code>
	--cluster-name          [Required] Name for the cluster.
	--resource-group        [Required] Name of the resource group for the cluster.
	--storage-account       [Required] Name of the storage account for the cluster.
	--storage-container     [Required] Name of the storage container where the Terraform state of the cluster will be stored.
	--rancher                          Install Rancher to manage the cluster.
	--setup-monitoring                 Install logging and monitoring stack (Prometheus, Grafana, Alertmanager, Loki). Default: true.
				</code>
				</pre>
				<h3>AWS EKS provisioning workflow flag</h3>
				<pre>
				<code>
	--cluster-name          [Required] Name for the cluster.
	--s3-bucket             [Required] Name of the S3 bucket where the Terraform state of the cluster will be stored.
	--s3-key-path           [Required] Path within the S3 bucket where the Terraform state of the cluster will be stored.
	--aws-access-key        [Required, on first run] AWS account access key ID.
	--aws-secret-access-key [Required, on first run] AWS account secret access key.
	--aws-region            [Required, on first run] AWS region for provisioning resources.
	--setup-monitoring                 Install logging and monitoring stack (Prometheus, Grafana, Alertmanager, Loki). Default: true.
	--rancher                          Install Rancher to manage the cluster.
				</code>
				</pre>
				<h3>Deploy to Kubernetes workflow flags</h3>
				<pre>
				<code>
	--package-pipeline-name         [Required] Package workflow name.
	--env-provision-pipeline-name   [Required] Environment provisioning workflow name.
	--k8s-provider                  [Required] Kubernetes cluster provider name. Accepted values: EKS, AKS.
	--k8s-namespace                 [Required] Kubernetes namespace where the application will be deployed.
	--k8s-deploy-files-path         [Required] Path from the root of the project to the YAML manifests directory.
	--k8s-image-pull-secret-name               Name for the generated secret containing registry credentials. Required when using a private registry to host images.
				</code>
				</pre>
			</body>
			</html>`;
    }
}
exports.WebviewPanelCreator = WebviewPanelCreator;
//# sourceMappingURL=WebviewPanelCreator.js.map