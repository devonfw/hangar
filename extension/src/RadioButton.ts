import * as vscode from "vscode";
import { ICustomRadioButton } from "./ICustomRadioButton";

/**
 * Represents a RadioButton item in a VS Code extension.
 * 
 * This class extends the vscode.TreeItem and is responsible for managing the state and behavior of a radio button
 * in a VS Code sidebar. It keeps track of the radio button's label, state, and unique identifier.
 * 
 * @example
 * const radioButton = new RadioButton({label: 'Example', id: 'exampleId'});
 * 
 * @see {@link https://code.visualstudio.com/api/references/vscode-api#TreeItem | VS Code TreeItem API}
 */
export class RadioButton extends vscode.TreeItem {
    /**
     * Create a new RadioButton.
     * 
     * @param customRadioButton - The custom radio button object. (ICustomRadioButton)
     */
    constructor(customRadioButton: ICustomRadioButton) {
        super(customRadioButton.label, vscode.TreeItemCollapsibleState.None);
        this.id = customRadioButton.id;
        this.checkboxState = vscode.TreeItemCheckboxState.Unchecked;
    }
}
