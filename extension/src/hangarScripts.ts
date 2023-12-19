import * as vscode from "vscode";
import path from "path";
import { exec, execSync } from "child_process";


/**
 * Represents a script runner for a VS Code extension.
 * 
 * This class is responsible for executing scripts based on the selected radio button. It includes a method
 * for running the script associated with the given radio button ID.
 * 
 * Available scripts:
 * - 🆙 Create repo
 * - ⏩ Pipeline generator
 *  
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 2.2.1
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
     * scriptSelector('create-repo.sh', '-a create -n repo-test -d /local/proyect/path');
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
                // TODO: Add add secret class
                break;
            case "pipeline-generator-gh":
                this.pipelineGeneratorSh("pipeline_generator.sh", scriptAttributes);
                break;
            case "pipeline-generator-az":
                this.pipelineGeneratorSh("pipeline_generator.sh", scriptAttributes);
                break;
            case "pipeline-generator-gc":
                this.pipelineGeneratorSh("pipeline_generator.sh", scriptAttributes);
                break;
            default:
                vscode.window.showErrorMessage(`🛑 No script found for radio button ID: ${scriptId}`);
        }
    }

    /**
    * Executes a script located at the given path.
    * 
    * @param {string} scriptPath - The path where the script is located.
    * @param {string} scriptName - The name of the script to execute.
    * @param {string} scriptAttributes - The scriptAttributes of the script.
    */
    private executeScript(scriptPath: string, scriptName: string, scriptAttributes: string): void {
        try {
            execSync(`cd ${scriptPath} ; ./${scriptName} ${scriptAttributes}`);
        } catch (error) {
            if (typeof error === 'object' && error !== null && 'message' in error) {
                console.error(`Error executing script: ${error.message}`);
                vscode.window.showErrorMessage(`Error executing script: ${error.message}`);
            } else {
                console.error(`Error executing script: ${error}`);
                vscode.window.showErrorMessage(`Error executing script: ${error}`);
            }
        }
    }

    /**
     * Returns the relative path of a script located in a given subdirectory.
     * 
     * @param {string} subdirectory - The subdirectory where the script is located.
     */
    public getScriptRelativePath(subdirectory: string): string {
        const absoluteScriptPath = path.resolve(__dirname, `../../scripts/${subdirectory}`);
        return vscode.workspace.asRelativePath(absoluteScriptPath, false);
    }


    /**
     * Asynchronously creates a repository based on the given script name and attributes.
     * 
     * @param {string} scriptName - The name of the script.
     * @param {string} scriptAttributes - The attributes for the script.
     */
    private async createRepoSh(scriptName: string, scriptAttributes: string) {
        let scriptPath: string = "";

        if (scriptName === "create-repo-gh") {
            scriptPath = this.getScriptRelativePath("repositories/github");
        } else if (scriptName === "create-repo-az") {
            scriptPath = this.getScriptRelativePath("repositories/azure-devops");
        } else if (scriptName === "create-repo-gc") {
            scriptPath = this.getScriptRelativePath("repositories/gcloud");
        }

        if (scriptAttributes) {
            let panel = vscode.window.createWebviewPanel(
                'infoPanel',
                'Information',
                vscode.ViewColumn.One,
                {}
            );
            panel.webview.html = `<h1>🆙 THE REPO HAS BEEN CREATED !!!</h1>`;
            await new Promise(resolve => setTimeout(() => {
                panel.dispose();
                resolve(null);
            }, 100));
            this.executeScript(scriptPath, "create-repo.sh", scriptAttributes);
        } else {
            vscode.window.showErrorMessage("Required attributes missing");
        }
    }

    private pipelineGeneratorSh(scriptName: string, scriptAttributes: string): void {
        vscode.window.showInformationMessage("⏩ GENERATING PIPELINE ...");
        const scriptPath = this.getScriptRelativePath("pipelines/github");
        this.executeScript(scriptPath, scriptName, scriptAttributes);
    }
}