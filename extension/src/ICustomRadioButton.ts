/**
 * Represents a custom radio button in a VS Code extension.
 *
 * This interface defines the structure of a custom radio button, which includes a unique identifier and a label.
 *
 * @param id - 🛑 IMPORTANT: Use same script filename for the id 🛑
 * @param label - Radio button text
 *
 * @example
 * const customRadioButton: ICustomRadioButton = { id: 'create-repo.sh', label: '🆙 Create repo' };
 *
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 2.0.2
 */
export interface ICustomRadioButton {
    id: string;
    label: string;
}