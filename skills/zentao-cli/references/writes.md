# 写入、状态流转与批量

先读取动作帮助，替换示例 ID 与账号为用户授权的真实值。

```bash
zentao story create --product-id 1 --title '需求标题' --assigned-to admin --pri 3
zentao story update 11 --plan 1
zentao story change 11 --data '{"title":"调整后的需求","reviewer":["reviewer1"]}'
zentao doc create-my-doc --space-id 1 --lib-id 2 --data '{"title":"说明","content":"# 正文","contentType":"doc"}'
zentao bug create --product 1 --title 'Bug 标题' --opened-build trunk
zentao story create --product-id 1 --data @body.json
zentao story create --product-id 1 --data @- < body.json
```

空格与等号赋值等价，多行文本和额外等号保持原文。类型由 schema 决定，不猜测字符串类型。请求体 JSON 必须是对象，同名字段来自多个入口且值不同时报错。只有显式 @- 才读取标准输入。API 数组需要数值时，用重复数值选项或 JSON 数字数组，不能把字符串数字混入。

story/requirement/epic 的 create/change：没有有效 reviewer 时跳过评审，状态默认 active；显式 status=draft 保留草稿。有有效 reviewer 时状态固定 reviewing。change 不自动保存原草稿状态，先核对业务意图。

更新 autoFill 仅在存在匹配的详情操作时生效，只补动作声明的可写字段；显式空字符串不会被当成缺省。状态流转不自动补全。不要复制整份 GET 结果作为请求体。

```bash
zentao bug resolve --ids 123,124 --resolution fixed --format=json
zentao bug delete --ids 123,124 --yes --no-input --format=json
zentao repo create --data '{"space":10,"product":[12,13],"name":"demo_repo"}'
zentao relation unlink 8 --yes
```

ids 只用于帮助声明支持批量的对象动作；与单个目标互斥，先完整校验和去重。创建多条记录显式逐条 create。relation unlink 使用 relation list 返回的关系记录 ID，不能用对象 ID 或 relationKey 替代。

批量逐项保留数据与错误；batch-fail-fast 不回滚已经成功的部分。写入超时或结果不明确时先按返回 ID、标题或列表核实，不盲目重复创建。
