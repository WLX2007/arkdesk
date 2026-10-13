export type LuminousControlSizeValue = 'Compact' | 'Regular';

export class LuminousControlSize {
  static readonly Compact: LuminousControlSizeValue = 'Compact';
  static readonly Regular: LuminousControlSizeValue = 'Regular';
}

type LuminousToneValue = 'Accent' | 'Neutral' | 'Danger';

export class LuminousTone {
  static readonly Accent: LuminousToneValue = 'Accent';
  static readonly Neutral: LuminousToneValue = 'Neutral';
  static readonly Danger: LuminousToneValue = 'Danger';
}

export class LuminousNeoTokens {
  static readonly BASE_SURFACE_SIZE: number = 720;
  static readonly COMPACT_HEIGHT: number = 40;
  static readonly REGULAR_HEIGHT: number = 48;
  static readonly SUBTLE_RAISED_DEPTH: number = 0.35;

  static controlHeight(size: LuminousControlSizeValue): number {
    return size === LuminousControlSize.Compact
      ? LuminousNeoTokens.COMPACT_HEIGHT
      : LuminousNeoTokens.REGULAR_HEIGHT;
  }

  /**
   * Flat rendering needs no outer shadow margin, but callers lay out using
   * surfaceSize + 2 * shadowPadding, so keep a small visual breathing room.
   */
  static shadowPaddingFor(shortEdge: number): number {
    const padding = Math.round(shortEdge * 0.06);
    return Math.min(10, Math.max(2, padding));
  }
}
