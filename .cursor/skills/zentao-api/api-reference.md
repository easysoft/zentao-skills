# 禅道 API v2.0 端点参考

基础路径：`{ZENTAO_URL}/api.php/v2`  
认证方式：所有接口（除登录外）需在 Header 携带 `token: <token值>`

---

## 认证

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| POST | `/users/login` | 登录获取 token | `{"account":"admin","password":"xxx"}` |

响应：`data.token`

---

## 项目集（Program）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/programs` | 获取项目集列表 |
| GET | `/programs/{id}` | 获取项目集详情 |
| GET | `/programs/{id}/projects` | 获取项目集下的项目列表 |
| GET | `/programs/{id}/products` | 获取项目集下的产品列表 |

---

## 项目（Project）

| 方法 | 路径 | 说明 | 参数/Body |
|------|------|------|---------|
| GET | `/projects` | 获取项目列表 | 查询参数：`browseType=all\|doing\|closed` |
| GET | `/projects/{id}` | 获取项目详情 | |
| POST | `/projects` | 创建项目（敏捷） | `{"program":1,"name":"xxx","begin":"2026-01-01","end":"2026-12-31","products":[1]}` |
| POST | `/projects` | 创建瀑布项目 | `{"program":1,"name":"xxx","begin":"2026-01-01","end":"2026-12-31","model":"waterfull","products":[1]}` |
| PUT | `/projects/{id}` | 编辑项目 | `{"name":"新名称"}` |
| POST | `/projects/{id}/start` | 开始项目 | `{"realBegan":"2026-01-01","comment":"备注"}` |
| GET | `/projects/{id}/executions` | 获取项目的执行列表 | |
| GET | `/projects/{id}/stories` | 获取项目的需求列表 | |
| GET | `/projects/{id}/bugs` | 获取项目的 Bug 列表 | |
| GET | `/projects/{id}/testcases` | 获取项目的用例列表 | |
| GET | `/projects/{id}/testtasks` | 获取项目的测试任务列表 | |
| GET | `/projects/{id}/testreports` | 获取项目的测试报告列表 | |
| GET | `/projects/{id}/builds` | 获取项目的 Build 列表 | |
| GET | `/projects/{id}/releases` | 获取项目的发布列表 | |

---

## 产品（Product）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/products` | 获取产品列表 | |
| GET | `/products/{id}` | 获取产品详情 | |
| POST | `/products` | 创建产品 | `{"name":"产品名","type":"normal","PO":"admin","acl":"open"}` |
| PUT | `/products/{id}` | 编辑产品 | `{"name":"新名称","acl":"open"}` |
| DELETE | `/products/{id}` | 删除产品 | |
| GET | `/products/{id}/stories` | 获取产品的需求列表 | |
| GET | `/products/{id}/productplans` | 获取产品计划列表 | |
| GET | `/products/{id}/releases` | 获取产品发布列表 | |
| GET | `/products/{id}/bugs` | 获取产品 Bug 列表 | |
| GET | `/products/{id}/testcases` | 获取产品用例列表 | |
| GET | `/products/{id}/testtasks` | 获取产品测试任务列表 | |
| GET | `/products/{id}/testreports` | 获取产品测试报告列表 | |

---

## 执行（Execution / Sprint）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/executions/{id}` | 获取执行详情 |
| DELETE | `/executions/{id}` | 删除执行 |
| GET | `/executions/{id}/stories` | 获取执行的需求列表 |
| GET | `/executions/{id}/tasks` | 获取执行的任务列表 |
| GET | `/executions/{id}/bugs` | 获取执行的 Bug 列表 |
| GET | `/executions/{id}/testcases` | 获取执行的用例列表 |
| GET | `/executions/{id}/builds` | 获取执行的 Build 列表 |
| GET | `/executions/{id}/testtasks` | 获取执行的测试任务列表 |
| GET | `/executions/{id}/testreports` | 获取执行的测试报告列表 |

> 获取正在进行的执行：先调用 `GET /projects?browseType=doing` 获取项目列表，再调用 `GET /projects/{id}/executions`

---

## 需求（Story / Requirement）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/stories/{id}` | 获取需求（软件需求）详情 | |
| POST | `/stories` | 创建需求 | `{"productID":1,"title":"需求名","assignedTo":"admin"}` |
| PUT | `/stories/{id}` | 编辑需求 | `{"title":"新标题","assignedTo":"admin"}` |
| PUT | `/stories/{id}/close` | 关闭需求 | `{"closedReason":"done"}` |
| GET | `/epics/{id}` | 获取业务需求详情 | |
| GET | `/requirements/{id}` | 获取用户需求详情（同 epics） | |
| PUT | `/requirements/{id}` | 编辑用户需求 | `{"name":"新名称"}` |
| PUT | `/requirements/{id}/close` | 关闭用户需求 | `{"closedReason":"done"}` |

---

## 产品计划（ProductPlan）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/productplans/{id}` | 获取产品计划详情 | |
| POST | `/productplans` | 创建产品计划 | `{"productID":1,"title":"计划名"}` |
| PUT | `/products/{id}/productplans` | 编辑产品计划 | |

---

## 发布（Release）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/releases/{id}` | 获取发布详情 |

---

## 任务（Task）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/tasks/{id}` | 获取任务详情 | |
| POST | `/tasks` | 创建任务 | `{"executionID":1,"name":"任务名","type":"normal","assignedTo":"admin"}` |
| PUT | `/tasks/{id}/activate` | 激活任务 | `{"left":10,"assignedTo":"user1"}` |
| PUT | `/tasks/{id}/finish` | 完成任务 | `{"consumed":2,"assignedTo":"admin","finishedDate":"2026-03-18"}` |
| PUT | `/tasks/{id}/close` | 关闭任务 | `{}` |
| DELETE | `/tasks/{id}` | 删除任务 | |

---

## Build

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/builds/{id}` | 获取 Build 详情 |

---

## Bug

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/bugs/{id}` | 获取 Bug 详情 | |
| POST | `/bugs` | 创建 Bug | `{"productID":1,"title":"Bug标题","openedBuild":["trunk"]}` |
| PUT | `/bugs/{id}` | 修改 Bug | `{"title":"新标题","severity":2,"pri":2,"type":"codeerror"}` |
| PUT | `/bugs/{id}/resolve` | 解决 Bug | `{}` （可附加 `resolution` 字段） |

常用 Bug 字段：
- `severity`：严重程度 1-4（1最严重）
- `pri`：优先级 1-4（1最高）
- `type`：Bug 类型，如 `codeerror`、`config`、`install`、`security`、`performance`、`standard`、`automation`、`designdefect`
- `openedBuild`：发现版本，如 `["trunk"]` 或 `["1.0"]`
- `assignedTo`：指派给（用户账号）

---

## 用例（TestCase）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/testcases/{id}` | 获取用例详情 | |
| POST | `/testcases` | 创建用例 | `{"productID":1,"title":"用例名","module":1}` |
| PUT | `/testcases/{id}` | 修改用例 | `{"module":2}` |

---

## 测试任务（TestTask）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/testtasks/{id}` | 获取测试任务详情 | |
| POST | `/testtasks` | 创建测试任务 | `{"productID":1,"name":"测试任务名","build":1,"execution":1,"type":"integrate","owner":"admin","begin":"2026-01-01","end":"2026-12-31"}` |

---

## 测试报告（TestReport）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/testreports/{id}` | 获取测试报告详情 |

---

## 部门（Dept）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/depts` | 获取部门列表 |
| GET | `/depts/{id}` | 获取部门详情 |

---

## 用户（User）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/users` | 获取用户列表 | |
| GET | `/users/{id}` | 获取用户详情 | |
| PUT | `/users/{id}` | 编辑用户 | `{"realname":"真实姓名"}` |
| DELETE | `/users/{id}` | 删除用户 | |

---

## 文件（File）

| 方法 | 路径 | 说明 | Body 示例 |
|------|------|------|---------|
| GET | `/files/{id}` | 获取文件详情 | |
| POST | `/files` | 上传文件（multipart/form-data） | `file=<文件>, objectType=bug, objectID=1` |
| PUT | `/files/{id}` | 编辑文件信息 | `{"fileName":"新名称","extension":"png"}` |
| DELETE | `/files/{id}` | 删除文件 | |
