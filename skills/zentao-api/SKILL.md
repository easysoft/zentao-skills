---
name: zentao-api
description: 调用禅道（ZenTao）RESTful API v2.0 完成用户请求，包括查询项目、执行、需求、Bug、任务、测试用例等数据，以及创建、编辑、删除等写操作。当用户提到禅道、zentao、查询项目进展、获取Bug列表、更新需求状态、创建任务等项目管理相关操作时使用本技能。
---

# 禅道 API v2.0

## 配置

优先从环境变量读取：

| 变量 | 说明 |
|------|------|
| `ZENTAO_URL` | 服务器地址，必须提供，如 `http://zentao.example.com` |
| `ZENTAO_TOKEN` | 直接指定 token，设置后跳过登录和缓存（最高优先级） |
| `ZENTAO_ACCOUNT` | 登录账号 |
| `ZENTAO_PASSWORD` | 登录密码 |

若 `ZENTAO_TOKEN` 已设置，其余三个变量可不填。否则需提供后三个变量，若缺失则提示用户并给出 `export` 命令。如果用户直接提供了服务器、账号和密码，则直接使用，但同时告知用户尽量设置为环境变量，避免每次都要输入，此时为了方便用户，可以提供一键设置环境变量的命令。

## 认证流程

所有业务 API 均需在 Header 携带 `token`。通过脚本自动处理缓存，避免每次重复登录：

```bash
TOKEN=$(bash .cursor/skills/zentao-api/scripts/get-token.sh)
```

脚本依赖：`curl`、`node`（Node.js）

脚本行为：

- 若 `~/.zentao-token.json` 中存有匹配当前 `ZENTAO_URL` 的 token，直接使用（token 永久有效）
- 切换服务器（`ZENTAO_URL` 变更）或缓存文件不存在时，调用登录 API 获取新 token 并写入缓存

获取到 token 后，在后续所有请求的 Header 中携带：

```
token: <TOKEN 变量值>
```

## 执行 API 调用的步骤

1. 读取环境变量 `ZENTAO_URL`、`ZENTAO_ACCOUNT`、`ZENTAO_PASSWORD`，若缺失则提示用户
2. 运行 `get-token.sh` 获取 token（自动处理缓存，无需每次登录）
3. 根据用户意图选择正确的 API 端点（参见 [api-reference.md](api-reference.md)）
4. 若为 PUT 操作且用户未提供全部字段，先调用对应 GET 详情接口取回当前数据，再将用户指定的字段覆盖进去
5. 构造请求（方法、URL、Header、Body）并向用户确认写操作内容
6. 执行请求，解析响应
7. 以清晰易读的格式向用户展示结果

## 常用操作示例

### 获取所有正在进行的执行（迭代/Sprint）

执行（execution）属于某个项目，需先确定项目 ID，或遍历所有项目：

```bash
# 先获取进行中的项目
curl -s "$ZENTAO_URL/api.php/v2/projects?browseType=doing" -H "token: $TOKEN"

# 再获取该项目的执行列表（将 {projectID} 替换为实际ID）
curl -s "$ZENTAO_URL/api.php/v2/projects/{projectID}/executions" -H "token: $TOKEN"
```

### 获取产品的 Bug 列表

```bash
curl -s "$ZENTAO_URL/api.php/v2/products/{productID}/bugs" -H "token: $TOKEN"
```

### 修改 Bug

```bash
curl -s -X PUT "$ZENTAO_URL/api.php/v2/bugs/{bugID}" \
  -H "token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "新标题", "severity": 2, "pri": 2}'
```

### 解决 Bug

```bash
curl -s -X PUT "$ZENTAO_URL/api.php/v2/bugs/{bugID}/resolve" \
  -H "token: $TOKEN" -H "Content-Type: application/json" -d '{}'
```

### 创建需求

```bash
curl -s -X POST "$ZENTAO_URL/api.php/v2/stories" \
  -H "token: $TOKEN" -H "Content-Type: application/json" \
  -d '{"productID": 1, "title": "需求标题", "assignedTo": "admin"}'
```

### 完成任务

```bash
curl -s -X PUT "$ZENTAO_URL/api.php/v2/tasks/{taskID}/finish" \
  -H "token: $TOKEN" -H "Content-Type: application/json" \
  -d '{"consumed": 2, "assignedTo": "admin", "finishedDate": "2026-03-18"}'
```

## 意图识别规则

| 用户意图关键词 | 对应操作 |
|--------------|---------|
| 正在进行的执行/迭代/Sprint | GET projects?browseType=doing + GET projects/{id}/executions |
| 获取所有产品/项目 | GET /products 或 GET /projects |
| 某产品/项目的 Bug | GET /products/{id}/bugs 或 /projects/{id}/bugs |
| 更新/修改 Bug | PUT /bugs/{id} |
| 解决 Bug | PUT /bugs/{id}/resolve |
| 关闭需求 | PUT /stories/{id}/close |
| 创建任务 | POST /tasks |
| 完成任务 | PUT /tasks/{id}/finish |
| 获取用户列表 | GET /users |

## 注意事项

- URL 中的数字 ID（如 `/bugs/1`）需替换为实际 ID
- 若不知道 ID，先调用列表接口获取，再操作具体条目
- **PUT 接口需提供所有相关字段**：禅道的 PUT API 通常要求请求体包含该资源的所有必填字段，而不仅仅是要修改的字段。若用户只指定了部分字段，必须先调用对应的 GET 详情接口获取当前完整数据，再将用户修改的字段覆盖进去，最后一并提交
- 写操作前向用户确认操作内容，避免误操作
- 响应为 401 表示 token 已被手动吊销，执行 `rm ~/.zentao-token.json` 清除缓存后重新运行
- `browseType` 常用值：`all`（全部）、`doing`（进行中）、`closed`（已关闭）

## 完整 API 参考

详细的端点列表和请求参数见 [api-reference.md](api-reference.md)。
