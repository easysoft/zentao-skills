---
name: zentao-api
description: 调用禅道（ZenTao）RESTful API v2.0 完成用户请求，包括查询项目、执行、需求、Bug、任务、测试用例等数据，以及创建、编辑、删除等写操作。当用户提到禅道、zentao、查询项目进展、获取Bug列表、更新需求状态、创建任务等项目管理相关操作时使用本技能。
---

# 禅道 API v2.0

## 配置

优先从环境变量读取：

| 变量 | 说明 |
|------|------|
| `ZENTAO_URL` | 服务器地址，如 `http://zentao.example.com` |
| `ZENTAO_ACCOUNT` | 登录账号 |
| `ZENTAO_PASSWORD` | 登录密码 |

若环境变量未配置，提示用户设置这三个环境变量的值后再继续，为了方便用户设置环境变量，应该给出设置环境变量的命令。如果用户直接提供了服务器、账号和密码，则直接使用，但同时告知用户尽量设置为环境变量，避免每次都要输入，此时为了方便用户，可以提供一键设置环境变量的命令。

## 认证流程

所有业务 API 均需在 Header 携带 `token`。每次执行前先获取 token：

```bash
curl -s -X POST "$ZENTAO_URL/api.php/v2/users/login" \
  -H "Content-Type: application/json" \
  -d '{"account": "$ZENTAO_ACCOUNT", "password": "$ZENTAO_PASSWORD"}'
```

响应中 `token` 即为后续请求所需 token。将其保存为变量后在后续请求 Header 中传递：

```
token: <获取到的token值>
```

## 执行 API 调用的步骤

1. 读取环境变量 `ZENTAO_URL`、`ZENTAO_ACCOUNT`、`ZENTAO_PASSWORD`，若缺失则提示用户
2. 调用登录 API 获取 token
3. 根据用户意图选择正确的 API 端点（参见 [api-reference.md](api-reference.md)）
4. 构造请求（方法、URL、Header、Body）
5. 执行请求，解析响应
6. 以清晰易读的格式向用户展示结果

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
- 写操作前向用户确认操作内容，避免误操作
- 响应为 401 表示 token 无效，需重新登录获取 token
- `browseType` 常用值：`all`（全部）、`doing`（进行中）、`closed`（已关闭）

## 完整 API 参考

详细的端点列表和请求参数见 [api-reference.md](api-reference.md)。
