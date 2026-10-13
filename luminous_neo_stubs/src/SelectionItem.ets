/**
 * Selection option descriptor used by LuminousSegmentedControl and
 * LuminousSecondaryMenu. Callers construct it with 2-4 positional args:
 *   new LuminousSelectionItem(key, label)
 *   new LuminousSelectionItem(key, label, description)
 *   new LuminousSelectionItem(key, label, description, isEnabled)
 */
export class LuminousSelectionItem {
  readonly key: string;
  readonly label: ResourceStr;
  readonly description: ResourceStr;
  readonly isEnabled: boolean;

  constructor(key: string, label: ResourceStr, description: ResourceStr = '', isEnabled: boolean = true) {
    this.key = key;
    this.label = label;
    this.description = description;
    this.isEnabled = isEnabled;
  }
}
