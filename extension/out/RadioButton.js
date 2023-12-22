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
exports.RadioButton = void 0;
const vscode = __importStar(require("vscode"));
/**
 * Represents a RadioButton item in a VS Code extension.
 *
 * This class extends the vscode.TreeItem and is responsible for managing the state and behavior of a radio button
 * in a VS Code sidebar. It keeps track of the radio button's label, state, and unique identifier.
 *
 * @example
 * const radioButton = new RadioButton({label: 'Example', id: 'exampleId'});
 *
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.0.0
 *
 * @see {@link https://code.visualstudio.com/api/references/vscode-api#TreeItem | VS Code TreeItem API}
 */
class RadioButton extends vscode.TreeItem {
    /**
     * Create a new RadioButton.
     *
     * @param customRadioButton - The custom radio button object. (ICustomRadioButton)
     */
    constructor(customRadioButton) {
        super(customRadioButton.label, vscode.TreeItemCollapsibleState.None);
        this.id = customRadioButton.id;
        this.checkboxState = vscode.TreeItemCheckboxState.Unchecked;
    }
}
exports.RadioButton = RadioButton;
//# sourceMappingURL=RadioButton.js.map