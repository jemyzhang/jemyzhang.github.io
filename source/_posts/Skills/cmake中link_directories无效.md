title: cmake中link_directories无效
date: 2016-10-14 12:36:00
tags: [cmake]

---



```shell
add_executable(debug ${SOURCE_FILES})
link_directories(libxxx/lib)
target_link_libraries(debug
     xxxx)
```

一直提示找不到xxx库, 解决方法很简单, 就是把`add_executable`放到`link_directories`后面就可以了-_-!

```shell
link_directories(libxxx/lib)
add_executable(debug ${SOURCE_FILES})
target_link_libraries(debug
     xxxx)
```

