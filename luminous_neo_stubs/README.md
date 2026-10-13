# luminous_neo 本地替身包

私有组件库 `luminous_neo@1.0.2` 的本地降级替身（参见上游
[RustDesk-ArkTS issue #1](https://github.com/FrankHan052176/RustDesk-ArkTS/issues/1)）。

- 导出符号与调用参数与私有库对齐（通过静态分析 app 内 21 处 import 得出）
- 视觉降级为扁平样式，不再有拟态阴影/动效
- 用法：把 `entry/oh-package.json5` 的依赖指向本目录（`file:../../luminous_neo_stubs`）
