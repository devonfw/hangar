import * as vscode from "vscode";
import { ICustomRadioButton } from "./ICustomRadioButton";
import { RadioButtonDataProvider } from "./RadioButtonDataProvider";
import { HangarScripts } from "./hangarScripts";
const hangarScripts = new HangarScripts();
import { WebviewPanelCreator } from "./WebviewPanelCreator";
const webviewPanelCreator = new WebviewPanelCreator();


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
export function activate(): void {
	const radioButtonDataProvider = createRadioButtonDataProvider();
	vscode.window.registerTreeDataProvider("hangar-cicd", radioButtonDataProvider);
	registerCommandHandler(radioButtonDataProvider);
	webviewPanelCreator.createWebviewPanel();
}

/**
 * Creates a radio button data provider.
 * 
 * @returns The radio button data provider.
 */
function createRadioButtonDataProvider(): RadioButtonDataProvider {
	const customRadioButtons: ICustomRadioButton[] = [
		{ id: "create-repo.sh", label: "🆙 Create repo" },
		{ id: "add-secret.sh", label: "🆕 Add secret" },
		{ id: "pipeline_generator.sh", label: "⏩ Pipeline generator" },
	];

	const runButtonLabel = "RUN";
	const runButtonCommand = "hangar-cicd.runScripts";

	const documentationButtonLabel = "OPEN DOCUMENTATION";
	const documentationButtonCommand = "hangar-cicd.openDocu";

	return new RadioButtonDataProvider(customRadioButtons, runButtonLabel, runButtonCommand, documentationButtonLabel, documentationButtonCommand);
}

/**
 * Registers a command handler.
 * 
 * @param radioButtonDataProvider The radio button data provider.
 */
function registerCommandHandler(radioButtonDataProvider: RadioButtonDataProvider): void {
	vscode.commands.registerCommand("hangar-cicd.openDocu", () => {
		webviewPanelCreator.createWebviewPanel();
	});

	vscode.commands.registerCommand("hangar-cicd.runScripts", async () => {
		let selectedScriptIds: string[] = [];

		radioButtonDataProvider.radioButtons.forEach(radioButton => {
			if (radioButton.checkboxState === vscode.TreeItemCheckboxState.Checked) {
				selectedScriptIds.push(radioButton.id as string);
			}
		});

		if (selectedScriptIds.length > 1) {
			vscode.window.showErrorMessage("🛑 Please select only one script at a time.");
		} else if (selectedScriptIds.length === 1) {
			let scriptPath: vscode.Uri[] | undefined = await vscode.window.showOpenDialog({
				canSelectMany: false,
				canSelectFiles: false,
				canSelectFolders: true,
				defaultUri: vscode.Uri.file('/')
			});
			let scriptAttributes: string | undefined = await vscode.window.showInputBox(
				{ prompt: '✨ Enter ALL attributes separated by space ...' }
			);

			if (scriptPath) {
				hangarScripts.scriptSelector(selectedScriptIds[0], scriptPath[0].fsPath, scriptAttributes as string);
			} else {
				vscode.window.showErrorMessage(`🛑 YOU MUST SELECT A SCRIPT FOLDER`);
			}
		}
	});
}