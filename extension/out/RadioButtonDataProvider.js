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
exports.RadioButtonDataProvider = void 0;
const vscode = __importStar(require("vscode"));
const RadioButton_1 = require("./RadioButton");
/**
 * Represents a data provider for the RadioButton in VS Code extension.
 *
 * This class is responsible for managing the state and behavior of radio buttons
 * in a VS Code sidebar. It keeps track of the radio buttons, their labels, and the
 * commands associated with them. It also provides methods for getting the tree
 * item for a given element and for getting the children of the tree.
 *
 * @example
 * const radioButtonDataProvider = new RadioButtonDataProvider(customRadioButton, 'Submit', 'submitCommand');
 *
 * @see {@link https://code.visualstudio.com/api/references/vscode-api#TreeDataProvider | VS Code TreeDataProvider API}
 *
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 3.2.0
 */
class RadioButtonDataProvider {
    radioButtons;
    runButtonLabel;
    runButtonCommand;
    documentationButtonLabel;
    documentationButtonCommand;
    /**
     * Create a new RadioButtonDataProvider.
     *
     * @param customRadioButtons - Array of ICustomRadioButtons.
     * @param runButtonLabel - Run button text.
     * @param runButtonCommand - Command to be executed.
     * @param documentationButtonLabel - Documentation button text.
     * @param documentationButtonCommand - Command to be executed.
     */
    constructor(customRadioButtons, runButtonLabel, runButtonCommand, documentationButtonLabel, documentationButtonCommand) {
        this.radioButtons = customRadioButtons.map((radioButton) => new RadioButton_1.RadioButton(radioButton));
        this.runButtonLabel = runButtonLabel;
        this.runButtonCommand = runButtonCommand;
        this.documentationButtonLabel = documentationButtonLabel;
        this.documentationButtonCommand = documentationButtonCommand;
    }
    /**
     * Get the tree item for a given element.
     *
     * This method is responsible for returning the tree item that corresponds to the given element.
     *
     * @param element - The RadioButton element for which to get the tree item.
     * @returns The tree item that corresponds to the given element.
     */
    getTreeItem(element) {
        return element;
    }
    /**
     * Return the array of RedioButtons plus the button as the root level.
     *
     * This method is responsible for returning the children of the tree, which includes all radio buttons and the button.
     *
     * @returns A promise that resolves to an array of RadioButton items, including the button.
     */
    getChildren() {
        const buttonItem = new vscode.TreeItem(this.runButtonLabel, vscode.TreeItemCollapsibleState.None);
        buttonItem.command = { command: this.runButtonCommand, title: this.runButtonLabel };
        const documentationButtonItem = new vscode.TreeItem(this.documentationButtonLabel, vscode.TreeItemCollapsibleState.None);
        documentationButtonItem.command = { command: this.documentationButtonCommand, title: this.documentationButtonLabel };
        return Promise.resolve([...this.radioButtons, buttonItem, documentationButtonItem]);
    }
}
exports.RadioButtonDataProvider = RadioButtonDataProvider;
//# sourceMappingURL=RadioButtonDataProvider.js.map