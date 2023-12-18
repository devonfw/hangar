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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.HangarScripts = void 0;
const vscode = __importStar(require("vscode"));
const path_1 = __importDefault(require("path"));
const child_process_1 = require("child_process");
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
class HangarScripts {
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
    scriptSelector(scriptId, scriptAttributes) {
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
    executeScript(scriptPath, scriptName, scriptAttributes) {
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
     * Returns the relative path of a script located in a given subdirectory.
     *
     * @param {string} subdirectory - The subdirectory where the script is located.
     */
    getScriptRelativePath(subdirectory) {
        const absoluteScriptPath = path_1.default.resolve(__dirname, `../../scripts/${subdirectory}`);
        return vscode.workspace.asRelativePath(absoluteScriptPath, false);
    }
    /**
     * Asynchronously creates a repository based on the given script name and attributes.
     *
     * @param {string} scriptName - The name of the script.
     * @param {string} scriptAttributes - The attributes for the script.
     */
    async createRepoSh(scriptName, scriptAttributes) {
        let scriptPath = "";
        if (scriptName === "create-repo-gh") {
            scriptPath = this.getScriptRelativePath("repositories/github");
        }
        else if (scriptName === "create-repo-az") {
            scriptPath = this.getScriptRelativePath("repositories/azure-devops");
        }
        else if (scriptName === "create-repo-gc") {
            scriptPath = this.getScriptRelativePath("repositories/gcloud");
        }
        await vscode.window.showInformationMessage("🆙 CREATING REPO ...");
        if (scriptAttributes) {
            this.executeScript(scriptPath, "create-repo.sh", scriptAttributes);
        }
        else {
            vscode.window.showErrorMessage("Required attributes missing");
        }
    }
    pipelineGeneratorSh(scriptName, scriptAttributes) {
        vscode.window.showInformationMessage("⏩ GENERATING PIPELINE ...");
        const scriptPath = this.getScriptRelativePath("pipelines/github");
        this.executeScript(scriptPath, scriptName, scriptAttributes);
    }
}
exports.HangarScripts = HangarScripts;
//# sourceMappingURL=hangarScripts.js.map