title: 打印预编译宏
date: 2015-11-26 13:59:58
tags: [c, predefine]
---

```
#define PRINT_MACRO_HELPER(x) #x 
#define PRINT_MACRO(x) #x"="PRINT_MACRO_HELPER(x) 

#pragma message(PRINT_MACRO(MULTI_CACHE)) 
#pragma message(PRINT_MACRO(_CACHE))
```
<!-- more -->
