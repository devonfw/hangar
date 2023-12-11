import * as vscode from "vscode";
import { ICustomRadioButton } from "./ICustomRadioButton";
import { RadioButton } from "./RadioButton";

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
 * @version 3.1.0
 */
export class RadioButtonDataProvider implements vscode.TreeDataProvider<RadioButton> {
    public radioButtons: RadioButton[];
    private runButtonLabel: string;
    private runButtonCommand: string;
    private documentationButtonLabel: string;
    private documentationButtonCommand: string;

    /**
     * Create a new RadioButtonDataProvider.
     * 
     * @param customRadioButtons - Array of ICustomRadioButtons.
     * @param runButtonLabel - Run button text.
     * @param runButtonCommand - Command to be executed.
     * @param documentationButtonLabel - Documentation button text.
     * @param documentationButtonCommand - Command to be executed.
     */
    constructor(customRadioButtons: ICustomRadioButton[], runButtonLabel: string, runButtonCommand: string, documentationButtonLabel: string, documentationButtonCommand: string) {
        this.radioButtons = customRadioButtons.map((radioButton) => new RadioButton(radioButton));
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
    getTreeItem(element: RadioButton): vscode.TreeItem | Thenable<vscode.TreeItem> {
        return element;
    }

    /**
     * Return the array of RedioButtons plus the button as the root level.
     * 
     * This method is responsible for returning the children of the tree, which includes all radio buttons and the button.
     * 
     * @returns A promise that resolves to an array of RadioButton items, including the button.
     */
    getChildren(): vscode.ProviderResult<RadioButton[]> {
        const buttonItem = new vscode.TreeItem(this.runButtonLabel, vscode.TreeItemCollapsibleState.None);
        buttonItem.command = { command: this.runButtonCommand, title: this.runButtonLabel };

        const documentationButtonItem = new vscode.TreeItem(this.documentationButtonLabel, vscode.TreeItemCollapsibleState.None);
        documentationButtonItem.command = { command: this.documentationButtonCommand, title: this.documentationButtonLabel };

        return Promise.resolve([...this.radioButtons, buttonItem, documentationButtonItem]);
    }
}
