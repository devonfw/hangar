import * as vscode from "vscode";

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
        vscode.window.showInformationMessage("🤞 RUNNING = " + checkboxesIds);
    }
}