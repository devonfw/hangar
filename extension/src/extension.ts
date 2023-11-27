import * as vscode from "vscode";
import { ICustomCheckbox } from "./ICustomCheckbox";
import { CheckboxDataProvider } from "./Checkbox";
import { HangarScripts } from "./hangarScripts";

/**
 * Activates the VS Code extension.
 * 
 * This function is responsible for initializing the extension. It creates a new instance of HangarScripts,
 * defines the custom checkboxes and their labels, sets the button label and command, and registers the 
 * CheckboxDataProvider as the data provider for the "checkboxes" view. It also registers a command that 
 * is executed when the button is clicked.
 * 
 * @see {@link https://code.visualstudio.com/api/references/activation-events | VS Code Activation Events}
 * 
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.0.0
 */
export function activate() {
	const hangarScripts = new HangarScripts();

	const customCheckboxes: ICustomCheckbox[] = [
		{ id: "create-repo.sh", label: "🆙 Create repo (repositories/github)" },
		{ id: "pipeline_generator.sh", label: "⏩ Pipeline generator (pipelines/github)" }
	];

	const buttonLabel = "Run selected scripts (CLICK ME)";
	const buttonCommand = "hangar-cicd.runScripts";

	const checkboxDataProvider = new CheckboxDataProvider(customCheckboxes, buttonLabel, buttonCommand);

	vscode.window.registerTreeDataProvider("hangar-cicd", checkboxDataProvider);

	vscode.commands.registerCommand(buttonCommand, () => {
		let checkboxesIds: string[] = [];
		checkboxDataProvider.checkboxes.forEach(checkbox => {
			if (checkbox.checkboxState === 1) {
				checkboxesIds.push(checkbox.id as string);
			}
		});
		if (checkboxesIds.length) {
			hangarScripts.scriptSelector(checkboxesIds);
		} else {
			vscode.window.showErrorMessage("🤬 YOU MUST SELECT AT LEAST ONE SCRIPT !!!");
		}
	});
}