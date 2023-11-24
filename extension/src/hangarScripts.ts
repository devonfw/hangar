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
 * @version 1.1.0
 */
export class HangarScripts {
    /**
     * Run the scripts associated with the given checkbox IDs.
     * 
     * @param checkboxesIds - The IDs of the checkboxes for which to run scripts.
     */
    public scriptSelector(checkboxesIds: string[]): void {
        if (checkboxesIds.includes("create-repo.sh")) { this.createRepoSh(); }
    }

    private async executeScript(scriptPath: string): Promise<string> {
        try {
            const { stdout } = await exec(`cd ${scriptPath} ; ./hello.sh`);
            return stdout;
        } catch (error) {
            throw new Error(`EXEC ERROR\n${error}`);
        }
    }

    private getScriptPath(): string {
        const absoluteScriptPath = path.resolve(__dirname, '../../scripts/repositories/github');
        return vscode.workspace.asRelativePath(absoluteScriptPath, false);
    }

    // TODO: REMOVE hello.sh
    private async createRepoSh(): Promise<void> {
        try {
            const scriptPath = this.getScriptPath();
            const stdout = await this.executeScript(scriptPath);
            console.log(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("🆙 CREATING REPO ...");
        } catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 THERE HAS BEEN AN ERROR DURING THE EXECUTION OF THE SCRIPT");
        }
    }
}