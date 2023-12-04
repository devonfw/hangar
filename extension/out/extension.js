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
    const hangarScripts = new hangarScripts_1.HangarScripts();
    const customRadioButtons = [
        { id: "create-repo.sh", label: "🆙 Create repo (repositories/github)" },
        { id: "pipeline_generator.sh", label: "⏩ Pipeline generator (pipelines/github)" }
    ];
    const buttonLabel = "Run selected scripts (CLICK ME)";
    const buttonCommand = "hangar-cicd.runScripts";
    const radioButtonDataProvider = new RadioButton_1.RadioButtonDataProvider(customRadioButtons, buttonLabel, buttonCommand);
    vscode.window.registerTreeDataProvider("hangar-cicd", radioButtonDataProvider);
    vscode.commands.registerCommand(buttonCommand, async () => {
        let selectedRadioButtonId;
        radioButtonDataProvider.radioButtons.forEach(radioButton => {
            // Ensures that the selected radio button is properly set to selectedRadioButtonId
            if (radioButton.checkboxState === vscode.TreeItemCheckboxState.Checked) {
                selectedRadioButtonId = radioButton.id;
            }
        });
        if (selectedRadioButtonId) {
            // Ask the user for script attributes
            let scriptAttributes = await vscode.window.showInputBox({ prompt: '✨ Enter ALL attributes separated by space ...' });
            hangarScripts.scriptSelector(selectedRadioButtonId, scriptAttributes);
        }
    });
}
exports.activate = activate;
//# sourceMappingURL=extension.js.map