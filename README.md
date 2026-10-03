# 禅道 Skills

![ZenTao Skills](./assets/zentao-skills-cover.png)

本仓库提供了禅道相关技能，帮助你在你常用的智能工具中通过 Skill 更好的使用禅道。

> [!WARNING]
> 当前技能仍处于实验阶段。请谨慎使用，并**强烈建议对 AI 发起的操作（包括 API 调用）进行人工审核**。

## 技能列表

| 技能 | 简介 |
| --- | --- |
| [`zentao-cli`](./skills/zentao-cli/SKILL.md) | 通过 zentao 命令行工具查询和操作禅道（ZenTao）数据，覆盖项目集、产品、项目、执行、需求、Bug、任务、测试用例、测试单、产品计划、版本、发布、反馈、工单、应用、用户、附件等模块的增删改查及状态流转。 |

> [!TIP]
> 禅道会持续优化现有技能，并添加更多好用的相关技能。欢迎大家通过 PR 的方式提交禅道相关技能到本仓库。

## 安装 Skills

### 选择使用的 AI 工具

先准备好 Node.js（包含 npm 和 npx）与 Git，在终端执行与你使用的工具对应的命令：

```sh
# Codex
npx skills add easysoft/zentao-skills --skill zentao-cli -a codex -g

# Claude Code
npx skills add easysoft/zentao-skills --skill zentao-cli -a claude-code -g

# Cursor
npx skills add easysoft/zentao-skills --skill zentao-cli -a cursor -g
```

`-g` 表示安装到当前用户，供多个项目使用。如果只想在某个项目中使用，请先进入该项目目录，再去掉命令中的 `-g`。`--skill zentao-cli` 指定安装的技能，`-a` 指定使用它的 AI 工具。

其他工具可以通过交互提示选择，支持范围见 [skills 官方文档](https://github.com/vercel-labs/skills)：

```sh
npx skills add easysoft/zentao-skills --skill zentao-cli -g
```

也可以把下面的提示词发给支持执行终端命令的 AI 工具：

```txt
请使用 npx skills add easysoft/zentao-skills --skill zentao-cli -g，
为我当前使用的 AI 工具安装禅道技能。
```

本文的 `npx skills` 命令从本仓库安装和更新技能。ZenTao CLI 提供的 `zentao add-skill <agent>` 则安装该 CLI 版本随附的技能，内容可能不同。通过本页命令安装的技能，请使用下方 `npx skills update` 命令更新；更新前请保留自己的定制内容。

### 准备 ZenTao CLI 并登录

技能通过 `zentao` 命令访问禅道。先检查是否已经安装：

```sh
zentao --version
```

如果提示找不到命令，再安装 [ZenTao CLI](https://github.com/easysoft/zentao-cli)：

```sh
npm install -g zentao-cli
```

首次使用时，在自己的交互终端中执行登录，按提示填写站点与账号信息；已有可用登录配置时可以跳过。密码和 Token 请在终端中输入，不要发到 AI 对话中。

```sh
zentao login
```

登录后执行一次只读查询，确认当前账号能够访问禅道：

```sh
zentao my todos
```

查询成功但没有待办也属正常。随后可以在 AI 工具中说：“使用 zentao-cli 技能查询我的待办。”

### 查看、更新和卸载

以下命令对应上面的用户级安装；查看和卸载以 Codex 为例，其他工具替换 `-a` 后的名称即可：

```sh
# 查看已安装的技能
npx skills list -a codex -g

# 更新通过 skills 安装的 zentao-cli 技能
npx skills update zentao-cli -g

# 从 Codex 卸载技能
npx skills remove zentao-cli -a codex -g
```

如果使用项目级安装，请在原项目目录执行命令：查看和卸载去掉 `-g`，更新时将 `-g` 换成 `-p`。更新技能不会更新 ZenTao CLI 程序；升级 CLI 请按其[官方说明](https://github.com/easysoft/zentao-cli)操作。

### 常见问题

| 情况 | 处理方式 |
| --- | --- |
| 找不到 `npx` 或 `git` | 安装 Node.js 或 Git 后，重新打开终端。 |
| 无法从 GitHub 下载 | 确认网络能访问 GitHub，再重试安装命令。 |
| 技能已安装但 AI 工具没有加载 | 用 `skills list` 检查工具和安装范围；项目级技能需要打开对应项目。必要时新建对话或重启工具。 |
| 创建符号链接失败 | 在安装命令末尾加上 `--copy`，改用文件复制。 |
| 提示找不到 `zentao` | 安装 ZenTao CLI，并确认其命令位于终端的 PATH 中。 |
| 查询提示未登录或凭证失效 | 在自己的终端重新执行 `zentao login`；无业务权限时联系站点管理员。 |

安装前只想查看本仓库提供的技能，可以执行：

```sh
npx skills add easysoft/zentao-skills --list
```

## 使用示例

创建产品：

```txt
我想创建一个产品，用来在线收集用户信息，请帮我整理下思路，然后生成第一版需求和计划。如果有问题尽管问我。
```

查询最新的需求：

```txt
上周增加了哪些新的需求？哪些需求比较难？我想针对比较难的需求提前制定方案。
```

查询 BUG，尝试分析原因和方案：

```txt
BUG 329 是什么问题？可能的原因是什么？有解决方案吗？
```

查看迭代情况，分析可能的风险：

```txt
迭代 10 的执行情况如何？有哪些风险？
```

## 许可证

[MIT](./LICENSE)
