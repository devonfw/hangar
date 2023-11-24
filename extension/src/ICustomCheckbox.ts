/**
 * Represents a custom checkbox in a VS Code extension.
 * 
 * This interface defines the structure of a custom checkbox, which includes a unique identifier and a label.
 * 
 * @param id - 🛑 IMPORTANT: Use same script filename for the id 🛑
 * @param label - Checkbox text
 * 
 * @example
 * const customCheckbox: ICustomCheckbox = { id: 'create-repo.sh', label: '🆙 Create repo' };
 * 
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.1.0
 */
export interface ICustomCheckbox {
    id: string;
    label: string;
}
