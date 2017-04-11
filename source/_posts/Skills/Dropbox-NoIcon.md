title: No icon display on status bar
date: 2016-09-10
tags: [trouble, dropbox, ubuntu]

---
No icon display on status bar
===

```
dropbox stop && DBUS_SESSION_BUS_ADDRESS="" dropbox start
# - or -
dropbox stop && dbus-launch dropbox start
```

