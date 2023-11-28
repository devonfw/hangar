import * as vscode from "vscode";
import path from "path";
import { promisify } from 'util';
const exec = promisify(require('child_process').exec);


/**
 * Represents a script runner for a VS Code extension.
 * 
 * This class is responsible for executing scripts based on the selected checkboxes. It includes a method
 * for running the scripts associated with the given checkbox IDs.
 * 
 * Available scripts:
 * - 🆙 Create repo
 * - ⏩ Pipeline generator
 * 
 * @example
 * const hangarScripts = new HangarScripts();
 * hangarScripts.scriptSelector(['scriptId1', 'scriptId2']);
 *  
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.2.0
 */
export class HangarScripts {
    /**
     * Executes the scripts associated with the given checkbox IDs.
     * 
     * This method iterates over the provided array of checkbox IDs, and for each ID, it executes the corresponding script.
     * If no script is found for a given ID, it logs an error message.
     * 
     * @param {string[]} checkboxesIds - The IDs of the checkboxes selected by the user.
     * 
     * @example
     * scriptSelector(['create-repo.sh', 'pipeline_generator.sh']);
     */
    public scriptSelector(checkboxesIds: string[], scriptAttributes: string): void {
        checkboxesIds.forEach(scriptId => {
            switch (scriptId) {
                case "create-repo.sh":
                    this.createRepoSh("create-repo.sh", scriptAttributes);
                    break;
                case "pipeline_generator.sh":
                    this.pipelineGeneratorSh("pipeline_generator.sh", scriptAttributes);
                    break;
                default:
                    vscode.window.showErrorMessage(`🛑 No script found for checkbox ID: ${scriptId}`);
            }
        });
    }

    /**
    * Executes a script located at the given path.
    * 
    * @param {string} scriptPath - The path where the script is located.
    * @param {string} scriptName - The name of the script to execute.
    * @param {string} scriptAttributes - The scriptAttributes of the script.
    */
    private async executeScript(scriptPath: string, scriptName: string, attributes: string): Promise<string> {
        try {
            const { stdout } = await exec(`cd ${scriptPath} ; ./${scriptName} ${attributes}`);
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
    private getScriptRelativePath(subdirectory: string): string {
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