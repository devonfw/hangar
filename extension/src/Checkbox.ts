import * as vscode from "vscode";
import { ICustomCheckbox } from "./ICustomCheckbox";

/**
 * Represents a checkbox item in a VS Code extension.
 * 
 * This class extends the vscode.TreeItem and is responsible for managing the state and behavior of a checkbox
 * in a VS Code sidebar. It keeps track of the checkbox's label, state, and unique identifier.
 * 
 * @example
 * const checkbox = new Checkbox({label: 'Example', id: 'exampleId'});
 * 
 * @see {@link https://code.visualstudio.com/api/references/vscode-api#TreeItem | VS Code TreeItem API}
 * 
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.0.0
 */
class Checkbox extends vscode.TreeItem {
    /**
     * Create a new Checkbox.
     * 
     * @param customCheckbox - The custom checkbox object. (ICustomCheckbox)
     */
    constructor(customCheckbox: ICustomCheckbox) {
        super(customCheckbox.label, vscode.TreeItemCollapsibleState.None);
        this.checkboxState = vscode.TreeItemCheckboxState.Unchecked;
        this.id = customCheckbox.id;
    }
}

/**
 * Represents a data provider for checkboxes in a VS Code extension.
 * 
 * This class is responsible for managing the state and behavior of checkboxes
 * in a VS Code sidebar. It keeps track of the checkboxes, their labels, and the
 * commands associated with them. It also provides methods for getting the tree
 * item for a given element and for getting the children of the tree.
 * 
 * @example
 * const checkboxDataProvider = new CheckboxDataProvider(customCheckboxes, 'Submit', 'submitCommand');
 * 
 * @see {@link https://code.visualstudio.com/api/references/vscode-api#TreeDataProvider | VS Code TreeDataProvider API}
 * 
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.0.0
 */
export class CheckboxDataProvider implements vscode.TreeDataProvider<Checkbox> {
    public checkboxes: Checkbox[];
    private buttonLabel: string;
    private buttonCommand: string;

    /**
     * Create a new CheckboxDataProvider.
     * 
     * @param customCheckboxes - Array of custom ICustomCheckbox.
     * @param buttonLabel - Button text.
     * @param buttonCommand - Command to be executed.
     */
    constructor(customCheckboxes: ICustomCheckbox[], buttonLabel: string, buttonCommand: string) {
        this.checkboxes = customCheckboxes.map((checkbox) => new Checkbox(checkbox));
        this.buttonLabel = buttonLabel;
        this.buttonCommand = buttonCommand;
    }

    /**
     * Get the tree item for a given element.
     * 
     * This method is responsible for returning the tree item that corresponds to the given element.
     * 
     * @param element - The Checkbox element for which to get the tree item.
     * @returns The tree item that corresponds to the given element.
     */
    getTreeItem(element: Checkbox): vscode.TreeItem | Thenable<vscode.TreeItem> {
        return element;
    }

    /**
     * Return the array of checkboxes plus the button as the root level.
     * 
     * This method is responsible for returning the children of the tree, which includes all checkboxes and the button.
     * 
     * @returns A promise that resolves to an array of Checkbox items, including the button.
     */
    getChildren(): vscode.ProviderResult<Checkbox[]> {
        const buttonItem = new vscode.TreeItem(this.buttonLabel, vscode.TreeItemCollapsibleState.None);
        buttonItem.command = { command: this.buttonCommand, title: this.buttonLabel };
        return Promise.resolve([...this.checkboxes, buttonItem]);
    }
}
