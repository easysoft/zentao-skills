---
name: zentao-cli
display_name: 禅道CLI
display_name_en: ZenTao CLI
description: 使用 ZenTao CLI 查询和维护禅道中的产品、项目、需求、任务与 Bug，执行状态流转并汇总进展。当用户要求操作禅道数据、查询禅道中的个人待办，或安装、配置和排查 zentao-cli 问题时使用。
description_zh: 由禅道官方（https://www.zentao.net/）提供的 ZenTao CLI，可查询与维护禅道中的产品、项目、需求、任务和 Bug，支持执行状态流转并汇总进展。适用于操作禅道数据、查询个人待办，以及安装、配置和排查 zentao-cli 问题等场景。
description_en: Official ZenTao CLI from ZenTao (https://www.zentao.net/). Query and maintain products, projects, requirements, tasks, and bugs in ZenTao; perform status transitions and summarize progress. For operating on ZenTao data, querying personal to-dos, and installing, configuring, or troubleshooting zentao-cli issues.
license: MIT
version: 0.4.4
author: 禅道软件
maintainer: Sun Hao <sunhao@chandao.com>
metadata:
  repository: https://github.com/easysoft/zentao-cli.git
  keywords: [zentao, 禅道, cli, project-management]
  version: 0.4.4
---

# 禅道 CLI

用当前安装版本的离线帮助操作禅道；先执行 `zentao --version` 和 `zentao help`。此技能对应显式资源/动作命令树；旧版本需先确认其支持的命令。

## 身份与授权

优先复用已有凭据，不读取或打印密码、Token、凭据文件或环境变量值。用户已明确站点、对象和操作时直接执行；只要求查询或分析时不写入。

```bash
zentao auth status --format=json
zentao auth status --verify --format=json
zentao profile list --format=json
zentao profile use 'admin@https://zentao.example.com'
```

`auth status` 离线返回来源、站点、账号、凭据类型及 verified=false；`--verify` 才在线验证。认证优先级为显式 `--profile` → 完整环境凭据 → 默认 Profile；环境凭据缺一部分会直接报错，不会静默访问其他站点。简写账号有歧义时使用返回的完整 key。

缺少凭据时，Agent 可发起 `zentao auth login --web` 并保持进程运行，让用户在本机浏览器完成验证；不要在对话中收集密码。`--no-input` 明确禁止所有交互，包括浏览器。终端交互使用 `zentao auth login --no-browser`。远程运行时链接属于 CLI 执行端。

登录默认只保存凭据，不改变默认账号；随后使用 `profile use`，或业务命令显式 `--profile`。明确需要登录后选中账号时使用 `auth login --select`；由宿主打开浏览器链接时使用 `auth login --web --no-open`。自动化环境提供 ZENTAO_URL + ZENTAO_ACCOUNT + ZENTAO_TOKEN 或 ZENTAO_PASSWORD，同源 Token 优先。完整环境凭据不读取本地 Profile；只有明确要求保存环境登录时使用 `auth login --use-env`。

`auth status --verify` 使用已保存 Token 时只查询一次当前用户会话；失败不修改本地凭据。`auth logout --revoke` 撤销并核实远端会话后才删除本地记录；失败时保留记录供重试。`--all` 清理当前配置文件的全部账号，空配置也成功，不影响其他配置文件。

配置路径：--config → ZENTAO_CONFIG_FILE → 绝对路径 XDG_CONFIG_HOME/zentao/zentao.json → ~/.config/zentao/zentao.json。遵守用户选定路径，普通查询不会写回配置。

## 发现命令

```bash
zentao help bug create --format=json
zentao bug create --help
zentao bug props --format=json
zentao product list --fields id,name
zentao bug list --product 1 --fields id,title,status
zentao task list --execution-id 1
zentao my tasks
zentao execution project-executions --project-id 5
zentao doc my-docs --space-id 1 --lib-id 2
```

命令格式为 `zentao <resource> <action> [target]`，无动作只显示帮助。动作和参数采用 kebab-case；JSON 请求体保留 SDK 字段名。字段类型、路径参数、必填项、约束、autoFill、分页能力、版本门槛以机器帮助为准。props 只是返回对象字段，不能当成写入清单。

业务字段同时支持空格与等号赋值。简单数组重复选项，复杂数组使用 JSON；所有未知字段、冲突输入和非法值会在认证前报错。多个路径参数分别提供，位置参数只代表帮助中声明的第一个目标。

## 执行与核实

Agent 发起 API 操作时，通过全局 `--assistant` 标注自身，例如 `zentao --assistant 'AI <codex 0.164.0, model: gpt-6.1-sol>' product list`。名称、版本和模型须使用当前已确认的信息；示例不能照抄，未知版本或模型省略，例如 `AI <codex>`。MCP 工具使用同义的顶层 `assistant` 字符串参数。用户要求关闭标记时传空字符串，不自行恢复；不要为添加标记修改用户的持久配置。标记须符合 HTTP 请求头字符限制，不能使用中文或换行。

机器处理显式 `--format=json --no-input`；结果是 `{ok,data,meta}`，失败在 stderr 返回 `{ok:false,error}`。不要把退出码 0、HTTP 200 或 raw 当成已完成写入的唯一证据。创建、更新和流转后按返回 ID 再查详情或所属列表，核对关键字段。

分页默认一页；全量任务用支持的 `--all`，通过 meta.total/returned/hasMore/truncated 判断范围。服务器总数是本地处理前的数量。见 [数据与输出](references/data-output.md)。

写操作按用户授权执行，必要字段不足时只补问影响操作的信息。批量对象用 `--ids`，删除必须显式 `--yes`；部分失败分开报告成功、失败和跳过项，不能整体盲目重试。超时写入先查询是否生效。见 [写入规则](references/writes.md)。

安装技能使用 `zentao skill install codex`；导出使用 `zentao skill export ./exported-skills`。MCP 安装为 `zentao mcp install codex`，服务为 `zentao mcp serve`。

## 错误处理

- E1001：完整环境凭据不足，不回退其他站点；E1006：没有可用默认凭据。
- E1003/E1004：登录失败或 Token 失效；按用户选定的来源重新认证。
- E1005/E1011：配置读取或写入失败；保留错误 details，不覆盖损坏文件，不重复登录。
- E2003/E2004/E2007/E2009：修正必填、类型、JSON 或冲突输入；先查离线动作帮助。
- E2002/E2006/E2008：核对具体 URL、权限及服务器响应，不直接认定记录已删除。
- E2010：当前服务器版本不支持动作；只能选择语义等价且范围明确的能力，不绕过版本检查。
- E1002/E5001/E5002：网络、超时或证书问题；写入结果不明时先回查。

退出码 0=成功，1=执行失败，2=用法错误，130=取消。取消不能回滚已经生效的写入。
