---
name: zentao-api
description: 调用禅道（ZenTao）RESTful API v2.0 完成用户请求，覆盖项目集、产品、项目、执行、需求（Story/Epic/Requirement）、Bug、任务、测试用例、测试单、产品计划、版本、发布、反馈、工单、应用、用户、文件等 20 个模块的增删改查及状态流转操作。当用户提到禅道、zentao、查询项目进展、获取 Bug 列表、更新需求状态、创建任务等项目管理相关操作时使用本技能。
---

# 禅道 API v2.0

## 配置

优先级从高到低：

| 变量 | 说明 |
|------|------|
| `ZENTAO_URL` | 服务器地址，如 `http://zentao.example.com` |
| `ZENTAO_TOKEN` | 直接指定 token，跳过登录和缓存（最高优先级），仍需提供服务器地址 |
| `ZENTAO_ACCOUNT` | 登录账号，有 token 时可选，但提供可更好回答与当前用户相关的问题 |
| `ZENTAO_PASSWORD` | 登录密码，有 token 时无需提供 |

**首次登录后 `ZENTAO_URL`、`ZENTAO_TOKEN`、`ZENTAO_ACCOUNT` 写入 `~/.zentao-token.json`，后续无需重复设置**。

若必要变量缺失，提示用户并给出 `export` 命令。用户直接提供服务器、账号和密码时直接使用，同时告知尽量设为环境变量。

## 认证流程

所有业务 API 需在 Header 携带 `token`。运行 `scripts/get-token.sh` 自动获取：

```bash
eval "$(bash scripts/get-token.sh)"
# 执行后可直接使用 $ZENTAO_URL、$ZENTAO_TOKEN、$ZENTAO_ACCOUNT
```

脚本依赖：`curl`、`node`

后续所有请求 Header 携带：`token: $ZENTAO_TOKEN`

## 执行 API 调用的步骤

1. 运行 `eval "$(bash scripts/get-token.sh)"` 获取凭证（自动处理缓存；仍缺失时提示用户）
2. 根据用户意图选择正确的 API 端点（参见 [api-reference.md](api-reference.md)）
3. 若为 PUT 操作且用户未提供全部字段，先调用对应 GET 详情接口取回当前数据，再将用户指定的字段覆盖进去
4. 构造请求（方法、URL、Header、Body）并向用户确认写操作内容
5. 执行请求，解析响应
6. 以清晰易读的格式向用户展示结果

## 模块总览

API 基础路径：`$ZENTAO_URL/api.php/v2`

| 模块 | 资源路径 | 支持操作 |
|------|---------|---------|
| 项目集 Program | `/programs` | CRUD + 关联产品/项目列表 |
| 产品 Product | `/products` | CRUD + 关联需求/Bug/用例/计划/发布/反馈/工单/测试单/应用 |
| 项目 Project | `/projects` | CRUD + 关联执行/需求/Bug/用例/版本/发布/测试单 |
| 执行 Execution | `/executions` | CRUD + 关联需求/任务/Bug/用例/版本/测试单 |
| 需求 Story | `/stories` | CRUD + change/close/activate |
| 业务需求 Epic | `/epics` | CRUD + change/close/activate |
| 用户需求 Requirement | `/requirements` | CRUD + change/close/activate |
| Bug | `/bugs` | CRUD + resolve/close/activate |
| 任务 Task | `/tasks` | CRUD + start/finish/close/activate |
| 测试用例 Testcase | `/testcases` | CRUD |
| 产品计划 Productplan | `/productplans` | CUD + 按产品查列表 |
| 版本 Build | `/builds` | CUD + 按项目/执行查列表 |
| 发布 Release | `/releases` | CUD + 按产品查列表 |
| 测试单 Testtask | `/testtasks` | CUD + 按产品/项目/执行查列表 |
| 反馈 Feedback | `/feedbacks` | CRUD + close/activate |
| 工单 Ticket | `/tickets` | CRUD + close/activate |
| 应用 System | `/systems` | CU + 按产品查列表 |
| 用户 User | `/users` | CRUD |
| 文件 File | `/files` | 编辑名称 + 删除 |

> CRUD = 创建(POST) + 读取(GET) + 更新(PUT) + 删除(DELETE)；CUD = 无独立列表接口

## 常用操作示例

### 获取进行中的执行（迭代/Sprint）

```bash
curl -s "$ZENTAO_URL/api.php/v2/projects?browseType=doing" -H "token: $ZENTAO_TOKEN"
curl -s "$ZENTAO_URL/api.php/v2/projects/{projectID}/executions" -H "token: $ZENTAO_TOKEN"
```

### 创建需求

```bash
curl -s -X POST "$ZENTAO_URL/api.php/v2/stories" \
  -H "token: $ZENTAO_TOKEN" -H "Content-Type: application/json" \
  -d '{"product": 1, "title": "需求标题", "assignedTo": "admin", "pri": 3}'
```

### 创建 Bug

```bash
curl -s -X POST "$ZENTAO_URL/api.php/v2/bugs" \
  -H "token: $ZENTAO_TOKEN" -H "Content-Type: application/json" \
  -d '{"product": 1, "title": "Bug标题", "severity": 2, "pri": 2, "type": "codeerror", "openedBuild": "trunk"}'
```

### 解决 Bug

```bash
curl -s -X PUT "$ZENTAO_URL/api.php/v2/bugs/{bugID}/resolve" \
  -H "token: $ZENTAO_TOKEN" -H "Content-Type: application/json" -d '{}'
```

### 创建并完成任务

```bash
curl -s -X POST "$ZENTAO_URL/api.php/v2/tasks" \
  -H "token: $ZENTAO_TOKEN" -H "Content-Type: application/json" \
  -d '{"execution": 1, "name": "任务名", "type": "devel", "assignedTo": "admin", "estimate": 4}'

curl -s -X PUT "$ZENTAO_URL/api.php/v2/tasks/{taskID}/finish" \
  -H "token: $ZENTAO_TOKEN" -H "Content-Type: application/json" \
  -d '{"consumed": 4, "assignedTo": "admin", "finishedDate": "2026-03-25"}'
```

### 获取产品反馈列表

```bash
curl -s "$ZENTAO_URL/api.php/v2/products/{productID}/feedbacks" -H "token: $ZENTAO_TOKEN"
```

## 意图识别规则

| 用户意图关键词 | 对应操作 |
|--------------|---------|
| 进行中的执行/迭代/Sprint | GET /projects?browseType=doing → GET /projects/{id}/executions |
| 获取所有产品/项目/项目集 | GET /products, /projects, /programs |
| 某产品/项目/执行的 Bug | GET /products/{id}/bugs, /projects/{id}/bugs, /executions/{id}/bugs |
| 创建/新增 Bug | POST /bugs |
| 更新/修改 Bug | PUT /bugs/{id} |
| 解决 Bug | PUT /bugs/{id}/resolve |
| 关闭 Bug | PUT /bugs/{id}/close |
| 激活 Bug | PUT /bugs/{id}/activate |
| 创建需求 | POST /stories |
| 关闭/激活/变更需求 | PUT /stories/{id}/close, /activate, /change |
| 业务需求 | /epics（同 stories 结构） |
| 用户需求 | /requirements（同 stories 结构） |
| 创建/完成/启动/关闭任务 | POST /tasks, PUT /tasks/{id}/finish, /start, /close |
| 测试用例 | /testcases（CRUD） |
| 测试单 | /testtasks（CUD + 按产品/项目/执行查列表） |
| 产品计划 | /productplans（CUD + 按产品查列表） |
| 版本/Build | /builds（CUD + 按项目/执行查列表） |
| 发布 | /releases（CUD + 按产品查列表） |
| 反馈 | /feedbacks（CRUD + close/activate） |
| 工单 | /tickets（CRUD + close/activate） |
| 应用/系统 | /systems（CU + 按产品查列表） |
| 获取用户列表 | GET /users |

## 注意事项

- URL 中的 `{id}` 需替换为实际 ID；不知道 ID 时先调列表接口获取
- **PUT 接口需提供所有相关字段**：先 GET 详情获取当前完整数据，再将用户修改的字段覆盖进去一并提交
- 写操作前向用户确认，用户明确要求不确认则直接执行
- 401 响应表示 token 已失效，执行 `rm ~/.zentao-token.json` 清除缓存后重新运行
- `browseType` 常用值：`all`（全部）、`doing`（进行中）、`closed`（已关闭）
- 状态流转操作（resolve/close/activate/start/finish/change）使用 PUT 方法 + 动作路径后缀

## 完整 API 参考

详细的端点列表、请求参数和响应示例见 [api-reference.md](api-reference.md)。

## 备用资源

- 禅道 API 2.0 官方文档：https://www.zentao.net/book/api/2309.html
- 1.0 API 文档（备用）：https://www.zentao.net/book/api/1397.html
