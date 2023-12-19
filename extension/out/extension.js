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
const RadioButtonDataProvider_1 = require("./RadioButtonDataProvider");
const hangarScripts_1 = require("./hangarScripts");
const hangarScripts = new hangarScripts_1.HangarScripts();
const WebviewPanelCreator_1 = require("./WebviewPanelCreator");
const webviewPanelCreator = new WebviewPanelCreator_1.WebviewPanelCreator();
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
 * @version 3.3.0
 */
function activate() {
    const radioButtonDataProvider = createRadioButtonDataProvider();
    vscode.window.registerTreeDataProvider("hangar-cicd", radioButtonDataProvider);
    registerCommandHandler(radioButtonDataProvider);
    webviewPanelCreator.createWebviewPanel();
}
exports.activate = activate;
/**
 * Creates a radio button data provider.
 *
 * @returns The radio button data provider.
 */
function createRadioButtonDataProvider() {
    const customRadioButtons = [
        { id: "create-repo.sh", label: "🆙 Create repo" },
        { id: "add-secret.sh", label: "🆕 Add secret" },
        { id: "pipeline_generator.sh", label: "⏩ Pipeline generator" },
    ];
    const runButtonLabel = "RUN";
    const runButtonCommand = "hangar-cicd.runScripts";
    const documentationButtonLabel = "OPEN DOCUMENTATION";
    const documentationButtonCommand = "hangar-cicd.openDocu";
    return new RadioButtonDataProvider_1.RadioButtonDataProvider(customRadioButtons, runButtonLabel, runButtonCommand, documentationButtonLabel, documentationButtonCommand);
}
/**
 * Registers a command handler.
 *
 * @param radioButtonDataProvider The radio button data provider.
 */
function registerCommandHandler(radioButtonDataProvider) {
    vscode.commands.registerCommand("hangar-cicd.openDocu", () => {
        webviewPanelCreator.createWebviewPanel();
    });
    vscode.commands.registerCommand("hangar-cicd.runScripts", async () => {
        let selectedScriptIds = [];
        radioButtonDataProvider.radioButtons.forEach(radioButton => {
            if (radioButton.checkboxState === vscode.TreeItemCheckboxState.Checked) {
                selectedScriptIds.push(radioButton.id);
            }
        });
        if (selectedScriptIds.length > 1) {
            vscode.window.showErrorMessage("🛑 Please select only one script at a time.");
        }
        else if (selectedScriptIds.length === 1) {
            let scriptPath = await vscode.window.showOpenDialog({
                canSelectMany: false,
                canSelectFiles: false,
                canSelectFolders: true,
                openLabel: 'Open',
                defaultUri: vscode.Uri.file('/')
            });
            let scriptAttributes = await vscode.window.showInputBox({ prompt: '✨ Enter ALL attributes separated by space ...' });
            if (scriptPath) {
                hangarScripts.scriptSelector(selectedScriptIds[0], scriptPath[0].fsPath, scriptAttributes);
            }
            else {
                vscode.window.showErrorMessage(`🛑 YOU MUST SELECT A SCRIPT FOLDER`);
            }
        }
    });
}
//# sourceMappingURL=extension.js.map