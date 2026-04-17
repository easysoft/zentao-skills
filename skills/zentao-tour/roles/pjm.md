# 项目经理视角

用户选了这个身份，意味着他关心的是"怎么把事情安排下去、推进下去"。陪他走一段"拉起一个项目 → 排一个 sprint → 把人安排进去 → 看看节奏"的路子，**但不要编号、不要预告清单、不要小结套话**。

## 开场一两句，马上拉出现有产品

不要列"我们要做 4 件事"。直接这样起头（示例）：

> "那我们来安排一个项目吧。先看看你们禅道里已经有啥产品——一个项目总得服务于某个产品。"

顺手跑一下，让用户从现有产品里挑：

```bash
zentao product --pick=id,name --limit=10
```

如果一条都没有，别卡住，顺水建议："要不我们借 PM 视角先捏一个玩具产品出来？"（跳到 [pm.md](pm.md) 的建产品那段，建完回来）。

## 拉起项目这件事，用最简几个字段就够

和用户聊清三样就可以动手：

- 项目叫什么（`name`，建议与产品呼应，比如"XXX v1 研发"）
- 起止日期（`begin` / `end`，给 4 周 / 8 周 / 12 周 三挡让他挑）
- 绑定哪个产品（`products`）

征得同意后执行：

```bash
zentao project create --name="..." --begin=<YYYY-MM-DD> --end=<YYYY-MM-DD> --products=<产品ID>
```

顺手把工作区挂上：`zentao workspace set --project=<项目ID>`。

告诉用户一句口语化的话，比如 "《XXX 研发》已经开张了，后面的 sprint 都挂它下面"。

## 接着抛一个问题，引到 Sprint

> "项目像个大框，真正要往前推，还得切成一段段小冲刺。你们团队习惯两周一个 sprint 还是更长？"

用户答完后：

```bash
zentao execution create --project=<项目ID> --name="Sprint 1" --begin=... --end=...
```

然后 `zentao workspace set --execution=<执行ID>`，以后任务命令更省事。

## 顺势把需求拆成任务

> "既然 sprint 立起来了，我们挑几条需求塞进去？"

先看可以塞什么：

```bash
zentao story --product=<产品ID> --filter='stage:wait' --pick=id,title,pri
```

和用户挑 2–3 条就够，别贪多。对每一条都问一句"你打算把它拆成几个任务？给谁做？预估几小时？"——用户给出一组就创建一个：

```bash
zentao task create --execution=<执行ID> --name="..." --type=devel --assignedTo=<账号> --estimate=<小时>
```

拆到第三条的时候可以主动刹车："节奏差不多了，想不想看看现在已经排成什么样？"

## 让他看到"进度"是什么感觉

```bash
zentao task --execution=<执行ID> --pick=id,name,status,assignedTo,estimate
```

如果用户对流转感兴趣，顺手演示一个任务从开始到完成：

```bash
zentao task start <id>
zentao task finish <id> --consumed=<实际小时>
```

边演示边用一句话解释 status 从 `wait` → `doing` → `done` 的变化，就足够了。

## 自然收尾

出现下列信号之一就可以收：

- 用户开始问"那 Bug 呢 / 测试呢"——介绍测试视角的存在，邀请切换。
- 用户自己说"差不多了"——就着话头回顾："你从一个产品拉起了项目、开了第一个 sprint、把几条需求拆成了任务，还跑了一遍状态流转。"
- 对话自然淡下来——回到 [../SKILL.md](../SKILL.md) 的收尾流程，问要不要换身份或清理演示数据。

## 写操作速查（给 AI 用）

| 动作 | 命令 |
|------|------|
| 建项目 | `zentao project create --name= --begin= --end= --products=<产品ID>` |
| 建 Sprint | `zentao execution create --project= --name= --begin= --end=` |
| 建任务 | `zentao task create --execution= --name= --type=devel --assignedTo= --estimate=` |
| 启动任务 | `zentao task start <id>` |
| 完成任务 | `zentao task finish <id> --consumed=<小时>` |
| 查执行下任务 | `zentao task --execution=<id> --pick=id,name,status,assignedTo` |

> 本视角目前剧情比较轻，欢迎根据真实团队节奏补得更丰满。
