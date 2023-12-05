import * as vscode from "vscode";
import { ICustomRadioButton } from "./ICustomRadioButton";
import { RadioButtonDataProvider } from "./RadioButton";
import { HangarScripts } from "./hangarScripts";
const hangarScripts = new HangarScripts();
import * as childProcess from 'child_process';


function createWebviewPanel() {
	const panel = vscode.window.createWebviewPanel(
		'scriptDocu',
		'Scripts documentation',
		vscode.ViewColumn.One,
		{}
	);

	panel.webview.html = getWebviewContent();
}

function getWebviewContent() {
	const createRepoPath = hangarScripts.getScriptRelativePath('repositories/github');
	const pipelineGeneratorPath = hangarScripts.getScriptRelativePath('pipelines/github');

	const createRepoHelp = childProcess.execSync(`cd ${createRepoPath}; ./create-repo.sh --help`).toString();
	const pipelineGeneratorHelp = childProcess.execSync(`cd ${pipelineGeneratorPath}; ./pipeline_generator.sh --help`).toString();

	return `<!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Scripts documentation</title>
        </head>
        <body>
			<h1>Scripts documentation</h1>
			<hr>
            <h2>🆙 create-repo.sh --help</h2>
            <h4>[${createRepoPath}]</h4>
            <pre>${createRepoHelp}</pre>
			<hr>
            <h2>⏩ pipeline_generator.sh --help</h2>
            <h4>[${pipelineGeneratorPath}]</h4>
            <pre>${pipelineGeneratorHelp}</pre>
        </body>
        </html>`;
}

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
	createWebviewPanel();

	const customRadioButtons: ICustomRadioButton[] = [
		{ id: "create-repo.sh", label: "🆙 Create repo (repositories/github)" },
		{ id: "pipeline_generator.sh", label: "⏩ Pipeline generator (pipelines/github)" }
	];

	const buttonLabel = "RUN";
	const buttonCommand = "hangar-cicd.runScripts";

	const radioButtonDataProvider = new RadioButtonDataProvider(customRadioButtons, buttonLabel, buttonCommand);

	vscode.window.registerTreeDataProvider("hangar-cicd", radioButtonDataProvider);

	vscode.commands.registerCommand(buttonCommand, async () => {
		let selectedRadioButtonId: string[] = [];
		radioButtonDataProvider.radioButtons.forEach(radioButton => {
			// Ensures that the selected radio button is properly set to selectedRadioButtonId
			if (radioButton.checkboxState === vscode.TreeItemCheckboxState.Checked) {
				selectedRadioButtonId.push(radioButton.id as string);
			}
		});
		// Avoids multiple scripts executions
		if (selectedRadioButtonId.length > 1) {
			vscode.window.showErrorMessage("ERROR: Please select only one script at a time.");
		} else if (selectedRadioButtonId.length === 1) {
			// Ask the user for script attributes
			let scriptAttributes: string | undefined = await vscode.window.showInputBox(
				{ prompt: '✨ Enter ALL attributes separated by space ...' }
			);
			console.info(selectedRadioButtonId);
			hangarScripts.scriptSelector(selectedRadioButtonId[0], scriptAttributes as string);
		}
	});
}