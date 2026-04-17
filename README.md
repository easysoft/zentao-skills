# 禅道 Skills

本仓库提供了禅道相关技能，帮助你在你常用的智能工具中通过 Skill 更好的使用禅道。

> [!WARNING]
> 当前技能仍处于实验阶段。请谨慎使用，并**强烈建议对 AI 发起的操作（包括 API 调用）进行人工审核**。

## 技能列表

|      技能    ｜   简介      |
| ------------ | --- |
| `zentao-cli` | 通过 zentao 命令行工具查询和操作禅道（ZenTao）数据，覆盖项目集、产品、项目、执行、需求、Bug、任务、测试用例、测试单、产品计划、版本、发布、反馈、工单、应用、用户、附件等模块的增删改查及状态流转。 |
| `zentao-api` | 调用禅道（ZenTao）RESTful API v2.0 完成用户请求，覆盖项目集、产品、项目、执行、需求（Story/Epic/Requirement）、Bug、任务、测试用例、测试单、产品计划、版本、发布、反馈、工单、应用、用户、文件等 20 个模块的增删改查及状态流转操作。 |

## 安装 Skills

现代智能工具都支持自动安装 Skills，只需要将 https://github.com/easysoft/zentao-skills 链接发送给智能工具，剩下的安装提示操作即可安装，下面是可供参考的提示词：

```txt
帮我安装 https://github.com/easysoft/zentao-skills 上的技能，可以通过 `npx skills add easysoft/zentao-skills` 来进行安装。
```

你也可以手动安装，在有 npm 环境的情况下执行如下命令即可安装：

```sh
npx skills add easysoft/zentao-skills
```

## 许可证

[MIT](./LICENSE)
