/**
 * Static stand-in for the motion-reactive light controller.
 * The app only calls the static control methods to gate sensor usage; a
 * no-op implementation is functionally correct for a flat-UI substitute.
 */
export class LuminousMotionLight {
  static suspend(): void {
  }

  static resume(): void {
  }

  static enableSensorSubscription(): void {
  }

  static disableSensorSubscription(): void {
  }
}
