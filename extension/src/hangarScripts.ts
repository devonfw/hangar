import * as vscode from "vscode";
import path from "path";
import { promisify } from 'util';
const exec = promisify(require('child_process').exec);


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
 * @version 2.0.0
 */
export class HangarScripts {
    /**
     * Executes the scripts associated with the given radio button ID.
     * 
     * This method executes the corresponding script.
     * If no script is found for a given ID, it logs an error message.
     * 
     * @param {string} radioButtonId - The ID of the radio button selected by the user.
     * @param {string} scriptAttributes - The script attributes.
     * 
     * @example
     * scriptSelector('create-repo.sh', '-a create -n repo-test -d /local/proyect/path');
     */
    public scriptSelector(radioButtonId: string, scriptAttributes: string): void {
        switch (radioButtonId) {
            case "create-repo.sh":
                this.createRepoSh("create-repo.sh", scriptAttributes);
                break;
            case "pipeline_generator.sh":
                this.pipelineGeneratorSh("pipeline_generator.sh", scriptAttributes);
                break;
            default:
                vscode.window.showErrorMessage(`🛑 No script found for rdai button ID: ${radioButtonId}`);
        }
    }

    /**
    * Executes a script located at the given path.
    * 
    * @param {string} scriptPath - The path where the script is located.
    * @param {string} scriptName - The name of the script to execute.
    * @param {string} scriptAttributes - The scriptAttributes of the script.
    */
    private async executeScript(scriptPath: string, scriptName: string, scriptAttributes: string): Promise<string> {
        try {
            const { stdout } = await exec(`cd ${scriptPath} ; ./${scriptName} ${scriptAttributes}`);
            return stdout;
        } catch (error) {
            throw new Error(`EXEC ERROR\n${error}`);
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

    private async createRepoSh(scriptName: string, scriptAttributes: string): Promise<void> {
        try {
            const scriptPath = this.getScriptRelativePath("repositories/github");
            const stdout = await this.executeScript(scriptPath, scriptName, scriptAttributes);
            console.info(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("🆙 CREATING REPO ...");
        } catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 There has been an error during the exec of the script");
        }
    }

    private async pipelineGeneratorSh(scriptName: string, scriptAttributes: string): Promise<void> {
        try {
            const scriptPath = this.getScriptRelativePath("pipelines/github");
            const stdout = await this.executeScript(scriptPath, scriptName, scriptAttributes);
            console.info(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("⏩ GENERATING PIPELINE ...");
        } catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 There has been an error during the exec of the script");
        }
    }
}