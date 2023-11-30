import * as vscode from "vscode";
import { ICustomRadioButton } from "./ICustomRadioButton";
import { RadioButtonDataProvider } from "./RadioButton";
import { HangarScripts } from "./hangarScripts";

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
export function activate() {
	const hangarScripts = new HangarScripts();

	const customRadioButtons: ICustomRadioButton[] = [
		{ id: "create-repo.sh", label: "🆙 Create repo (repositories/github)" },
		{ id: "pipeline_generator.sh", label: "⏩ Pipeline generator (pipelines/github)" }
	];

	const buttonLabel = "Run selected scripts (CLICK ME)";
	const buttonCommand = "hangar-cicd.runScripts";

	const radioButtonDataProvider = new RadioButtonDataProvider(customRadioButtons, buttonLabel, buttonCommand);

	vscode.window.registerTreeDataProvider("hangar-cicd", radioButtonDataProvider);

	vscode.commands.registerCommand(buttonCommand, async () => {
		let selectedRadioButtonId: string | undefined;
		radioButtonDataProvider.radioButtons.forEach(radioButton => {
			// Ensures that the selected radio button is properly set to selectedRadioButtonId
			if (selectedRadioButtonId) { return; }
			selectedRadioButtonId = radioButton.id as string;
		});
		if (selectedRadioButtonId) {
			// Ask the user for script attributes
			let scriptAttributes: string | undefined = await vscode.window.showInputBox(
				{ prompt: '✨ Enter ALL attributes separated by space ...' }
			);
			hangarScripts.scriptSelector(selectedRadioButtonId, scriptAttributes as string);
		}
	});
}