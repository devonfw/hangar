import * as vscode from "vscode";
import { execSync } from "child_process";
import path from "path";


/**
 * Represents a script runner for a VS Code extension.
 * 
 * This class is responsible for executing scripts based on the selected radio button. It includes a method
 * for running the script associated with the given radio button ID.
 * 
 * Available scripts:
 * - 🆙 Create repo
 * - 🆕 Add secret
 * - ⏩ Pipeline generator
 *  
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.0.0
 */
export class HangarScripts {
    /**
     * Executes the scripts associated with the given script ID.
     * 
     * This method executes the corresponding script.
     * If no script is found for a given ID, it logs an error message.
     * 
     * @param {string} scriptId - The ID of the selected script.
     * @param {string} scriptAttributes - The script attributes.
     * 
     * @example
     * scriptSelector('create-repo.sh', '-a create -n repo-test -d /local/project/path');
     */
    public scriptSelector(scriptId: string, scriptAttributes: string): void {
        switch (scriptId) {
            case "create-repo-gh":
                this.createRepoSh("create-repo-gh", scriptAttributes);
                break;
            case "create-repo-az":
                this.createRepoSh("create-repo-az", scriptAttributes);
                break;
            case "create-repo-gc":
                this.createRepoSh("create-repo-gc", scriptAttributes);
                break;
            case "add-secret":
                this.addSecretSh(scriptAttributes);
                break;
            case "pipeline-generator-gh":
                this.pipelineGeneratorSh("pipeline-generator-gh", scriptAttributes);
                break;
            case "pipeline-generator-az":
                this.pipelineGeneratorSh("pipeline-generator-az", scriptAttributes);
                break;
            case "pipeline-generator-gc":
                this.pipelineGeneratorSh("pipeline-generator-gc", scriptAttributes);
                break;
            default:
                vscode.window.showErrorMessage(`🛑 No script found for radio button ID: ${scriptId}`);
        }
    }

    /**
    * Executes a script located at the given path.
    *
    * @param {string} scriptName - The name of the script to execute.
    * @param {string} scriptPath - The path where the script is located.
    * @param {string} scriptAttributes - The scriptAttributes of the script.
    */
    private executeScript(scriptName: string, scriptPath: string, scriptAttributes: string): void {
        try {
            execSync(`cd ${scriptPath} ; ./${scriptName} ${scriptAttributes}`);
        } catch (error) {
            if (typeof error === 'object' && error !== null && 'message' in error) {
                vscode.window.showErrorMessage(`${error.message}`);
            } else {
                vscode.window.showErrorMessage(`${error}`);
            }
        }
    }

    /**
     * Returns the relative path of a script located in a given subdirectory.
     * 
     * @param {string} subdirectory - The subdirectory where the script is located.
    */
    private getScriptRelativePath(subdirectory: string): string {
        const absoluteScriptPath: string = path.resolve(__dirname, `../scripts/${subdirectory}`);
        return vscode.workspace.asRelativePath(absoluteScriptPath, false);
    }

    /**
    * Opens a new tab that notifies the user that the corresponding script
    * has been executed.
    *
    * @param {string} htmlContent - The html content to be displayed in the tab.
    */
    private async displayPanel(htmlContent: string): Promise<void> {
        let panel: vscode.WebviewPanel = vscode.window.createWebviewPanel(
            'infoPanel',
            'Information',
            vscode.ViewColumn.One,
            {}
        );
        panel.webview.html = htmlContent + "<br><p>You can close this tab now.</p>";
        await new Promise(resolve => setTimeout(() => {
            panel.dispose();
            resolve(null);
        }, 100));
    }

    /**
     * Creates a repository based on the given script name and attributes.
     * 
     * @param {string} scriptName - The name of the script.
     * @param {string} scriptAttributes - The attributes for the script.
     */
    private async createRepoSh(scriptName: string, scriptAttributes: string): Promise<void> {
        let scriptPath: string = "";

        if (scriptName === "create-repo-gh") {
            scriptPath = this.getScriptRelativePath("repositories/github");
        } else if (scriptName === "create-repo-az") {
            scriptPath = this.getScriptRelativePath("repositories/azure-devops");
        } else if (scriptName === "create-repo-gc") {
            scriptPath = this.getScriptRelativePath("repositories/gcloud");
        }

        if (scriptAttributes) {
            await this.displayPanel(`<h1>🆙 THE REPO HAS BEEN CREATED !!!</h1>`);
            this.executeScript("create-repo.sh", scriptPath, scriptAttributes);
        } else {
            vscode.window.showErrorMessage("🛑 Required attributes missing");
        }
    }

    /**
    *  Uploads a file or a variable as a secret in Google Cloud Secret Manager
    *  to make it available in chosen pipelines.
    * 
    * @param {string} scriptAttributes - The attributes for the script.
    */
    private async addSecretSh(scriptAttributes: string): Promise<void> {
        let scriptPath: string = this.getScriptRelativePath("pipelines/gcloud");

        if (scriptAttributes) {
            await this.displayPanel(`<h1>⏩ THE SECRET HAS BEEN ADDED !!!</h1>`);
            this.executeScript("add-secret.sh", scriptPath, scriptAttributes);
        } else {
            vscode.window.showErrorMessage("🛑 Required attributes missing");
        }
    }

    /**
     *  Generates a workflow on github based on the given definition
     * 
     * @param {string} scriptName - The name of the script.
     * @param {string} scriptAttributes - The attributes for the script.
    */
    private async pipelineGeneratorSh(scriptName: string, scriptAttributes: string): Promise<void> {
        let scriptPath: string = "";

        if (scriptName === "pipeline-generator-gh") {
            scriptPath = this.getScriptRelativePath("pipelines/github");
        } else if (scriptName === "pipeline-generator-az") {
            scriptPath = this.getScriptRelativePath("pipelines/azure-devops");
        } else if (scriptName === "pipeline-generator-gc") {
            scriptPath = this.getScriptRelativePath("pipelines/gcloud");
        }

        if (scriptAttributes) {
            await this.displayPanel(`<h1>⏩ THE PIPELINE HAS BEEN CREATED !!!</h1>`);
            this.executeScript("pipeline_generator.sh", scriptPath, scriptAttributes);
        } else {
            vscode.window.showErrorMessage("🛑 Required attributes missing");
        }
    }
}