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
exports.CheckboxDataProvider = void 0;
const vscode = __importStar(require("vscode"));
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
    constructor(customCheckbox) {
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
class CheckboxDataProvider {
    checkboxes;
    buttonLabel;
    buttonCommand;
    /**
     * Create a new CheckboxDataProvider.
     *
     * @param customCheckboxes - Array of custom ICustomCheckbox.
     * @param buttonLabel - Button text.
     * @param buttonCommand - Command to be executed.
     */
    constructor(customCheckboxes, buttonLabel, buttonCommand) {
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
    getTreeItem(element) {
        return element;
    }
    /**
     * Return the array of checkboxes plus the button as the root level.
     *
     * This method is responsible for returning the children of the tree, which includes all checkboxes and the button.
     *
     * @returns A promise that resolves to an array of Checkbox items, including the button.
     */
    getChildren() {
        const buttonItem = new vscode.TreeItem(this.buttonLabel, vscode.TreeItemCollapsibleState.None);
        buttonItem.command = { command: this.buttonCommand, title: this.buttonLabel };
        return Promise.resolve([...this.checkboxes, buttonItem]);
    }
}
exports.CheckboxDataProvider = CheckboxDataProvider;
//# sourceMappingURL=Checkbox.js.map