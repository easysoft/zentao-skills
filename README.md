# 禅道 Skills

> ⚠️ 说明：当前技能仍处于实验阶段。请谨慎使用，并**强烈建议对 AI 发起的 API 调用进行人工审核**。

## 这是什么

本仓库提供基于 [禅道 RESTful API 2.0](https://www.zentao.net/book/api/2309.html) 的 AI Skills。

- **当前包含**：`skills/zentao-api/`（查询并操作禅道数据，如项目、执行、需求、Bug、任务、用例等，取决于接口覆盖范围）

## 快速开始

你可以在 OpenClaw、Cursor、Claude Code 等工具中使用。

下面以 🦀 **OpenClaw** 为例：

1. 在终端执行 `clawdhub install zentao-skills`，或者将如下内容发送给 OpenClaw 会话：

    ```txt
    执行命令 `clawdhub install zentao-skills` 安装禅道 Skills
    ```

2. 按下文“鉴权与 Token 获取”准备好服务器地址与 Token（或账号密码）
3. 在对话中直接提出你的需求，例如：

    ```txt
    查询某项目本周新增 Bug 列表，并按严重程度分组
    ```

    ```txt
    把某个需求状态更新为已关闭，并备注原因
    ```

在其他工具中使用参考：

<details>
  <summary>Cursor</summary>
  <ol>
    <li>将 `skills` 目录合并到 `～/.cursor/skills`</li>
    <li>按下文“鉴权与 Token 获取”准备好服务器地址与 Token（或账号密码）</li>
    <li>在对话中直接提出你的需求，例如：</li>
    <ul>
      <li>“查询某项目本周新增 Bug 列表，并按严重程度分组”</li>
      <li>“把某个需求状态更新为已关闭，并备注原因”</li>
    </ul>
  </ol>
</details>

<details>
  <summary>Claude</summary>
  <ol>
    <li>将 `skills` 目录合并到 `～/.claude/skills`</li>
    <li>按下文“鉴权与 Token 获取”准备好服务器地址与 Token（或账号密码）</li>
    <li>在对话中直接提出你的需求，例如：</li>
    <ul>
      <li>“查询某项目本周新增 Bug 列表，并按严重程度分组”</li>
      <li>“把某个需求状态更新为已关闭，并备注原因”</li>
    </ul>
  </ol>
</details>

## 鉴权与 Token 获取

技能会按以下顺序尝试获取禅道服务器地址与 Token：

- **优先**：从缓存文件 `~/.zentao-token.json` 读取服务器地址与 Token，如果有用户名也会读取用户名
- **其次**：从环境变量读取服务器地址、Token 和用户名
- **再次**：若仍缺少 Token，则从环境变量读取账号密码并调用 `scripts/get-token.sh` 动态获取 Token
- **兜底**：若以上信息都缺失，会提示你提供禅道服务器地址、账号与密码以完成鉴权
- **缓存**：成功获取 Token 后会将服务器地址、Token 和用户名写入 `~/.zentao-token.json`，方便下次直接使用

## 注意事项

- **安全**：请不要将 `~/.zentao-token.json`、环境变量、账号密码粘贴到公开渠道；建议仅在本机受控环境使用。
- **Token**：禅道 Token 通常为长期有效；如 Token 失效或需要切换账号/服务器，可让 AI 清除本地缓存后重新获取。
- **覆盖范围**：当前不保证覆盖禅道全部模块接口；会随禅道 API 2.0 支持情况逐步补齐。

## 常见问题

- **如何清除缓存？**：删除 `~/.zentao-token.json`（或让 AI 帮你执行清理），再重新发起一次需要鉴权的请求即可。
