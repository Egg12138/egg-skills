---
name: c-err-analyse
description: Compactly analyze standard C compiler errors by extracting error symbols, classifying error types, identifying direct causes, and producing concise diagnostic reports.
allowed-tools: [Read, Grep, Bash, Glob]
---

# triggers

/c-err-analyse
c compilation error analyse
/c-err-ananlyse --file <log>

# purpose

用于分析 标准 C 编译错误 并输出：

1. 多行错误的紧凑提取
2. 符号/字段精简解析
3. 简要直接原因（紧凑描述）
4. 可读性强、节省token、不废话

# catelogs

分类用于 conclusions 阶段辅助判断：

分类	示例关键字
Syntax	expected ‘;’, stray, expected identifier
Type/Declaration	unknown type, conflicting types, redeclaration
Prototype/Call	implicit declaration, too few/many arguments
Identifier/Scope	undeclared, unknown identifier
Macro/Preproc	#include not found, macro name missing
Init/Constexpr	initializer element not constant

# output format


===errors===
[file:line] "<原始错误消息>" => "<关键符号/字段>"
...


关键符号抽取规则：

Identifier：如 foo, bar

Type：如 `int`, `MY_TYPE`

Function：如 printf, foo

Macro/Include：如 #include, MY_MACRO

示例抽取：

输入行：
main.c:12:5: error: implicit declaration of function ‘foo’
输出变为：

[main.c:12] "implicit declaration of function ‘foo’" => function=foo

“简要诊断（direct cause）” 区块

对应输出：

===conclusions===
err1 => <直接原因（1行）>
err2 => <直接原因（1行）>
...


直接原因模板示例：

缺函数声明 / 未包含头文件

类型不匹配

标识符未声明

语法符号缺失

宏格式非法

初始化需要常量表达式

---

完整紧凑报告模板

处理多错误时，统一输出如下结构：

════════════════════
🧩 C COMPILATION REPORT
════════════════════

===errors===
[file:line] "<err1 raw>" => "<key fields>"
[file:line] "<err2 raw>" => "<key fields>"
...

===conclusions===
err1 => <direct cause (one-line)>
err2 => <direct cause (one-line)>
...

════════════════════

# example 

示例（完整演示）

输入模拟：

main.c:5:5: error: implicit declaration of function ‘foo’
main.c:6:12: error: ‘x’ undeclared (first use in this function)
main.c:10:1: error: expected ‘;’ before ‘}’


输出为：

════════════════════
🧩 C COMPILATION REPORT
════════════════════

===errors===
[main.c:5] "implicit declaration of function ‘foo’" => function=foo
[main.c:6] "‘x’ undeclared" => identifier=x
[main.c:10] "expected ‘;’ before ‘}’" => symbol=";" context="}"

===conclusions===
err1 => 函数 foo 未声明，可能缺少头文件或函数原型
err2 => 标识符 x 未在作用域内声明或拼写错误
err3 => 缺分号导致语法错误

════════════════════

# workflow

分析流程：
提取错误行
抽取位置 file:line
提取关键字段（identifier/type/function）
映射分类
生成直接原因（one-line）
输出紧凑结构
