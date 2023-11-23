/**
 * Represents a custom checkbox in a VS Code extension.
 * 
 * This interface defines the structure of a custom checkbox, which includes a unique identifier and a label.
 * 
 * @example
 * const customCheckbox: ICustomCheckbox = { id: 'exampleId', label: 'Example' };
 * 
 * @author ADCenter Spain - DevOn Hangar Team
 * @version 1.0.0
 */
export interface ICustomCheckbox {
    id: string;
    label: string;
}
