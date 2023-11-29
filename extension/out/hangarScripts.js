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
const util_1 = require("util");
const exec = (0, util_1.promisify)(require('child_process').exec);
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
 * @example
 * const hangarScripts = new HangarScripts();
 * hangarScripts.scriptSelector('scriptId1');
 *
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 2.0.0
 */
class HangarScripts {
    /**
     * Executes the scripts associated with the given radio button ID.
     *
     * This method iterates over the provided array of checkbox IDs, and for each ID, it executes the corresponding script.
     * If no script is found for a given ID, it logs an error message.
     *
     * @param {string[]} checkboxesIds - The IDs of the checkboxes selected by the user.
     *
     * @example
     * scriptSelector(['create-repo.sh', 'pipeline_generator.sh']);
     */
    scriptSelector(checkboxesIds, scriptAttributes) {
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
    async executeScript(scriptPath, scriptName, attributes) {
        try {
            const { stdout } = await exec(`cd ${scriptPath} ; ./${scriptName} ${attributes}`);
            return stdout;
        }
        catch (error) {
            throw new Error(`EXEC ERROR\n${error}`);
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
    async createRepoSh(scriptName, scriptAttributes) {
        try {
            const scriptPath = this.getScriptRelativePath("repositories/github");
            const stdout = await this.executeScript(scriptPath, scriptName, scriptAttributes);
            console.info(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("🆙 CREATING REPO ...");
        }
        catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 There has been an error during the exec of the script");
        }
    }
    async pipelineGeneratorSh(scriptName, scriptAttributes) {
        try {
            const scriptPath = this.getScriptRelativePath("pipelines/github");
            const stdout = await this.executeScript(scriptPath, scriptName, scriptAttributes);
            console.info(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("⏩ GENERATING PIPELINE ...");
        }
        catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 There has been an error during the exec of the script");
        }
    }
}
exports.HangarScripts = HangarScripts;
//# sourceMappingURL=hangarScripts.js.map