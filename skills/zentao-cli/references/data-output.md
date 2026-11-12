# 数据与输出

默认 table 适合终端，markdown 适合文档，json 适合程序。JSON 成功封装为 `{ok:true,data,meta}`，失败为 stderr 上的 `{ok:false,error:{code,message,details?}}`。批量 data 含逐项 objectID、ok、data/error/skipped，meta 含成功、失败和跳过数量；部分失败退出码为 1。

JSON 不隐式修改 HTML 内容，不截断字段值。`--fields` 显式选择字段；需要转换富文本时使用 `--html-to-markdown`。raw 输出原始服务端响应，不能与本地过滤、排序、字段摘取、自动分页组合。

```bash
zentao product list --page 2 --page-size 50 --format=json
zentao bug list --product 1 --all --fields id,title,status --format=json
zentao product list --all --max-items 100 --sort id:desc --format=json
```

只有具有服务端分页能力的动作才提供 page/page-size/all。默认当前页；all 获取全部页面后再过滤、排序和限制返回数量。max-items 不改变服务端原生 limit 的含义。

meta 的 returned 是实际返回数，fetched 是获取数，total 为服务器本地处理前总数；hasMore 表示服务器是否还有页，truncated 表示是否被 max-items 截断，processingScope 是 page 或 all。未知分页为 null，不宣称完整。空筛选结果可能仍有下一页。

filter/search/sort 都仅作用于已获取范围；复杂查询可用 jq。业务查询字段（如 browse-type、filters、order-by）由服务端处理，不能与客户端 filter 混淆。

quiet 仅压制进度，结果仍输出。诊断和错误使用 stderr。timeout 是单请求毫秒数，deadline 是含认证与预取的整次期限；取消不会回滚已完成写入。
