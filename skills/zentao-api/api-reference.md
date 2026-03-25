# 禅道 API v2.0 端点参考

基础路径：`{ZENTAO_URL}/api.php/v2`
认证方式：所有接口（除登录外）需在 Header 携带 `token: <token值>`

---

## 认证（Token）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/users/login` | 登录获取 token |

请求：`{"account":"admin","password":"xxx"}`
响应：`{"status":"success","token":"llb8ocefb0kbgklif53j839k6l"}`

---

## 用户（User）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/users` | 创建用户 |
| GET | `/users` | 获取用户列表 |
| GET | `/users/{userID}` | 获取用户详情 |
| PUT | `/users/{userID}` | 修改用户信息 |
| DELETE | `/users/{userID}` | 删除用户 |

常用字段：`account`, `realname`, `type`, `dept`, `gender`, `email`, `mobile`, `role`, `visions`

---

## 项目集（Program）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/programs` | 创建项目集 |
| GET | `/programs` | 获取项目集列表 |
| GET | `/programs/{programID}` | 获取项目集详情 |
| PUT | `/programs/{programID}` | 修改项目集 |
| DELETE | `/programs/{programID}` | 删除项目集 |
| GET | `/programs/{programID}/products` | 获取项目集的产品列表 |
| GET | `/programs/{programID}/projects` | 获取项目集的项目列表 |

常用字段：`name`, `parent`, `PM`, `begin`, `end`, `budget`, `budgetUnit`, `desc`, `acl`

---

## 产品（Product）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/products` | 创建产品 |
| GET | `/products` | 获取产品列表 |
| GET | `/products/{productID}` | 获取产品详情 |
| PUT | `/products/{productID}` | 修改产品 |
| DELETE | `/products/{productID}` | 删除产品 |

**产品关联资源列表：**

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/products/{productID}/stories` | 需求列表 |
| GET | `/products/{productID}/epics` | 业务需求列表 |
| GET | `/products/{productID}/requirements` | 用户需求列表 |
| GET | `/products/{productID}/bugs` | Bug 列表 |
| GET | `/products/{productID}/testcases` | 测试用例列表 |
| GET | `/products/{productID}/productplans` | 产品计划列表 |
| GET | `/products/{productID}/releases` | 发布列表 |
| GET | `/products/{productID}/testtasks` | 测试单列表 |
| GET | `/products/{productID}/feedbacks` | 反馈列表 |
| GET | `/products/{productID}/tickets` | 工单列表 |
| GET | `/products/{productID}/systems` | 应用列表 |

常用字段：`name`, `program`, `type`(normal), `desc`, `PO`, `QD`, `RD`, `acl`(open/private)

---

## 项目（Project）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/projects` | 创建项目 |
| GET | `/projects` | 获取项目列表 |
| PUT | `/projects/{projectID}` | 修改项目 |
| DELETE | `/projects/{projectID}` | 删除项目 |

查询参数：`browseType=all|doing|closed`

**项目关联资源列表：**

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/projects/{projectID}/executions` | 执行列表 |
| GET | `/projects/{projectID}/stories` | 需求列表 |
| GET | `/projects/{projectID}/bugs` | Bug 列表 |
| GET | `/projects/{projectID}/testcases` | 测试用例列表 |
| GET | `/projects/{projectID}/builds` | 版本列表 |
| GET | `/projects/{projectID}/testtasks` | 测试单列表 |

常用字段：`name`, `parent`, `model`(scrum/waterfall), `begin`, `end`, `budget`, `PM`, `desc`, `acl`, `products`(数组)

> 注意：OpenAPI 规范中无 `GET /projects/{projectID}` 项目详情接口

---

## 执行（Execution / Sprint）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/executions` | 创建执行 |
| GET | `/executions` | 获取执行列表 |
| GET | `/executions/{executionID}` | 获取执行详情 |
| PUT | `/executions/{executionID}` | 修改执行 |
| DELETE | `/executions/{executionID}` | 删除执行 |

**执行关联资源列表：**

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/executions/{executionID}/stories` | 需求列表 |
| GET | `/executions/{executionID}/tasks` | 任务列表 |
| GET | `/executions/{executionID}/bugs` | Bug 列表 |
| GET | `/executions/{executionID}/testcases` | 测试用例列表 |
| GET | `/executions/{executionID}/builds` | 版本列表 |
| GET | `/executions/{executionID}/testtasks` | 测试单列表 |

常用字段：`project`, `name`, `type`(sprint), `begin`, `end`, `days`, `PO`, `PM`, `QD`, `RD`, `desc`, `acl`

> 获取进行中的执行：先 `GET /projects?browseType=doing` 再 `GET /projects/{id}/executions`

---

## 需求（Story）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/stories` | 创建需求 |
| GET | `/stories/{storyID}` | 获取需求详情 |
| PUT | `/stories/{storyID}` | 修改需求 |
| DELETE | `/stories/{storyID}` | 删除需求 |
| PUT | `/stories/{storyID}/change` | 变更需求 |
| PUT | `/stories/{storyID}/close` | 关闭需求 |
| PUT | `/stories/{storyID}/activate` | 激活需求 |

列表通过父资源获取：`/products/{id}/stories`, `/projects/{id}/stories`, `/executions/{id}/stories`

常用字段：`product`, `title`, `type`(story), `category`(feature), `pri`, `estimate`, `source`, `spec`(描述), `verify`(验收标准), `assignedTo`, `reviewer`, `module`, `plan`

---

## 业务需求（Epic）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/epics` | 创建业务需求 |
| GET | `/epics/{storyID}` | 获取业务需求详情 |
| PUT | `/epics/{epicID}` | 修改业务需求 |
| DELETE | `/epics/{epicID}` | 删除业务需求 |
| PUT | `/epics/{epicID}/change` | 变更业务需求 |
| PUT | `/epics/{epicID}/close` | 关闭业务需求 |
| PUT | `/epics/{epicID}/activate` | 激活业务需求 |

列表：`/products/{id}/epics`

常用字段：同 Story，`type` 值为 `epic`

---

## 用户需求（Requirement）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/requirements` | 创建用户需求 |
| GET | `/requirements/{storyID}` | 获取用户需求详情 |
| PUT | `/requirements/{requirementID}` | 修改用户需求 |
| DELETE | `/requirements/{requirementID}` | 删除用户需求 |
| PUT | `/requirements/{requirementID}/change` | 变更用户需求 |
| PUT | `/requirements/{requirementID}/close` | 关闭用户需求 |
| PUT | `/requirements/{requirementID}/activate` | 激活用户需求 |

列表：`/products/{id}/requirements`

常用字段：同 Story，`type` 值为 `requirement`

---

## Bug

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/bugs` | 创建 Bug |
| GET | `/bugs/{bugID}` | 获取 Bug 详情 |
| PUT | `/bugs/{bugID}` | 修改 Bug |
| DELETE | `/bugs/{bugID}` | 删除 Bug |
| PUT | `/bugs/{bugID}/resolve` | 解决 Bug |
| PUT | `/bugs/{bugID}/close` | 关闭 Bug |
| PUT | `/bugs/{bugID}/activate` | 激活 Bug |

列表通过父资源获取：`/products/{id}/bugs`, `/projects/{id}/bugs`, `/executions/{id}/bugs`

常用字段：

| 字段 | 说明 |
|------|------|
| `product` | 所属产品 ID |
| `title` | Bug 标题 |
| `severity` | 严重程度 1-4（1 最严重） |
| `pri` | 优先级 1-4（1 最高） |
| `type` | 类型：`codeerror`, `config`, `install`, `security`, `performance`, `standard`, `automation`, `designdefect` |
| `steps` | 重现步骤 |
| `openedBuild` | 发现版本，如 `"trunk"` |
| `assignedTo` | 指派用户账号 |
| `os` | 操作系统 |
| `browser` | 浏览器 |
| `deadline` | 截止日期 |
| `story` | 关联需求 ID |
| `task` | 关联任务 ID |

---

## 任务（Task）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/tasks` | 创建任务 |
| GET | `/tasks/{taskID}` | 获取任务详情 |
| PUT | `/tasks/{taskID}` | 修改任务 |
| DELETE | `/tasks/{taskID}` | 删除任务 |
| PUT | `/tasks/{taskID}/start` | 启动任务 |
| PUT | `/tasks/{taskID}/finish` | 完成任务 |
| PUT | `/tasks/{taskID}/close` | 关闭任务 |
| PUT | `/tasks/{taskID}/activate` | 激活任务 |

列表：`/executions/{id}/tasks`

常用字段：

| 字段 | 说明 |
|------|------|
| `execution` | 所属执行 ID |
| `name` | 任务名称 |
| `type` | 类型：`devel`, `test`, `design`, `discuss`, `ui`, `affair`, `misc` |
| `pri` | 优先级 |
| `estimate` | 预计工时 |
| `left` | 剩余工时 |
| `consumed` | 已消耗工时（完成时填写） |
| `assignedTo` | 指派用户 |
| `estStarted` | 预计开始日期 |
| `deadline` | 截止日期 |
| `finishedDate` | 完成日期（完成时填写） |
| `story` | 关联需求 ID |

---

## 测试用例（Testcase）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/testcases` | 创建测试用例 |
| GET | `/testcases/{caseID}` | 获取测试用例详情 |
| PUT | `/testcases/{testcasID}` | 修改测试用例 |
| DELETE | `/testcases/{testcasID}` | 删除测试用例 |

列表通过父资源获取：`/products/{id}/testcases`, `/projects/{id}/testcases`, `/executions/{id}/testcases`

常用字段：`product`, `title`, `type`(feature), `pri`, `precondition`, `stage`, `story`, `module`, `steps`(数组 `{desc, expect, type}`)

---

## 产品计划（Productplan）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/productplans` | 创建产品计划 |
| GET | `/productplans/{planID}` | 获取产品计划详情 |
| PUT | `/productplans/{productplanID}` | 修改产品计划 |
| DELETE | `/productplans/{productplanID}` | 删除产品计划 |

列表：`/products/{id}/productplans`

常用字段：`product`, `title`, `begin`, `end`, `desc`

---

## 版本（Build）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/builds` | 创建版本 |
| PUT | `/builds/{buildID}` | 修改版本 |
| DELETE | `/builds/{buildID}` | 删除版本 |

列表：`/projects/{id}/builds`, `/executions/{id}/builds`

常用字段：`project`, `product`, `execution`, `name`, `date`, `desc`, `builder`, `scmPath`, `filePath`

---

## 发布（Release）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/releases` | 创建发布 |
| PUT | `/releases/{releasID}` | 修改发布 |
| DELETE | `/releases/{releasID}` | 删除发布 |

列表：`/products/{id}/releases`

常用字段：`product`, `build`, `name`, `date`, `desc`, `stories`, `bugs`

> 注意：路径参数名为 `releasID`（非 releaseID）

---

## 测试单（Testtask）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/testtasks` | 创建测试单 |
| PUT | `/testtasks/{testtaskID}` | 修改测试单 |
| DELETE | `/testtasks/{testtaskID}` | 删除测试单 |

列表：`/products/{id}/testtasks`, `/projects/{id}/testtasks`, `/executions/{id}/testtasks`

常用字段：`project`, `product`, `execution`, `build`, `name`, `type`(integrate), `owner`, `pri`, `begin`, `end`, `desc`

---

## 反馈（Feedback）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/feedbacks` | 创建反馈 |
| GET | `/feedbacks/{feedbackID}` | 获取反馈详情 |
| PUT | `/feedbacks/{feedbackID}` | 修改反馈 |
| DELETE | `/feedbacks/{feedbackID}` | 删除反馈 |
| PUT | `/feedbacks/{feedbackID}/close` | 关闭反馈 |
| PUT | `/feedbacks/{feedbackID}/activate` | 激活反馈 |

列表：`/products/{id}/feedbacks`

常用字段：`product`, `module`, `title`, `type`(story), `desc`, `pri`, `source`, `feedbackBy`, `public`, `notify`

---

## 工单（Ticket）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/tickets` | 创建工单 |
| GET | `/tickets/{ticketID}` | 获取工单详情 |
| PUT | `/tickets/{ticketID}` | 修改工单 |
| DELETE | `/tickets/{ticketID}` | 删除工单 |
| PUT | `/tickets/{ticketID}/close` | 关闭工单 |
| PUT | `/tickets/{ticketID}/activate` | 激活工单 |

列表：`/products/{id}/tickets`

常用字段：`product`, `module`, `title`, `type`(code), `desc`, `openedBuild`, `assignedTo`, `deadline`, `pri`

---

## 应用（System）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/systems` | 创建应用 |
| PUT | `/systems/{systemID}` | 修改应用 |

列表：`/products/{id}/systems`

---

## 文件（File）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/files` | 编辑附件名称 |
| DELETE | `/files/{fileID}` | 删除附件 |
