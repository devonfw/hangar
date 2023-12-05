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
exports.activate = void 0;
const vscode = __importStar(require("vscode"));
const RadioButton_1 = require("./RadioButton");
const hangarScripts_1 = require("./hangarScripts");
const hangarScripts = new hangarScripts_1.HangarScripts();
const childProcess = __importStar(require("child_process"));
function createWebviewPanel() {
    const panel = vscode.window.createWebviewPanel('scriptDocu', 'Scripts documentation', vscode.ViewColumn.One, {});
    panel.webview.html = getWebviewContent();
}
function getWebviewContent() {
    const createRepoPath = hangarScripts.getScriptRelativePath('repositories/github');
    const pipelineGeneratorPath = hangarScripts.getScriptRelativePath('pipelines/github');
    const createRepoHelp = childProcess.execSync(`cd ${createRepoPath}; ./create-repo.sh --help`).toString();
    const pipelineGeneratorHelp = childProcess.execSync(`cd ${pipelineGeneratorPath}; ./pipeline_generator.sh --help`).toString();
    return `<!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Scripts documentation</title>
        </head>
        <body>
			<h1>Scripts documentation</h1>
			<hr>
            <h2>🆙 create-repo.sh --help</h2>
            <h4>[${createRepoPath}]</h4>
            <pre>${createRepoHelp}</pre>
			<hr>
            <h2>⏩ pipeline_generator.sh --help</h2>
            <h4>[${pipelineGeneratorPath}]</h4>
            <pre>${pipelineGeneratorHelp}</pre>
        </body>
        </html>`;
}
/**
 * Activates the VS Code extension.
 *
 * This function is responsible for initializing the extension. It creates a new instance of HangarScripts,
 * defines the custom radio buttons and their labels, sets the button label and command, and registers the
 * RadioButtonDataProvider as the data provider for the "radioButtons" view. It also registers a command that
 * is executed when the button is clicked.
 *
 * @see {@link https://code.visualstudio.com/api/references/activation-events | VS Code Activation Events}
 *
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 2.0.0
 */
function activate() {
    createWebviewPanel();
    const customRadioButtons = [
        { id: "create-repo.sh", label: "🆙 Create repo (repositories/github)" },
        { id: "pipeline_generator.sh", label: "⏩ Pipeline generator (pipelines/github)" }
    ];
    const buttonLabel = "RUN";
    const buttonCommand = "hangar-cicd.runScripts";
    const radioButtonDataProvider = new RadioButton_1.RadioButtonDataProvider(customRadioButtons, buttonLabel, buttonCommand);
    vscode.window.registerTreeDataProvider("hangar-cicd", radioButtonDataProvider);
    vscode.commands.registerCommand(buttonCommand, async () => {
        let selectedRadioButtonId = [];
        radioButtonDataProvider.radioButtons.forEach(radioButton => {
            // Ensures that the selected radio button is properly set to selectedRadioButtonId
            if (radioButton.checkboxState === vscode.TreeItemCheckboxState.Checked) {
                selectedRadioButtonId.push(radioButton.id);
            }
        });
        // Avoids multiple scripts executions
        if (selectedRadioButtonId.length > 1) {
            vscode.window.showErrorMessage("ERROR: Please select only one script at a time.");
        }
        else if (selectedRadioButtonId.length === 1) {
            // Ask the user for script attributes
            let scriptAttributes = await vscode.window.showInputBox({ prompt: '✨ Enter ALL attributes separated by space ...' });
            hangarScripts.scriptSelector(selectedRadioButtonId[0], scriptAttributes);
        }
    });
}
exports.activate = activate;
//# sourceMappingURL=extension.js.map