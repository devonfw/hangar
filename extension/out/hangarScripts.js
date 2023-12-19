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
exports.HangarScripts = void 0;
const vscode = __importStar(require("vscode"));
const child_process_1 = require("child_process");
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
 * @version 3.0.0
 */
class HangarScripts {
    /**
     * Executes the scripts associated with the given script ID.
     *
     * This method executes the corresponding script.
     * If no script is found for a given ID, it logs an error message.
     *
     * @param {string} scriptId - The ID of the selected script.
     * @param {string} scriptPath - The relative path of the script.
     * @param {string} scriptAttributes - The script attributes.
     *
     * @example
     * scriptSelector('create-repo.sh', '/script/folder/path', '-a create -n repo-test -d /local/project/path');
     */
    scriptSelector(scriptId, scriptPath, scriptAttributes) {
        switch (scriptId) {
            case "create-repo.sh":
                this.createRepoSh(scriptId, scriptPath, scriptAttributes);
                break;
            case "add-secret.sh":
                // TODO: Add 'addSecretSh()' class
                break;
            case "pipeline_generator.sh":
                this.pipelineGeneratorSh("pipeline_generator.sh", scriptPath, scriptAttributes);
                break;
            default:
                vscode.window.showErrorMessage(`🛑 No script found for radio button ID: ${scriptId}`);
        }
    }
    /**
    * Executes a script located at the given path.
    * TODO: Remove scriptName and make scriptPath have the ../../script-name.sh
    * @param {string} scriptName - The name of the script to execute.
    * @param {string} scriptPath - The path where the script is located.
    * @param {string} scriptAttributes - The scriptAttributes of the script.
    */
    executeScript(scriptName, scriptPath, scriptAttributes) {
        try {
            (0, child_process_1.execSync)(`cd ${scriptPath} ; ./${scriptName} ${scriptAttributes}`);
        }
        catch (error) {
            if (typeof error === 'object' && error !== null && 'message' in error) {
                console.error(`Error executing script: ${error.message}`);
                vscode.window.showErrorMessage(`Error executing script: ${error.message}`);
            }
            else {
                console.error(`Error executing script: ${error}`);
                vscode.window.showErrorMessage(`Error executing script: ${error}`);
            }
        }
    }
    /**
     * Asynchronously creates a repository based on the given script name and attributes.
     *
     * @param {string} scriptName - The name of the script.
     * @param {string} scriptPath - The path of the script.
     * @param {string} scriptAttributes - The attributes for the script.
     */
    async createRepoSh(scriptName, scriptPath, scriptAttributes) {
        if (scriptAttributes) {
            let panel = vscode.window.createWebviewPanel('infoPanel', 'Information', vscode.ViewColumn.One, {});
            panel.webview.html = `<h1>🆙 THE REPO HAS BEEN CREATED !!!</h1>`;
            await new Promise(resolve => setTimeout(() => {
                panel.dispose();
                resolve(null);
            }, 100));
            this.executeScript(scriptName, scriptPath, scriptAttributes);
        }
        else {
            vscode.window.showErrorMessage("Required attributes missing");
        }
    }
    pipelineGeneratorSh(scriptName, scriptPath, scriptAttributes) {
        vscode.window.showInformationMessage("⏩ GENERATING PIPELINE ...");
        this.executeScript(scriptPath, scriptName, scriptAttributes);
    }
}
exports.HangarScripts = HangarScripts;
//# sourceMappingURL=hangarScripts.js.map