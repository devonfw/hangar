import * as vscode from "vscode";
import * as childProcess from 'child_process';
import path from "path";


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
 * @version 1.0.0
 */
export class HangarScripts {
    /**
     * Run the scripts associated with the given checkbox IDs.
     * 
     * @param checkboxesIds - The IDs of the checkboxes for which to run scripts.
     */
    public scriptSelector(checkboxesIds: string[]): void {
        if (checkboxesIds.includes("create_repo")) { this.createRepoSh(); }
    }

    private createRepoSh(): void {
        const absoluteScriptPath = path.resolve(__dirname, '../../scripts/repositories/github');
        const relativeScriptPath = vscode.workspace.asRelativePath(absoluteScriptPath, false);

        childProcess.exec(`cd ${relativeScriptPath} ; ./hello.sh`, (error, stdout) => {
            if (error) {
                console.error(`EXEC ERROR\n${error}`);
                vscode.window.showErrorMessage("🛑 THERE HAS BEEN AN ERROR DURING THE EXECUTION OF THE SCRIPT");
                return;
            }
            console.log(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("🆙 CREATING REPO ...");
        });
    }
}