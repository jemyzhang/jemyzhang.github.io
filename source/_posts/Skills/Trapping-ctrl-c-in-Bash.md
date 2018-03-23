title: Trapping ctrl-c in Bash
date: 2015-06-17 18:28:10
tags: [bash, shell]
---

You can use the trap builtin to handle a user pressing ctrl-c during the execution of a Bash script. e.g. if you need to perform some cleanup functions.
<!-- more -->
```
#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
}

for i in `seq 1 5`; do
    sleep 1
    echo -n "."
done
```
