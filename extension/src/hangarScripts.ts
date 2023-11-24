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
    public scriptSelector(checkboxesIds: string[]): void {
        checkboxesIds.forEach(scriptId => {
            switch (scriptId) {
                case "create-repo.sh":
                    this.createRepoSh();
                    break;
                case "pipelin_generator.sh":
                    this.pipelineGeneratorSh();
                    break;
                default:
                    vscode.window.showErrorMessage(`🛑 No script found for checkbox ID: ${scriptId}`);
            }
        });
    }

    private async executeScript(scriptPath: string): Promise<string> {
        try {
            const { stdout } = await exec(`cd ${scriptPath} ; ./hello.sh`);
            return stdout;
        } catch (error) {
            throw new Error(`EXEC ERROR\n${error}`);
        }
    }

    private getScriptRelativePath(scriptName: string): string {
        const absoluteScriptPath = path.resolve(__dirname, `../../scripts/repositories/github/${scriptName}`);
        return vscode.workspace.asRelativePath(absoluteScriptPath, false);
    }

    // TODO: REMOVE hello.sh
    private async createRepoSh(): Promise<void> {
        try {
            const scriptPath = this.getScriptRelativePath('create-repo.sh');
            const stdout = await this.executeScript(scriptPath);
            console.info(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("🆙 CREATING REPO ...");
        } catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 THERE HAS BEEN AN ERROR DURING THE EXECUTION OF THE SCRIPT");
        }
    }

    private async pipelineGeneratorSh(): Promise<void> {
        try {
            const scriptPath = this.getScriptRelativePath('pipeline_generator.sh');
            const stdout = await this.executeScript(scriptPath);
            console.log(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("⏩ GENERATING PIPELINE ...");
        } catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 THERE HAS BEEN AN ERROR DURING THE EXECUTION OF THE SCRIPT");
        }
    }
}