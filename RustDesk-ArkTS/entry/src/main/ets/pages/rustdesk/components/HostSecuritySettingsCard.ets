import {
  ControlledHostState,
  ControlledPasswordMode,
  ControlledTrustedDevice,
  ControlledTwoFactorState,
  PASSWORD_MODE_BOTH,
  PASSWORD_MODE_PERMANENT,
  PASSWORD_MODE_TEMPORARY,
} from '../../../services/controlled/ControlledHostTypes';

export interface HostSecuritySettingsCardProps {
  hostState: ControlledHostState;
  twoFactor: ControlledTwoFactorState;
  onRefresh: () => void;
  onPasswordModeChange: (mode: ControlledPasswordMode) => void;
  onSetPermanentPassword: (password: string, confirmation: string) => void;
  onRemovePermanentPassword: () => void;
  onBeginTwoFactor: () => void;
  onVerifyTwoFactor: (code: string) => void;
  onCancelTwoFactor: () => void;
  onDisableTwoFactor: () => void;
  onTrustedDevicesEnabledChange: (enabled: boolean) => void;
  onRemoveTrustedDevice: (device: ControlledTrustedDevice) => void;
  onClearTrustedDevices: () => void;
}

@ComponentV2
export struct HostSecuritySettingsCard {
  @Param hostState: ControlledHostState = new ControlledHostState();
  @Param twoFactor: ControlledTwoFactorState = new ControlledTwoFactorState();
  @Local viewportWidth: number = 390;
  @Local fixedPassword: string = '';
  @Local fixedPasswordConfirmation: string = '';
  @Local twoFactorCode: string = '';
  @Local setupSecretVisible: boolean = false;
  @Local confirmRemovePassword: boolean = false;
  @Local confirmDisableTwoFactor: boolean = false;
  @Local confirmClearTrustedDevices: boolean = false;
  @Event onRefresh: () => void = () => {};
  @Event onPasswordModeChange: (mode: ControlledPasswordMode) => void = (_mode: ControlledPasswordMode) => {};
  @Event onSetPermanentPassword: (password: string, confirmation: string) => void =
    (_password: string, _confirmation: string) => {};
  @Event onRemovePermanentPassword: () => void = () => {};
  @Event onBeginTwoFactor: () => void = () => {};
  @Event onVerifyTwoFactor: (code: string) => void = (_code: string) => {};
  @Event onCancelTwoFactor: () => void = () => {};
  @Event onDisableTwoFactor: () => void = () => {};
  @Event onTrustedDevicesEnabledChange: (enabled: boolean) => void = (_enabled: boolean) => {};
  @Event onRemoveTrustedDevice: (device: ControlledTrustedDevice) => void = (_device: ControlledTrustedDevice) => {};
  @Event onClearTrustedDevices: () => void = () => {};

  aboutToDisappear(): void {
    this.clearSecretDrafts();
    this.setupSecretVisible = false;
    if (this.twoFactor.setupUri.length > 0 && !this.twoFactor.enabled) {
      this.onCancelTwoFactor();
    }
  }

  @Monitor('twoFactor.setupUri')
  private onTwoFactorSetupChanged(_monitor: IMonitor): void {
    this.twoFactorCode = '';
    this.setupSecretVisible = false;
  }

  private contentWidth(): number {
    return Math.max(280, Math.min(this.viewportWidth - 40, 560));
  }

  private passwordModeIndex(): number {
    if (this.hostState.verificationMethod === PASSWORD_MODE_TEMPORARY) {
      return 0;
    }
    if (this.hostState.verificationMethod === PASSWORD_MODE_PERMANENT) {
      return 1;
    }
    return 2;
  }

  private permanentPasswordEnabled(): boolean {
    return this.hostState.verificationMethod !== PASSWORD_MODE_TEMPORARY;
  }

  private passwordValidationText(): string {
    if (this.fixedPassword.length === 0 && this.fixedPasswordConfirmation.length === 0) {
      return '';
    }
    if (this.fixedPassword.length < 6) {
      return '固定密码至少需要 6 个字符。';
    }
    if (this.fixedPassword.length > this.hostState.maxPasswordLength) {
      return `固定密码不能超过 ${this.hostState.maxPasswordLength} 个字符。`;
    }
    if (this.fixedPassword !== this.fixedPasswordConfirmation) {
      return '两次输入的固定密码不一致。';
    }
    return '';
  }

  private canSubmitPassword(): boolean {
    return !this.hostState.permanentPasswordChangeDisabled && this.fixedPassword.length >= 6 &&
      this.fixedPassword === this.fixedPasswordConfirmation &&
      this.fixedPassword.length <= this.hostState.maxPasswordLength;
  }

  private clearPasswordDrafts(): void {
    this.fixedPassword = '';
    this.fixedPasswordConfirmation = '';
  }

  private clearSecretDrafts(): void {
    this.clearPasswordDrafts();
    this.twoFactorCode = '';
  }

  private submitPermanentPassword(): void {
    if (!this.canSubmitPassword()) {
      return;
    }
    const password: string = this.fixedPassword;
    const confirmation: string = this.fixedPasswordConfirmation;
    this.clearPasswordDrafts();
    this.onSetPermanentPassword(password, confirmation);
  }

  private setupSecret(): string {
    const result: RegExpExecArray | null = /(?:\?|&)secret=([^&]+)/.exec(this.twoFactor.setupUri);
    if (result === null || result.length < 2) {
      return '';
    }
    return decodeURIComponent(result[1]);
  }

  private trustedDeviceTitle(device: ControlledTrustedDevice): string {
    const name: string = device.name.trim();
    if (name.length > 0) {
      return name;
    }
    const id: string = device.id.trim();
    return id.length > 0 ? id : '未命名设备';
  }

  // ── 通用构件 ────────────────────────────────

  @Builder
  private SectionHeading(icon: Resource, title: string, subtitle: string, tone: ResourceColor,
    soft: ResourceColor) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph(icon)
          .fontSize(20)
          .fontColor([tone]);
      }
      .width(42)
      .height(42)
      .borderRadius(12)
      .backgroundColor(soft);

      Column({ space: 3 }) {
        Text(title)
          .width('100%')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'));
        if (subtitle.length > 0) {
          Text(subtitle)
            .width('100%')
            .fontSize(12)
            .lineHeight(17)
            .fontColor($r('app.color.text_tertiary'));
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  private FieldLabel(text: string) {
    Text(text)
      .width('100%')
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_secondary'));
  }

  @Builder
  private FieldInput(placeholder: string, value: string, maxLength: number, enabled: boolean,
    onChange: (value: string) => void) {
    TextInput({ text: value, placeholder: placeholder })
      .type(InputType.Password)
      .maxLength(maxLength)
      .width('100%')
      .height(48)
      .fontSize(15)
      .fontColor($r('app.color.text_primary'))
      .placeholderColor($r('app.color.text_tertiary'))
      .placeholderFont({ size: 14 })
      .backgroundColor($r('app.color.field_background'))
      .borderRadius(12)
      .border({ width: 1.5, color: $r('app.color.field_border') })
      .opacity(enabled ? 1 : 0.45)
      .enabled(enabled)
      .onChange(onChange);
  }

  @Builder
  private SegmentOption(label: string, index: number, enabled: boolean) {
    Text(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .fontWeight(this.passwordModeIndex() === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.passwordModeIndex() === index
        ? $r('app.color.text_inverse')
        : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .borderRadius(11)
      .backgroundColor(this.passwordModeIndex() === index
        ? $r('app.color.brand_primary')
        : Color.Transparent)
      .opacity(enabled ? 1 : 0.4)
      .onClick(() => {
        if (!enabled) {
          return;
        }
        const modes: ControlledPasswordMode[] = [
          PASSWORD_MODE_TEMPORARY,
          PASSWORD_MODE_PERMANENT,
          PASSWORD_MODE_BOTH,
        ];
        this.clearPasswordDrafts();
        this.onPasswordModeChange(modes[index]);
      });
  }

  // ── ① 访问密码 ──────────────────────────────

  @Builder
  private PasswordCard() {
    Column({ space: 16 }) {
      this.SectionHeading(
        $r('sys.symbol.lock_shield'),
        '访问密码',
        '密码只通过回调交给安全服务处理，输入草稿不会持久化',
        $r('app.color.brand_primary'),
        $r('app.color.brand_primary_soft'),
      );

      Row({ space: 4 }) {
        this.SegmentOption('临时密码', 0, !this.hostState.verificationMethodFixed);
        this.SegmentOption('固定密码', 1, !this.hostState.verificationMethodFixed);
        this.SegmentOption('两者', 2, !this.hostState.verificationMethodFixed);
      }
      .width('100%')
      .padding(3)
      .borderRadius(14)
      .backgroundColor($r('app.color.surface_secondary'));

      if (this.permanentPasswordEnabled()) {
        Row({ space: 8 }) {
          Row()
            .width(8)
            .height(8)
            .borderRadius(999)
            .backgroundColor(this.hostState.permanentPasswordSet
              ? $r('app.color.success')
              : $r('app.color.warning'));
          Text(this.hostState.permanentPasswordSet ? '固定密码已设置' : '固定密码尚未设置')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.hostState.permanentPasswordSet
              ? $r('app.color.success')
              : $r('app.color.warning'));
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);

        Column({ space: 8 }) {
          this.FieldLabel(this.hostState.permanentPasswordSet ? '输入新的固定密码' : '设置固定密码');
          this.FieldInput(
            this.hostState.permanentPasswordSet ? '输入新的固定密码' : '设置固定密码',
            this.fixedPassword,
            this.hostState.maxPasswordLength,
            !this.hostState.permanentPasswordChangeDisabled,
            (value: string): void => {
              this.fixedPassword = value;
            },
          );
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Column({ space: 8 }) {
          this.FieldLabel('确认固定密码');
          this.FieldInput(
            '再次输入固定密码',
            this.fixedPasswordConfirmation,
            this.hostState.maxPasswordLength,
            !this.hostState.permanentPasswordChangeDisabled,
            (value: string): void => {
              this.fixedPasswordConfirmation = value;
            },
          );
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Text('至少 6 个字符；两次输入必须一致。')
          .width('100%')
          .fontSize(11)
          .lineHeight(17)
          .fontColor($r('app.color.text_tertiary'));

        if (this.passwordValidationText().length > 0) {
          Text(this.passwordValidationText())
            .width('100%')
            .fontSize(12)
            .fontColor($r('app.color.error'));
        }

        Button(this.hostState.permanentPasswordSet ? '更改固定密码' : '设置固定密码')
          .width('100%')
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(14)
          .opacity(this.canSubmitPassword() ? 1 : 0.45)
          .enabled(this.canSubmitPassword())
          .onClick(() => this.submitPermanentPassword());

        if (this.hostState.permanentPasswordSet) {
          if (this.confirmRemovePassword) {
            Column({ space: 10 }) {
              Text('移除后，固定密码模式将无法继续用于认证。')
                .width('100%')
                .fontSize(12)
                .fontColor($r('app.color.warning'));
              Row({ space: 10 }) {
                Button('取消')
                  .layoutWeight(1)
                  .height(44)
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .backgroundColor($r('app.color.surface_secondary'))
                  .borderRadius(12)
                  .onClick(() => this.confirmRemovePassword = false);
                Button('确认移除')
                  .layoutWeight(1)
                  .height(44)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_inverse'))
                  .backgroundColor($r('app.color.error'))
                  .borderRadius(12)
                  .onClick((): void => {
                    this.confirmRemovePassword = false;
                    this.clearPasswordDrafts();
                    this.onRemovePermanentPassword();
                  });
              }
              .width('100%');
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start);
          } else {
            Button('移除固定密码')
              .width('100%')
              .height(46)
              .fontSize(14)
              .fontColor($r('app.color.error'))
              .backgroundColor($r('app.color.error_soft'))
              .borderRadius(12)
              .enabled(!this.hostState.permanentPasswordChangeDisabled)
              .opacity(this.hostState.permanentPasswordChangeDisabled ? 0.45 : 1)
              .onClick(() => this.confirmRemovePassword = true);
          }
        }
      }

      if (this.hostState.passwordError.length > 0) {
        Text(this.hostState.passwordError)
          .width('100%')
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.error'));
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor($r('app.color.surface'))
    .shadow({
      radius: 18,
      color: $r('app.color.shadow'),
      offsetX: 0,
      offsetY: 4,
    })
    .alignItems(HorizontalAlign.Start);
  }

  // ── ② 双重认证 ──────────────────────────────

  @Builder
  private TwoFactorCard() {
    Column({ space: 16 }) {
      this.SectionHeading(
        $r('sys.symbol.checkmark_shield'),
        '双重认证',
        '2FA 在密码验证成功后执行，不能替代密码',
        this.twoFactor.enabled ? $r('app.color.success') : $r('app.color.text_secondary'),
        this.twoFactor.enabled ? $r('app.color.success_soft') : $r('app.color.surface_secondary'),
      );

      if (this.twoFactor.setupUri.length > 0 && !this.twoFactor.enabled) {
        Text('使用验证器扫描二维码，或手动输入下方密钥。')
          .width('100%')
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.text_secondary'));

        Column({ space: 10 }) {
          QRCode(this.twoFactor.setupUri)
            .width(170)
            .height(170)
            .color(Color.Black)
            .backgroundColor(Color.White);

          Text(this.setupSecretVisible ? this.setupSecret() : '•••• •••• •••• ••••')
            .fontSize(13)
            .fontFamily('monospace')
            .fontColor($r('app.color.text_primary'))
            .textAlign(TextAlign.Center)
            .copyOption(this.setupSecretVisible ? CopyOptions.LocalDevice : CopyOptions.None);
        }
        .width('100%')
        .padding(14)
        .borderRadius(14)
        .backgroundColor($r('app.color.surface_secondary'))
        .alignItems(HorizontalAlign.Center);

        Button(this.setupSecretVisible ? '隐藏手动密钥' : '显示手动密钥')
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.surface_secondary'))
          .borderRadius(12)
          .onClick(() => this.setupSecretVisible = !this.setupSecretVisible);

        Column({ space: 8 }) {
          this.FieldLabel('验证码');
          TextInput({ text: this.twoFactorCode, placeholder: '输入 6 位验证码' })
            .type(InputType.Number)
            .maxLength(6)
            .width('100%')
            .height(48)
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
            .placeholderColor($r('app.color.text_tertiary'))
            .placeholderFont({ size: 14 })
            .backgroundColor($r('app.color.field_background'))
            .borderRadius(12)
            .border({ width: 1.5, color: $r('app.color.field_border') })
            .enabled(!this.twoFactor.busy)
            .opacity(this.twoFactor.busy ? 0.45 : 1)
            .onChange((value: string): void => {
              this.twoFactorCode = value;
            });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Row({ space: 10 }) {
          Button('取消')
            .layoutWeight(1)
            .height(46)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.surface_secondary'))
            .borderRadius(12)
            .onClick((): void => {
              this.twoFactorCode = '';
              this.setupSecretVisible = false;
              this.onCancelTwoFactor();
            });
          Button('验证并启用')
            .layoutWeight(1)
            .height(46)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_inverse'))
            .backgroundColor($r('app.color.brand_primary'))
            .borderRadius(12)
            .opacity(/^\d{6}$/.test(this.twoFactorCode) && !this.twoFactor.busy ? 1 : 0.45)
            .enabled(/^\d{6}$/.test(this.twoFactorCode) && !this.twoFactor.busy)
            .onClick((): void => {
              const code: string = this.twoFactorCode;
              this.twoFactorCode = '';
              this.onVerifyTwoFactor(code);
            });
        }
        .width('100%');
      } else if (this.twoFactor.enabled) {
        Row({ space: 8 }) {
          Row()
            .width(8)
            .height(8)
            .borderRadius(999)
            .backgroundColor($r('app.color.success'));
          Text('双重认证已启用')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.success'));
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);

        Row({ space: 12 }) {
          Column({ space: 3 }) {
            Text('启用受信任设备')
              .width('100%')
              .fontSize(14)
              .fontColor($r('app.color.text_primary'));
            Text('受信任设备仍需密码，只在有效期内免除第二因素')
              .width('100%')
              .fontSize(11)
              .lineHeight(16)
              .fontColor($r('app.color.text_tertiary'));
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Toggle({ type: ToggleType.Switch, isOn: this.twoFactor.trustedDevicesEnabled })
            .selectedColor($r('app.color.brand_primary'))
            .enabled(!this.twoFactor.trustedDevicesFixed && !this.twoFactor.busy)
            .opacity(this.twoFactor.trustedDevicesFixed ? 0.45 : 1)
            .onChange((enabled: boolean): void => {
              if (!this.twoFactor.trustedDevicesFixed && !this.twoFactor.busy) {
                this.onTrustedDevicesEnabledChange(enabled);
              }
            });
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .borderRadius(14)
        .backgroundColor($r('app.color.surface_secondary'))
        .alignItems(VerticalAlign.Center);

        if (this.confirmDisableTwoFactor) {
          Column({ space: 10 }) {
            Text('关闭 2FA 会同时清空全部受信任设备。')
              .width('100%')
              .fontSize(12)
              .fontColor($r('app.color.warning'));
            Row({ space: 10 }) {
              Button('取消')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .backgroundColor($r('app.color.surface_secondary'))
                .borderRadius(12)
                .onClick(() => this.confirmDisableTwoFactor = false);
              Button('确认关闭')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_inverse'))
                .backgroundColor($r('app.color.error'))
                .borderRadius(12)
                .onClick((): void => {
                  this.confirmDisableTwoFactor = false;
                  this.onDisableTwoFactor();
                });
            }
            .width('100%');
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start);
        } else {
          Button('关闭双重认证')
            .width('100%')
            .height(46)
            .fontSize(14)
            .fontColor($r('app.color.error'))
            .backgroundColor($r('app.color.error_soft'))
            .borderRadius(12)
            .enabled(!this.twoFactor.busy)
            .opacity(this.twoFactor.busy ? 0.45 : 1)
            .onClick(() => this.confirmDisableTwoFactor = true);
        }
      } else {
        Button('设置双重认证')
          .width('100%')
          .height(50)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(14)
          .enabled(!this.twoFactor.busy)
          .opacity(this.twoFactor.busy ? 0.45 : 1)
          .onClick(() => this.onBeginTwoFactor());
      }

      if (this.twoFactor.errorText.length > 0) {
        Text(this.twoFactor.errorText)
          .width('100%')
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.error'));
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor($r('app.color.surface'))
    .shadow({
      radius: 18,
      color: $r('app.color.shadow'),
      offsetX: 0,
      offsetY: 4,
    })
    .alignItems(HorizontalAlign.Start);
  }

  // ── ③ 受信任设备 ────────────────────────────

  @Builder
  private TrustedDevicesCard() {
    Column({ space: 12 }) {
      this.SectionHeading(
        $r('sys.symbol.person_crop_circle_fill'),
        '受信任设备',
        '受信任状态只跳过 2FA，不会绕过密码',
        this.twoFactor.trustedDevicesEnabled ? $r('app.color.success') : $r('app.color.text_secondary'),
        this.twoFactor.trustedDevicesEnabled ? $r('app.color.success_soft') : $r('app.color.surface_secondary'),
      );

      if (this.twoFactor.trustedDevices.length === 0) {
        Text('暂无受信任设备')
          .width('100%')
          .fontSize(13)
          .fontColor($r('app.color.text_tertiary'));
      } else {
        Column() {
          ForEach(this.twoFactor.trustedDevices, (device: ControlledTrustedDevice, index: number) => {
            Row({ space: 12 }) {
              Column({ space: 3 }) {
                Text(this.trustedDeviceTitle(device))
                  .width('100%')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'));
                Text(`${device.platform.length > 0 ? device.platform : '未知平台'} · ${device.id}`)
                  .width('100%')
                  .fontSize(11)
                  .fontColor($r('app.color.text_tertiary'))
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start);

              Text('移除')
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.error'))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(8)
                .backgroundColor($r('app.color.error_soft'))
                .onClick(() => this.onRemoveTrustedDevice(device));
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .alignItems(VerticalAlign.Center)
            .border({
              width: { bottom: index < this.twoFactor.trustedDevices.length - 1 ? 0.5 : 0 },
              color: $r('app.color.divider'),
            });
          }, (device: ControlledTrustedDevice) => `${device.id}-${device.time}`);
        }
        .width('100%')
        .borderRadius(14)
        .backgroundColor($r('app.color.surface_secondary'))
        .clip(true);

        if (this.confirmClearTrustedDevices) {
          Column({ space: 10 }) {
            Text('确认清空全部受信任设备？此操作不能撤销。')
              .width('100%')
              .fontSize(12)
              .fontColor($r('app.color.warning'));
            Row({ space: 10 }) {
              Button('取消')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .backgroundColor($r('app.color.surface_secondary'))
                .borderRadius(12)
                .onClick(() => this.confirmClearTrustedDevices = false);
              Button('确认清空')
                .layoutWeight(1)
                .height(44)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_inverse'))
                .backgroundColor($r('app.color.error'))
                .borderRadius(12)
                .onClick((): void => {
                  this.confirmClearTrustedDevices = false;
                  this.onClearTrustedDevices();
                });
            }
            .width('100%');
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start);
        } else {
          Button('清空受信任设备')
            .width('100%')
            .height(46)
            .fontSize(14)
            .fontColor($r('app.color.error'))
            .backgroundColor($r('app.color.error_soft'))
            .borderRadius(12)
            .onClick(() => this.confirmClearTrustedDevices = true);
        }
      }
    }
    .width('100%')
    .padding(16)
    .borderRadius(18)
    .backgroundColor($r('app.color.surface'))
    .shadow({
      radius: 18,
      color: $r('app.color.shadow'),
      offsetX: 0,
      offsetY: 4,
    })
    .alignItems(HorizontalAlign.Start);
  }

  build() {
    Column({ space: 16 }) {
      this.PasswordCard();
      this.TwoFactorCard();
      if (this.twoFactor.enabled) {
        this.TrustedDevicesCard();
      }

      Button('刷新安全状态')
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.brand_primary'))
        .backgroundColor($r('app.color.brand_primary_soft'))
        .borderRadius(14)
        .onClick(() => this.onRefresh());
    }
    .width(this.contentWidth())
    .alignItems(HorizontalAlign.Start)
    .onAreaChange((_oldArea: Area, newArea: Area): void => {
      const width: number = Number(newArea.width);
      if (width > 0) {
        this.viewportWidth = width;
      }
    });
  }
}
