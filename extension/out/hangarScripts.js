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
class HangarScripts {
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
    scriptSelector(checkboxesIds) {
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
    async executeScript(scriptPath) {
        try {
            const { stdout } = await exec(`cd ${scriptPath} ; ./hello.sh`);
            return stdout;
        }
        catch (error) {
            throw new Error(`EXEC ERROR\n${error}`);
        }
    }
    getScriptRelativePath(scriptName) {
        const absoluteScriptPath = path_1.default.resolve(__dirname, `../../scripts/repositories/github/${scriptName}`);
        return vscode.workspace.asRelativePath(absoluteScriptPath, false);
    }
    // TODO: REMOVE hello.sh
    async createRepoSh() {
        try {
            const scriptPath = this.getScriptRelativePath('create-repo.sh');
            const stdout = await this.executeScript(scriptPath);
            console.info(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("🆙 CREATING REPO ...");
        }
        catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 THERE HAS BEEN AN ERROR DURING THE EXECUTION OF THE SCRIPT");
        }
    }
    async pipelineGeneratorSh() {
        try {
            const scriptPath = this.getScriptRelativePath('pipeline_generator.sh');
            const stdout = await this.executeScript(scriptPath);
            console.log(`STDOUT\n${stdout}`);
            vscode.window.showInformationMessage("⏩ GENERATING PIPELINE ...");
        }
        catch (error) {
            console.error(error);
            vscode.window.showErrorMessage("🛑 THERE HAS BEEN AN ERROR DURING THE EXECUTION OF THE SCRIPT");
        }
    }
}
exports.HangarScripts = HangarScripts;
//# sourceMappingURL=hangarScripts.js.map