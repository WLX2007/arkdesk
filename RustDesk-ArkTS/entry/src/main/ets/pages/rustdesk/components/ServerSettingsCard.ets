import { ServerConfig, ServerEndpointTestState, ServerMode } from '../RustDeskDirectoryTypes';

export interface ServerSettingsCardProps {
  showHeader: boolean;
  config: ServerConfig;
  validating: boolean;
  saving: boolean;
  onConfigChange: (config: ServerConfig) => void;
  onValidate: (config: ServerConfig) => void;
  onSave: (config: ServerConfig) => void;
}

@ComponentV2
export struct ServerSettingsCard {
  @Param showHeader: boolean = true;
  @Param config: ServerConfig = new ServerConfig();
  @Param validating: boolean = false;
  @Param saving: boolean = false;
  @Local viewportWidth: number = 390;
  @Local validationMessage: ResourceStr = '';
  @Local validationField: string = '';
  @Event onConfigChange: (config: ServerConfig) => void = (_config: ServerConfig) => {};
  @Event onValidate: (config: ServerConfig) => void = (_config: ServerConfig) => {};
  @Event onSave: (config: ServerConfig) => void = (_config: ServerConfig) => {};

  private isBusy(): boolean {
    return this.validating || this.saving;
  }

  private copyConfig(): ServerConfig {
    const next = new ServerConfig();
    next.mode = this.config.mode;
    next.idServer = this.config.idServer;
    next.relayServer = this.config.relayServer;
    next.apiServer = this.config.apiServer;
    next.key = this.config.key;
    next.effectiveApiServer = this.config.effectiveApiServer;
    next.usingPublicServer = this.config.usingPublicServer;
    next.remoteReachable = this.config.remoteReachable;
    next.accountAvailable = this.config.accountAvailable;
    next.resultState = this.config.resultState;
    next.message = this.config.message;
    next.idServerTestState = this.config.idServerTestState;
    next.relayServerTestState = this.config.relayServerTestState;
    next.apiServerTestState = this.config.apiServerTestState;
    next.idServerTestMessage = this.config.idServerTestMessage;
    next.relayServerTestMessage = this.config.relayServerTestMessage;
    next.apiServerTestMessage = this.config.apiServerTestMessage;
    return next;
  }

  private updateMode(mode: ServerMode): void {
    const next = this.copyConfig();
    next.mode = mode;
    this.emitDraft(next, 'mode-draft');
  }

  private emitDraft(next: ServerConfig, state: string = 'idle'): void {
    next.remoteReachable = false;
    next.accountAvailable = false;
    next.resultState = state;
    next.message = '';
    next.idServerTestState = 'untested';
    next.relayServerTestState = 'untested';
    next.apiServerTestState = 'untested';
    next.idServerTestMessage = '';
    next.relayServerTestMessage = '';
    next.apiServerTestMessage = '';
    this.validationMessage = '';
    this.validationField = '';
    this.onConfigChange(next);
  }

  private updateIdServer(value: string): void {
    const next = this.copyConfig();
    next.idServer = value;
    this.emitDraft(next);
  }

  private updateRelayServer(value: string): void {
    const next = this.copyConfig();
    next.relayServer = value;
    this.emitDraft(next);
  }

  private updateApiServer(value: string): void {
    const next = this.copyConfig();
    next.apiServer = value;
    this.emitDraft(next);
  }

  private updateKey(value: string): void {
    const next = this.copyConfig();
    next.key = value;
    this.emitDraft(next);
  }

  private normalizedConfig(): ServerConfig {
    const next = this.copyConfig();
    next.idServer = next.idServer.trim();
    next.relayServer = next.relayServer.trim();
    next.apiServer = next.apiServer.trim();
    next.key = next.key.trim();
    return next;
  }

  private validateFormat(config: ServerConfig): ResourceStr {
    if (config.mode === 'official') {
      return '';
    }
    if (config.idServer.includes(' ')) {
      return $r('app.string.settings_server_error_id_space');
    }
    if (config.relayServer.includes(' ')) {
      return $r('app.string.settings_server_error_relay_space');
    }
    if (config.apiServer.length > 0
      && !config.apiServer.startsWith('http://')
      && !config.apiServer.startsWith('https://')) {
      return $r('app.string.settings_server_error_api_scheme');
    }
    return '';
  }

  private findValidationField(config: ServerConfig): string {
    if (config.mode === 'official') {
      return '';
    }
    if (config.idServer.includes(' ')) {
      return 'id-server';
    }
    if (config.relayServer.includes(' ')) {
      return 'relay-server';
    }
    if (config.apiServer.length > 0
      && !config.apiServer.startsWith('http://')
      && !config.apiServer.startsWith('https://')) {
      return 'api-server';
    }
    return '';
  }

  private requestValidation(): void {
    const next = this.normalizedConfig();
    const message = this.validateFormat(next);
    if (message !== '') {
      this.validationMessage = message;
      this.validationField = this.findValidationField(next);
      return;
    }
    this.validationMessage = '';
    this.validationField = '';
    this.onConfigChange(next);
    this.onValidate(next);
  }

  private requestSave(): void {
    const next = this.normalizedConfig();
    const message = this.validateFormat(next);
    if (message !== '') {
      this.validationMessage = message;
      this.validationField = this.findValidationField(next);
      return;
    }
    this.validationMessage = '';
    this.validationField = '';
    this.onSave(next);
  }

  private remoteStatusText(): ResourceStr {
    if (this.config.resultState === 'mode-draft') {
      return $r('app.string.settings_server_pending_apply');
    }
    if (this.config.mode === 'official') {
      return $r('app.string.settings_server_remote_auto');
    }
    if (this.config.idServer.trim().length === 0 && this.config.relayServer.trim().length === 0) {
      return $r('app.string.settings_server_remote_unconfigured');
    }
    if (this.config.remoteReachable) {
      return $r('app.string.settings_server_remote_ready');
    }
    return $r('app.string.settings_server_remote_pending');
  }

  private resultIsSuccess(): boolean {
    return this.config.resultState === 'test-success' || this.config.resultState === 'save-success' ||
      this.config.resultState === 'empty-success' || this.config.resultState === 'success';
  }

  private resultTitle(): ResourceStr {
    if (this.config.resultState === 'save-success') {
      return $r('app.string.settings_server_save_success');
    }
    if (this.config.resultState === 'empty-success') {
      return $r('app.string.settings_server_empty_success');
    }
    return this.resultIsSuccess()
      ? $r('app.string.settings_server_test_success')
      : $r('app.string.settings_server_test_failed');
  }

  private hasResult(): boolean {
    return this.config.resultState === 'test-success' || this.config.resultState === 'save-success' ||
      this.config.resultState === 'empty-success' || this.config.resultState === 'success' ||
      this.config.resultState === 'error';
  }

  private accountStatusText(): ResourceStr {
    if (this.config.resultState === 'mode-draft') {
      return $r('app.string.settings_server_pending_apply');
    }
    if (this.config.accountAvailable) {
      return $r('app.string.settings_server_account_ready');
    }
    if (this.config.effectiveApiServer.trim().length === 0) {
      return $r('app.string.settings_server_account_unconfigured');
    }
    return $r('app.string.settings_server_account_pending');
  }

  private effectiveApiText(): ResourceStr {
    if (this.config.resultState === 'mode-draft') {
      return $r('app.string.settings_server_pending_apply');
    }
    const apiServer = this.config.effectiveApiServer.trim();
    if (apiServer.length > 0) {
      return apiServer;
    }
    return $r('app.string.settings_server_effective_api_auto');
  }

  private endpointStatusText(value: string, state: ServerEndpointTestState): ResourceStr {
    if (value.trim().length === 0) {
      return $r('app.string.settings_server_status_unconfigured');
    }
    if (state === 'success') {
      return $r('app.string.settings_server_status_success');
    }
    if (state === 'error') {
      return $r('app.string.settings_server_status_failed');
    }
    return $r('app.string.settings_server_status_untested');
  }

  private endpointStatusColor(value: string, state: ServerEndpointTestState): ResourceColor {
    if (value.trim().length === 0 || state === 'untested') {
      return $r('app.color.text_tertiary');
    }
    return state === 'success' ? $r('app.color.success') : $r('app.color.error');
  }

  private endpointActionText(state: ServerEndpointTestState): ResourceStr {
    if (state === 'success') {
      return $r('app.string.settings_server_action_retest');
    }
    if (state === 'error') {
      return $r('app.string.settings_server_action_retry');
    }
    return $r('app.string.settings_server_action_test');
  }

  private endpointErrorPrefix(controlId: string): string {
    if (controlId === 'id-server') {
      return 'ID 服务器:';
    }
    if (controlId === 'relay-server') {
      return '中继服务器:';
    }
    return 'API 服务器:';
  }

  private hasEndpointErrorDetails(): boolean {
    return this.config.message.includes('ID 服务器:') || this.config.message.includes('中继服务器:') ||
      this.config.message.includes('API 服务器:');
  }

  private endpointDisplayState(controlId: string, value: string,
    state: ServerEndpointTestState): ServerEndpointTestState {
    if (this.validationField === controlId) {
      return 'error';
    }
    if (state !== 'untested' || value.trim().length === 0) {
      return state;
    }
    if (this.config.resultState === 'test-success' || this.config.resultState === 'success') {
      return 'success';
    }
    if (this.config.resultState === 'error') {
      if (!this.hasEndpointErrorDetails()) {
        return 'error';
      }
      return this.config.message.includes(this.endpointErrorPrefix(controlId)) ? 'error' : 'success';
    }
    return 'untested';
  }

  private endpointDisplayMessage(controlId: string, message: string): string {
    if (message.length > 0) {
      return message;
    }
    const prefix = this.endpointErrorPrefix(controlId);
    const entries = this.config.message.split(' · ');
    for (let index = 0; index < entries.length; index += 1) {
      const entry = entries[index].trim();
      if (entry.startsWith(prefix)) {
        return entry.substring(prefix.length).trim();
      }
    }
    return '';
  }

  // ── 结果横幅 ────────────────────────────────

  @Builder
  private ResultBanner() {
    Row({ space: 10 }) {
      Row()
        .width(8)
        .height(8)
        .borderRadius(999)
        .backgroundColor(this.resultIsSuccess() ? $r('app.color.success') : $r('app.color.error'));

      Column({ space: 2 }) {
        Text(this.resultTitle())
          .width('100%')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.resultIsSuccess() ? $r('app.color.success') : $r('app.color.error'));
        Text(this.config.message)
          .width('100%')
          .fontSize(12)
          .lineHeight(17)
          .fontColor($r('app.color.text_secondary'));
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(14)
    .borderRadius(14)
    .backgroundColor(this.resultIsSuccess() ? $r('app.color.success_soft') : $r('app.color.error_soft'))
    .alignItems(VerticalAlign.Top);
  }

  // ── 连接方式卡 ──────────────────────────────

  @Builder
  private ModeOption(mode: ServerMode, label: ResourceStr) {
    Text(label)
      .layoutWeight(1)
      .height(40)
      .fontSize(14)
      .fontWeight(this.config.mode === mode ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.config.mode === mode
        ? $r('app.color.text_inverse')
        : $r('app.color.text_secondary'))
      .textAlign(TextAlign.Center)
      .borderRadius(11)
      .backgroundColor(this.config.mode === mode ? $r('app.color.brand_primary') : Color.Transparent)
      .onClick(() => this.updateMode(mode));
  }

  @Builder
  private ModeCard() {
    Column({ space: 12 }) {
      Text('连接方式')
        .width('100%')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'));

      Row({ space: 4 }) {
        this.ModeOption('official', $r('app.string.settings_server_official'))
        this.ModeOption('custom', $r('app.string.settings_server_custom'))
      }
      .width('100%')
      .padding(3)
      .borderRadius(14)
      .backgroundColor($r('app.color.surface_secondary'));

      Text(this.config.mode === 'official'
        ? $r('app.string.settings_server_public_hint')
        : $r('app.string.settings_server_custom_hint'))
        .width('100%')
        .fontSize(12)
        .lineHeight(18)
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

  // ── 官方模式：能力总览 ──────────────────────

  @Builder
  private CapabilityRow(label: ResourceStr, value: ResourceStr, available: boolean, isLast: boolean) {
    Row({ space: 12 }) {
      Row()
        .width(8)
        .height(8)
        .borderRadius(999)
        .backgroundColor(available ? $r('app.color.success') : $r('app.color.outline'));

      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'));

      Text(value)
        .layoutWeight(1)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(available ? $r('app.color.success') : $r('app.color.text_tertiary'))
        .textAlign(TextAlign.End)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width('100%')
    .constraintSize({ minHeight: 48 })
    .padding({ left: 14, right: 14 })
    .alignItems(VerticalAlign.Center)
    .border({
      width: { bottom: isLast ? 0 : 0.5 },
      color: $r('app.color.divider'),
    });
  }

  @Builder
  private StatusSummaryCard() {
    Column() {
      Row({ space: 12 }) {
        Text($r('app.string.settings_server_effective_api'))
          .fontSize(14)
          .fontColor($r('app.color.text_primary'));
        Text(this.effectiveApiText())
          .layoutWeight(1)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.End)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width('100%')
      .constraintSize({ minHeight: 48 })
      .padding({ left: 14, right: 14 })
      .alignItems(VerticalAlign.Center)
      .border({ width: { bottom: 0.5 }, color: $r('app.color.divider') });

      this.CapabilityRow(
        $r('app.string.settings_server_remote_capability'),
        this.remoteStatusText(),
        this.config.remoteReachable,
        false,
      )
      this.CapabilityRow(
        $r('app.string.settings_server_account_capability'),
        this.accountStatusText(),
        this.config.accountAvailable,
        true,
      )
    }
    .width('100%')
    .borderRadius(18)
    .backgroundColor($r('app.color.surface'))
    .shadow({
      radius: 18,
      color: $r('app.color.shadow'),
      offsetX: 0,
      offsetY: 4,
    })
    .clip(true);
  }

  // ── 自定义模式：字段 ────────────────────────

  @Builder
  private EndpointTestButton(controlId: string, value: string, state: ServerEndpointTestState) {
    if (this.validating && value.trim().length > 0) {
      Row({ space: 6 }) {
        LoadingProgress()
          .width(14)
          .height(14)
          .color($r('app.color.brand_primary'));
        Text($r('app.string.settings_server_status_testing'))
          .fontSize(12)
          .fontColor($r('app.color.brand_primary'));
      }
      .alignItems(VerticalAlign.Center);
    } else if (value.trim().length > 0) {
      Row({ space: 8 }) {
        Row()
          .width(8)
          .height(8)
          .borderRadius(999)
          .backgroundColor(this.endpointStatusColor(value, this.endpointDisplayState(controlId, value, state)));
        Text(this.endpointStatusText(value, this.endpointDisplayState(controlId, value, state)))
          .fontSize(12)
          .fontColor(this.endpointStatusColor(value, this.endpointDisplayState(controlId, value, state)));

        Text(this.endpointActionText(this.endpointDisplayState(controlId, value, state)))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.brand_primary'))
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(8)
          .backgroundColor($r('app.color.brand_primary_soft'))
          .opacity(this.isBusy() ? 0.45 : 1)
          .onClick((): void => {
            if (!this.isBusy()) {
              this.requestValidation();
            }
          });
      }
      .alignItems(VerticalAlign.Center);
    } else {
      Row({ space: 8 }) {
        Row()
          .width(8)
          .height(8)
          .borderRadius(999)
          .backgroundColor($r('app.color.text_tertiary'));
        Text($r('app.string.settings_server_status_unconfigured'))
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'));
      }
      .alignItems(VerticalAlign.Center);
    }
  }

  @Builder
  private ServerField(controlId: string, label: ResourceStr, placeholder: ResourceStr, value: string,
    state: ServerEndpointTestState, testMessage: string, testable: boolean,
    onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Row() {
        Text(label)
          .layoutWeight(1)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.validationField === controlId
            ? $r('app.color.error')
            : $r('app.color.text_secondary'));

        if (testable) {
          this.EndpointTestButton(controlId, value, state)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center);

      TextInput({ text: value, placeholder: placeholder })
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_tertiary'))
        .placeholderFont({ size: 14 })
        .backgroundColor($r('app.color.field_background'))
        .borderRadius(12)
        .border({
          width: 1.5,
          color: this.validationField === controlId
            ? $r('app.color.error')
            : $r('app.color.field_border'),
        })
        .onChange(onChange);

      if (this.validationField === controlId && this.validationMessage !== '') {
        Text(this.validationMessage)
          .width('100%')
          .fontSize(11)
          .fontColor($r('app.color.error'));
      } else if (this.endpointDisplayState(controlId, value, state) === 'error' &&
        this.endpointDisplayMessage(controlId, testMessage).length > 0) {
        Text(this.endpointDisplayMessage(controlId, testMessage))
          .width('100%')
          .fontSize(11)
          .fontColor($r('app.color.error'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private CustomFieldsCard() {
    Column({ space: 18 }) {
      this.ServerField(
        'id-server',
        $r('app.string.settings_id_server'),
        $r('app.string.settings_id_server_placeholder'),
        this.config.idServer,
        this.config.idServerTestState,
        this.config.idServerTestMessage,
        true,
        (value: string) => this.updateIdServer(value),
      )
      this.ServerField(
        'relay-server',
        $r('app.string.settings_relay_server'),
        $r('app.string.settings_relay_server_placeholder'),
        this.config.relayServer,
        this.config.relayServerTestState,
        this.config.relayServerTestMessage,
        true,
        (value: string) => this.updateRelayServer(value),
      )
      this.ServerField(
        'api-server',
        $r('app.string.settings_api_server'),
        $r('app.string.settings_api_server_placeholder'),
        this.config.apiServer,
        this.config.apiServerTestState,
        this.config.apiServerTestMessage,
        true,
        (value: string) => this.updateApiServer(value),
      )
      this.ServerField(
        'server-key',
        $r('app.string.settings_server_key'),
        $r('app.string.settings_server_key_placeholder'),
        this.config.key,
        'untested',
        '',
        false,
        (value: string) => this.updateKey(value),
      )
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
  private ActionArea() {
    Column({ space: 12 }) {
      Button(this.saving
        ? $r('app.string.settings_server_saving')
        : $r('app.string.settings_server_save'))
        .width('100%')
        .height(52)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_inverse'))
        .backgroundColor($r('app.color.brand_primary'))
        .borderRadius(14)
        .opacity(this.isBusy() ? 0.45 : 1)
        .enabled(!this.isBusy())
        .onClick(() => this.requestSave());

      if (this.config.mode === 'custom') {
        Text($r('app.string.settings_server_validation_note'))
          .width('100%')
          .fontSize(11)
          .lineHeight(17)
          .fontColor($r('app.color.text_tertiary'));
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  build() {
    Column({ space: 16 }) {
      this.ModeCard();

      if (this.config.mode === 'official') {
        this.StatusSummaryCard();
      } else {
        this.CustomFieldsCard();
      }

      if (this.hasResult()) {
        this.ResultBanner();
      }

      this.ActionArea();
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
