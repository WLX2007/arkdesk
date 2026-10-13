import { AccountLoginProvider, AccountState } from '../RustDeskDirectoryTypes';

export interface AccountSettingsCardProps {
  showHeader: boolean;
  accountState: AccountState;
  loginProviders: AccountLoginProvider[];
  onLogin: (username: string, password: string) => void;
  onVerify: (code: string) => void;
  onCancelChallenge: () => void;
  onOidcLogin: (provider: string) => void;
  onOidcCancel: () => void;
  onSync: () => void;
  onLogout: () => void;
}

@ComponentV2
export struct AccountSettingsCard {
  @Param showHeader: boolean = true;
  @Param accountState: AccountState = new AccountState();
  @Param loginProviders: AccountLoginProvider[] = [];
  @Local username: string = '';
  @Local password: string = '';
  @Local verificationCode: string = '';
  @Local inputError: string = '';
  @Local viewportWidth: number = 390;
  @Event onLogin: (username: string, password: string) => void = (_username: string, _password: string) => {};
  @Event onVerify: (code: string) => void = (_code: string) => {};
  @Event onCancelChallenge: () => void = () => {};
  @Event onOidcLogin: (provider: string) => void = (_provider: string) => {};
  @Event onOidcCancel: () => void = () => {};
  @Event onSync: () => void = () => {};
  @Event onLogout: () => void = () => {};

  aboutToAppear(): void {
    if (this.username.length === 0 && this.accountState.name.trim().length > 0) {
      this.username = this.accountState.name.trim();
    }
  }

  private isBusy(): boolean {
    return this.accountState.busy || this.accountState.syncing;
  }

  private hasChallenge(): boolean {
    return this.accountState.challengeId.trim().length > 0
      || this.accountState.challengeType.trim().length > 0;
  }

  private isTotpChallenge(): boolean {
    return this.accountState.challengeType.trim().toLowerCase() === 'totp';
  }

  private isOidcActive(): boolean {
    return this.accountState.oidcProvider.trim().length > 0;
  }

  private canLogin(): boolean {
    return !this.isBusy()
      && this.accountState.apiServer.trim().length > 0
      && this.username.trim().length > 0
      && this.password.length > 0;
  }

  private canVerify(): boolean {
    return !this.isBusy()
      && this.accountState.challengeId.trim().length > 0
      && this.verificationCode.trim().length > 0;
  }

  private requestLogin(): void {
    const normalizedUsername = this.username.trim();
    const submittedPassword = this.password;
    if (this.isBusy()) {
      return;
    }
    if (normalizedUsername.length === 0 || submittedPassword.trim().length === 0) {
      this.inputError = '请输入用户名和密码';
      return;
    }
    this.inputError = '';
    this.username = normalizedUsername;
    this.password = '';
    this.onLogin(normalizedUsername, submittedPassword);
  }

  private requestVerification(): void {
    const code = this.verificationCode.trim();
    if (code.length === 0 || this.isBusy()) {
      return;
    }
    this.verificationCode = '';
    this.onVerify(code);
  }

  private cancelChallenge(): void {
    if (this.isBusy()) {
      return;
    }
    this.verificationCode = '';
    this.onCancelChallenge();
  }

  private requestOidc(provider: string): void {
    const providerName = provider.trim();
    if (providerName.length === 0 || this.isBusy()) {
      return;
    }
    this.onOidcLogin(providerName);
  }

  private providerLabel(provider: AccountLoginProvider): string {
    const label = provider.label.trim();
    return label.length > 0 ? label : provider.name.trim();
  }

  private providerCompactLabel(provider: AccountLoginProvider): ResourceStr {
    const normalizedProvider = provider.name.trim().toLowerCase();
    if (normalizedProvider === 'github') {
      return $r('app.string.settings_account_oidc_github_short');
    }
    if (normalizedProvider === 'google') {
      return $r('app.string.settings_account_oidc_google_short');
    }
    if (normalizedProvider === 'microsoft' || normalizedProvider === 'azure') {
      return $r('app.string.settings_account_oidc_microsoft_short');
    }
    return this.providerLabel(provider);
  }

  private activeOidcProviderLabel(): string {
    const activeProvider = this.accountState.oidcProvider.trim().toLowerCase();
    for (let index = 0; index < this.loginProviders.length; index += 1) {
      if (this.loginProviders[index].name.trim().toLowerCase() === activeProvider) {
        return this.providerLabel(this.loginProviders[index]);
      }
    }
    return activeProvider;
  }

  private accountTitle(): ResourceStr {
    if (this.accountState.displayName.trim().length > 0) {
      return this.accountState.displayName.trim();
    }
    if (this.accountState.name.trim().length > 0) {
      return this.accountState.name.trim();
    }
    if (this.accountState.email.trim().length > 0) {
      return this.accountState.email.trim();
    }
    return $r('app.string.settings_account_default_user');
  }

  private optionalValue(value: string): ResourceStr {
    const normalized = value.trim();
    if (normalized.length > 0) {
      return normalized;
    }
    return $r('app.string.settings_account_not_provided');
  }

  private apiServerText(): ResourceStr {
    const apiServer = this.accountState.apiServer.trim();
    if (apiServer.length > 0) {
      return apiServer;
    }
    return $r('app.string.settings_account_api_unavailable');
  }

  private statusText(): ResourceStr {
    if (this.accountState.syncing) {
      return $r('app.string.settings_account_syncing');
    }
    if (this.accountState.busy) {
      if (this.isOidcActive()) {
        return $r('app.string.settings_account_oidc_waiting_short');
      }
      return this.hasChallenge()
        ? $r('app.string.settings_account_verifying')
        : $r('app.string.settings_account_logging_in');
    }
    if (this.hasChallenge()) {
      return $r('app.string.settings_account_awaiting_verification');
    }
    if (this.accountState.loggedIn) {
      return $r('app.string.settings_account_signed_in');
    }
    return $r('app.string.settings_account_signed_out');
  }

  private statusColor(): ResourceColor {
    if (this.accountState.busy || this.accountState.syncing) {
      return $r('app.color.brand_primary');
    }
    if (this.hasChallenge()) {
      return $r('app.color.warning');
    }
    if (this.accountState.loggedIn) {
      return $r('app.color.success');
    }
    return $r('app.color.text_tertiary');
  }

  private statusBackground(): ResourceColor {
    if (this.accountState.busy || this.accountState.syncing) {
      return $r('app.color.brand_primary_soft');
    }
    if (this.hasChallenge()) {
      return $r('app.color.warning_soft');
    }
    if (this.accountState.loggedIn) {
      return $r('app.color.success_soft');
    }
    return $r('app.color.surface_secondary');
  }

  private messageColor(): ResourceColor {
    if (this.accountState.busy || this.accountState.syncing) {
      return $r('app.color.brand_primary');
    }
    if (this.accountState.loggedIn && !this.hasChallenge()) {
      return $r('app.color.success');
    }
    return $r('app.color.warning');
  }

  private messageBackground(): ResourceColor {
    if (this.accountState.busy || this.accountState.syncing) {
      return $r('app.color.brand_primary_soft');
    }
    if (this.accountState.loggedIn && !this.hasChallenge()) {
      return $r('app.color.success_soft');
    }
    return $r('app.color.warning_soft');
  }

  // ── 通用构件 ────────────────────────────────

  @Builder
  private FieldLabel(text: ResourceStr) {
    Text(text)
      .width('100%')
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_secondary'));
  }

  @Builder
  private FieldInput(placeholder: ResourceStr, value: string, inputType: InputType,
    maxLength: number, enabled: boolean, onChange: (value: string) => void) {
    TextInput({ text: value, placeholder: placeholder })
      .type(inputType)
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
  private CardTitle(title: string, subtitle: string) {
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
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  // ── 登录态头部 ──────────────────────────────

  @Builder
  private StatusCard() {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph(this.hasChallenge()
          ? $r('sys.symbol.checkmark_shield')
          : (this.accountState.loggedIn
            ? $r('sys.symbol.person_crop_circle_fill')
            : $r('sys.symbol.person')))
          .fontSize(20)
          .fontColor([this.statusColor()]);
      }
      .width(42)
      .height(42)
      .borderRadius(12)
      .backgroundColor(this.statusBackground());

      Column({ space: 3 }) {
        Text(this.statusText())
          .width('100%')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'));
        Text(this.apiServerText())
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
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
    .alignItems(VerticalAlign.Center);
  }

  // ── 未登录：登录表单 ────────────────────────

  @Builder
  private LoginForm() {
    Column({ space: 16 }) {
      this.CardTitle('登录账户', '登录后可在设备之间同步通讯簿和账户信息');

      Column({ space: 14 }) {
        Column({ space: 8 }) {
          this.FieldLabel($r('app.string.settings_account_username'));
          this.FieldInput(
            $r('app.string.settings_account_username_placeholder'),
            this.username,
            InputType.Normal,
            256,
            !this.isBusy(),
            (value: string) => this.username = value,
          );
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);

        Column({ space: 8 }) {
          this.FieldLabel($r('app.string.settings_account_password'));
          this.FieldInput(
            $r('app.string.settings_account_password_placeholder'),
            this.password,
            InputType.Password,
            256,
            !this.isBusy(),
            (value: string) => this.password = value,
          );
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%');

      if (this.inputError.length > 0) {
        Text(this.inputError)
          .width('100%')
          .fontSize(12)
          .fontColor($r('app.color.error'));
      }

      Button(this.accountState.busy
        ? $r('app.string.settings_account_logging_in')
        : $r('app.string.settings_account_login'))
        .width('100%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_inverse'))
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(14)
        .opacity(this.canLogin() ? 1 : 0.45)
        .enabled(this.canLogin())
        .onClick(() => this.requestLogin());

      Text($r('app.string.settings_account_password_note'))
        .width('100%')
        .fontSize(11)
        .lineHeight(17)
        .fontColor($r('app.color.text_tertiary'));
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

  @Builder
  private OidcCard() {
    if (this.loginProviders.length > 0) {
      Column({ space: 12 }) {
        this.CardTitle('浏览器授权',
          this.isOidcActive()
            ? '请在系统浏览器中完成授权，返回应用后会自动继续'
            : '选择账户提供商，在系统浏览器中完成安全授权');

        if (this.isOidcActive()) {
          Text(this.activeOidcProviderLabel())
            .width('100%')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'));

          Button($r('app.string.settings_account_oidc_cancel'))
            .width('100%')
            .height(46)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.surface_secondary'))
            .borderRadius(12)
            .onClick(() => this.onOidcCancel());
        } else {
          Column({ space: 8 }) {
            ForEach(this.loginProviders, (provider: AccountLoginProvider) => {
              Row({ space: 10 }) {
                SymbolGlyph($r('sys.symbol.link'))
                  .fontSize(16)
                  .fontColor([$r('app.color.text_secondary')]);
                Text(this.providerCompactLabel(provider))
                  .layoutWeight(1)
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'));
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(13)
                  .fontColor([$r('app.color.text_tertiary')]);
              }
              .width('100%')
              .height(46)
              .padding({ left: 14, right: 14 })
              .borderRadius(12)
              .backgroundColor($r('app.color.surface_secondary'))
              .alignItems(VerticalAlign.Center)
              .opacity(this.isBusy() ? 0.45 : 1)
              .onClick(() => this.requestOidc(provider.name));
            }, (provider: AccountLoginProvider) => provider.name);
          }
          .width('100%');
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
  }

  // ── 验证挑战 ────────────────────────────────

  @Builder
  private ChallengeCard() {
    Column({ space: 16 }) {
      this.CardTitle(
        this.isTotpChallenge() ? '双重身份验证' : '验证登录邮箱',
        this.isTotpChallenge()
          ? '输入身份验证器当前生成的一次性验证码'
          : '输入服务器发送到邮箱的验证码',
      );

      if (!this.isTotpChallenge() && this.accountState.emailHint.trim().length > 0) {
        Text(this.accountState.emailHint.trim())
          .width('100%')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }

      Column({ space: 8 }) {
        this.FieldLabel($r('app.string.settings_account_verification_code'));
        this.FieldInput(
          $r('app.string.settings_account_code_placeholder'),
          this.verificationCode,
          InputType.Number,
          8,
          !this.isBusy(),
          (value: string) => this.verificationCode = value,
        );
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);

      Row({ space: 10 }) {
        Button($r('app.string.settings_account_cancel'))
          .layoutWeight(1)
          .height(48)
          .fontSize(15)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor($r('app.color.surface_secondary'))
          .borderRadius(14)
          .enabled(!this.isBusy())
          .opacity(this.isBusy() ? 0.45 : 1)
          .onClick(() => this.cancelChallenge());

        Button(this.accountState.busy
          ? $r('app.string.settings_account_verifying')
          : $r('app.string.settings_account_verify'))
          .layoutWeight(1)
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(14)
          .opacity(this.canVerify() ? 1 : 0.45)
          .enabled(this.canVerify())
          .onClick(() => this.requestVerification());
      }
      .width('100%');
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

  // ── 已登录 ──────────────────────────────────

  @Builder
  private IdentityCard() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Text('R')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_inverse'));
        }
        .width(48)
        .height(48)
        .borderRadius(14)
        .backgroundColor($r('app.color.brand_primary'));

        Column({ space: 3 }) {
          Text(this.accountTitle())
            .width('100%')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text($r('app.string.settings_account_signed_in_hint'))
            .width('100%')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'));
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      Divider()
        .strokeWidth(0.5)
        .color($r('app.color.divider'));

      Column() {
        this.AccountInfoRow(
          $r('app.string.settings_account_username'),
          this.optionalValue(this.accountState.name),
          false,
        )
        this.AccountInfoRow(
          $r('app.string.settings_account_email'),
          this.optionalValue(this.accountState.email),
          false,
        )
        this.AccountInfoRow(
          $r('app.string.settings_server_effective_api'),
          this.apiServerText(),
          true,
        )
      }
      .width('100%');

      Row({ space: 10 }) {
        Button($r('app.string.settings_account_logout'))
          .layoutWeight(1)
          .height(46)
          .fontSize(14)
          .fontColor($r('app.color.error'))
          .backgroundColor($r('app.color.error_soft'))
          .borderRadius(12)
          .enabled(!this.isBusy())
          .opacity(this.isBusy() ? 0.45 : 1)
          .onClick(() => this.onLogout());

        Button(this.accountState.syncing
          ? $r('app.string.settings_account_syncing')
          : $r('app.string.settings_account_sync'))
          .layoutWeight(1)
          .height(46)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.brand_primary'))
          .borderRadius(12)
          .enabled(!this.isBusy())
          .opacity(this.isBusy() ? 0.45 : 1)
          .onClick(() => this.onSync());
      }
      .width('100%');
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

  @Builder
  private AccountInfoRow(label: ResourceStr, value: ResourceStr, isLast: boolean) {
    Row({ space: 12 }) {
      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'));

      Text(value)
        .layoutWeight(1)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .textAlign(TextAlign.End)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width('100%')
    .constraintSize({ minHeight: 42 })
    .alignItems(VerticalAlign.Center)
    .border({
      width: { bottom: isLast ? 0 : 0.5 },
      color: $r('app.color.divider'),
    });
  }

  @Builder
  private MessageBanner() {
    if (this.accountState.message.trim().length > 0) {
      Row({ space: 10 }) {
        Row()
          .width(8)
          .height(8)
          .borderRadius(999)
          .backgroundColor(this.messageColor());

        Text(this.accountState.message.trim())
          .layoutWeight(1)
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.text_secondary'));
      }
      .width('100%')
      .padding(14)
      .borderRadius(14)
      .backgroundColor(this.messageBackground())
      .alignItems(VerticalAlign.Top);
    }
  }

  build() {
    Column({ space: 16 }) {
      this.StatusCard();

      if (this.hasChallenge()) {
        this.ChallengeCard();
      } else if (this.accountState.loggedIn) {
        this.IdentityCard();
      } else {
        this.LoginForm();
        this.OidcCard();
      }

      this.MessageBanner();
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      const width = Number(newArea.width);
      if (width > 0) {
        this.viewportWidth = width;
      }
    });
  }
}
