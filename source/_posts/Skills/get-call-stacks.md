title: Get Call stacks
date: 2016-09-10
tags: [shell, skills, linux, snippets]
---
Get Call stacks
===

```sh
get_stack() {
   STACK=""
   # to avoid noise we start with 1 to skip get_stack caller
   local i
   local stack_size=${#FUNCNAME[@]}
   for (( i=1; i<$stack_size ; i++ )); do
      local func="${FUNCNAME[$i]}"
      [ x$func = x ] && func=MAIN
      local linen="${BASH_LINENO[(( i - 1 ))]}"
      local src="${BASH_SOURCE[$i]}"
      [ x"$src" = x ] && src=non_file_source

      STACK+=$'\n'"   "$func" "$src" "$linen
   done
}
```
