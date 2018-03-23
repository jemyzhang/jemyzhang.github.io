title: Android init进程——属性服务
date: 2018-03-23
tags: [android, system]

---
> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://blog.csdn.net/wzy_1988/article/details/44999103

# **概述**

init是一个进程，确切的说，它是Linux系统中用户空间的第一个进程。由于Android是基于Linux内核的，所以init也是Android系统中用户空间的第一个进程。**init的进程号是1**。作为天字第一号进程，init有很多重要的工作：

1.  init提供property service（属性服务）来管理Android系统的属性。
2.  init负责创建系统中的关键进程，包括zygote。

以往的文章一上来就介绍init的源码，但是我这里先从这两个主要工作开始。搞清楚这两个主要工作是如何实现的，我们再回头来看init的源码。

这篇文章主要是介绍init进程的属性服务。

> 跟init属性服务相关的源码目录如下：
>
> 1.  system/core/init/
> 2.  bionic/libc/bionic/
> 3.  system/core/libcutils/

* * *

# **属性服务**

在windows平台上有一个叫做注册表的东西，它可以存储一些类似key/value的键值对。一般而言，系统或者某些应用程序会把自己的一些属性存储在注册表中，即使系统重启或应用程序重启，它还能根据之前在注册表中设置的属性值，进行相应的初始化工作。

Android系统也提供了类似的机制，称之为属性服务（property service）。应用程序可以通过这个服务查询或者设置属性。我们可以通过如下命令，获取手机中属性键值对。

```
adb shell getprop
```

例如红米Note手机的属性值如下：

```
[ro.product.device]: [lcsh92_wet_jb9]
[ro.product.locale.language]: [zh]
[ro.product.locale.region]: [CN]
[ro.product.manufacturer]: [Xiaomi]
```

在system/core/init/init.c文件的main函数中，跟属性服务的相关代码如下：

```
property_init();
queue_builtin_action(property_service_init_action, "property_service_init");
```

接下来，我们分别看一下这两处代码的具体实现。

* * *

# **属性服务初始化**

* * *

## **创建存储空间**

首先，我们先来看一下property_init函数的源码（/system/core/init/property_service.c）：

```
void property_init(void)
{
    init_property_area();
}
```

property_init函数中只是简单的调用了init_property_area方法，接下来我们看一下这个方法的具体实现：

```
static int property_area_inited = 0;
static workspace pa_workspace;
static int init_property_area(void)
{
    // 属性空间是否已经初始化
    if (property_area_inited)
        return -1;

    if (__system_property_area_init())
        return -1;

    if (init_workspace(&pa_workspace, 0))
        return -1;

    fcntl(pa_workspace.fd, F_SETFD, FD_CLOEXEC);

    property_area_inited = 1;
    return 0;
}
```

从init_property_area函数，我们可以看出，函数首先判断属性内存区域是否已经初始化过，如果已经初始化，则返回-1。如果没有初始化，我们接下来会发现有两个关键函数**__system_property_area_init**和**init_workspace**应该是跟内存区域初始化相关。那我们分别分析一下这两个函数具体实现。

* * *

### **__system_property_area_init**

__system_property_area_init函数位于/bionic/libc/bionic/system_properties.c文件中，具体代码实现如下：

```
struct prop_area {
    unsigned bytes_used;
    unsigned volatile serial;
    unsigned magic;
    unsigned version;
    unsigned reserved[28];
    char data[0];
};
typedef struct prop_area prop_area;
prop_area *__system_property_area__ = NULL;

#define PROP_FILENAME "/dev/__properties__"
static char property_filename[PATH_MAX] = PROP_FILENAME; 

#define PA_SIZE (128 * 1024)

static int map_prop_area_rw()
{
    prop_area *pa;
    int fd;
    int ret;

    /**
     * O_RDWR ==> 读写
     * O_CREAT ==> 若不存在，则创建
     * O_NOFOLLOW ==> 如果filename是软链接，则打开失败
     * O_EXCL ==> 如果使用O_CREAT是文件存在，则可返回错误信息
     */
    fd = open(property_filename, O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC | O_EXCL, 0444);
    if (fd < 0) {
        if (errno == EACCES) {
            abort();
        }
        return -1;
    }

    ret = fcntl(fd, F_SETFD, FD_CLOEXEC);
    if (ret < 0)
        goto out;

    if (ftruncate(fd, PA_SIZE) < 0)
        goto out;

    pa_size = PA_SIZE;
    pa_data_size = pa_size - sizeof(prop_area);
    compat_mode = false;

    // mmap映射文件实现共享内存
    pa = mmap(NULL, pa_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (pa == MAP_FAILED)
        goto out;

    /*初始化内存地址中所有值为0*/
    memset(pa, 0, pa_size);
    pa->magic = PROP_AREA_MAGIC;
    pa->version = PROP_AREA_VERSION;
    pa->bytes_used = sizeof(prop_bt);

    __system_property_area__ = pa;

    close(fd);
    return 0;

out:
    close(fd);
    return -1;
}

int __system_property_area_init()
{
    return map_prop_area_rw();
}
```

代码比较好理解，主要内容是利用mmap映射property_filename创建了一个共享内存区域，并将共享内存的首地址赋值给全局变量__system_property_area__。

> Tips
> 主要是想说一下struct prop_area的结构体定义很精妙。特别是`char data[];`的定义。这里char data[]可以理解成动态数组指针，但是它并没有被占用内存空间。所以计算pa->bytes_used的时候，并没有计算char data[]占用的空间。
>
> 但是，char data[]又是动态数组，我理解mmap分配的内存，prop_area除了头部占用了部分空间(即sizeof(prop_area))，其他的都是char data去支配了。
> 按照我的理解，最终属性也应该分配到char data[]所指向的内存中去。为了验证我的想法，我会跟踪property_set方法的具体实现。

#### **property_set**

property_set是在/system/core/init/property_service.c文件中定义的，具体源码如下：

```
int property_set(const char *name, const char *value)
{
    prop_info *pi;
    int ret;

    unsigned int namelen = strlen(name);
    unsigned int valuelen = strlen(value);

    if (!is_legal_property_name(name, namelen)) return -1;
    if (valuelen >= PROP_VALUE_MAX) return -1;

    pi = (prop_info*) __system_property_find(name);
    // ......省略后续代码，之后重点分析__system_property_find即可
}

static bool is_legal_property_name(const char *name, unsigned int namelen)
{
    if (namelen >= PROP_NAME_MAX) return false;
    if (namelen < 1) return false;
    if (name[0] == '.') return false;
    if (name[namelen - 1] == '.') return false;

    /* Only allow alphanumeric, plus '.', '-', or '_'*/
    /* Don't allow ".." to appear in a property name */
    unsigned int i;
    bool previous_was_dot = false;
    for (i = 0; i < namelen; i ++) {
        if (name[i] == '.') {
            if (previous_was_dot == true) return false;
            previous_was_dot = true;
            continue;
        }
        previous_was_dot = false;
        if (name[i] == '_' || name[i] == '-') continue;
        if (name[i] >= '0' && name[i] <= '9') continue;
        if (name[i] >= 'a' && name[i] <= 'z') continue;
        if (name[i] >= 'A' && name[i] <= 'Z') continue;
        return false;
    }
    return true;
}
```

可以看到，在property_set方法中，当添加一个(name, value)键值对时，会先在当前的属性空间中查找该键值对是否已经存在。根据我们之前的分析，这里查找的属性空间应该是prop_area结构体所指向的data区域。接下来，让我们深入代码去验证我们的想法。

__system_property_find函数是在/bionic/libc/bionic/system_properties.c文件中定义的：

```
const prop_info *__system_property_find(const char *name)
{
    return find_property(root_node(), name, strlen(name), NULL, 0, false);
}

// 分析一下root_node的实现
static prop_bt *root_node()
{
    return to_prop_obj(0);
}
static void *to_prop_obj(prop_off_t off)
{
    if (off > pa_data_size) {
        return NULL;
    }
    // 注意，这里off的值为0
    // 所以，验证了我们的想法，prop_area结构体的char data[]果然是属性空间的起始地址
    return __system_property_area__->data + off;
}
```

上面的代码已经验证了我之前所说的想法：data指针指向的区域是属性内容的起始地址。
大家感兴趣可以自己阅读代码，看一下属性键值对是如何在属性空间中存储的。（我大体看了一下，貌似是很简单的二叉查找树的形式）。

* * *

> Tips
> 关于mmap映射文件实现共享内存IPC通信机制，可以参考这篇文章：[mmap实现IPC通信机制](http://blog.csdn.net/wzy_1988/article/details/40858765)

* * *

### **init_workspace**

接下来，我们来看一下init_workspace函数的源码（/system/core/init/property_service.c）：

```
typedef struct {
    void *data;
    size_t size;
    int fd;
}workspace;

static int init_workspace(workspace *w, size_t size)
{
    void *data;
    int fd = open(PROP_FILENAME, O_RDONLY | O_NOFOLLOW);
    if (fd < 0)
        return -1;

    w->size = size;
    w->fd = fd;
    return 0;
}
```

* * *

## **客户端进程访问属性内存区域**

虽然属性内存区域是init进程创建的，但是Android系统希望其他进程也能够读取这块内存区域里的内容。为了做到这一点，init进程在属性区域初始化过程中做了如下两项工作：

1.  把属性内存区域创建在共享内存上，而共享内存是可以跨进程的。这一点，在上述代码中是通过mmap映射/dev/__properties__文件实现的。pa_workspace变量中的fd成员也保存了映射文件的句柄。
2.  如何让其他进程知道这个共享内存句柄呢？Android先将文件映射句柄赋值给__system_property_area__变量，这个变量属于bionic_lic库中的输出的一个变量，然后利用了gcc的constructor属性，这个属性指明了一个__lib_prenit函数，当bionic_lic库被加载时，将自动调用__libc_prenit，这个函数内部完成共享内存到本地进程的映射工作。

只讲原理是不行的，我们直接来看一下__lib_prenit函数代码的相关实现：

```
void __attribute__((constructor)) __libc_prenit(void);
void __libc_prenit(void)
{
    // ...
    __libc_init_common(elfdata); // 调用这个函数
    // ...
}
```

__libc_init_common函数为：

```
void __libc_init_common(uintptr_t *elfdata)
{
    // ...
    __system_properties_init(); // 初始化客户端的属性存储区域
}
```

__system_properties_init函数有回到了我们熟悉的/bionic/libc/bionic/system_properties.c文件：

```
static int get_fd_from_env(void)
{
    char *env = getenv("ANDROID_PROPERTY_WORKSPACE");

    if (! env) {
        return -1;
    }

    return atoi(env);
}

static int map_prop_area()
{
    bool formFile = true;
    int result = -1;
    int fd;
    int ret;

    fd = open(property_filename, O_RDONLY | O_NOFOLLOW | O_CLOEXEC);
    if (fd >= 0) {
        /* For old kernels that don't support O_CLOEXEC */
        ret = fcntl(fd, F_SETFD, FD_CLOEXEC);
        if (ret < 0)
            goto cleanup;
    }

    if ((fd < 0) && (error == ENOENT)) {
        fd = get_fd_from_env();
        fromFile = false;
    }

    if (fd < 0) {
        return -1;
    }

    struct stat fd_stat;
    if (fstat(fd, &fd_stat) < 0) {
        goto cleanup;
    }

    if ((fd_stat.st_uid != 0)
            || (fd_stat.st_gid != 0)
            || (fd_stat.st_mode & (S_IWGRP | S_IWOTH) != 0)
            || (fd_stat.st_size < sizeof(prop_area))) {
        goto cleanup;
    }

    pa_size = fd_stat.st_size;
    pa_data_size = pa_size - sizeof(prop_area);

    /* 
     * 映射init创建的属性内存到本地进程空间，这样本地进程就可以使用这块共享内存了。
     * 注意：映射时制定了PROT_READ属性，所以客户端进程只能读属性，不能设置属性。
     */
    prop_area *pa = mmap(NULL, pa_size, PROT_READ, MAP_SHARED, fd, 0);

    if (pa == MAP_FAILED) {
        goto cleanup;
    }

    if ((pa->magic != PROP_AREA_MAGIC) || (pa->version != PROP_AREA_VERSION && pa->version != PROP_AREA_VERSION_COMPAT)) {
        munmap(pa, pa_size);
        goto cleanup;
    }

    if (pa->version == PROP_AREA_VERSION_COMPAT) {
        compat_mode = true;
    }

    result = 0;

    __system_property_area__ = pa;
cleanup:
    if (fromFile) {
        close(fd);
    }

    return result;
}

int __system_properties_init()
{
    return map_prop_area();
}
```

通过对源码的阅读，可以发现，客户端通过mmap映射，可以读取属性内存的内容，但是没有权限设置属性。那客户端是如何设置属性的呢？这就涉及到下面要将的属性服务器了。

* * *

# **属性服务器的分析**

init进程会启动一个属性服务器，而客户端只能通过与属性服务器的交互来设置属性。

* * *

## **启动属性服务器**

先来看一下属性服务器的内容，它由property_service_init_action函数启动，源码如下（/system/core/init/init.c&&property_service.c）：

```
static int property_service_init_action(int nargs, char **args)
{
    start_property_service();
    return 0;
}

static void load_override_properties()
{
#ifdef ALLOW_LOCAL_PROP_OVERRIDE
    char debuggable[PROP_VALUE_MAX];
    int ret;

    ret = property_get("ro.debuggable", debuggable);
    if (ret && (strcmp(debuggable, "1") == 0)) {
        load_properties_from_file(PROP_PATH_LOCAL_OVERRIDE);
    }
#endif
}

static void load_properties(char *data)
{
    char *key, *value, *eol, *sol, *tmp;

    sol = data;
    while ((eol = strchr(sol, '\n'))) {
        key = sol;
        // 赋值下一行的指针给sol
        *eol ++ = 0;
        sol = eol;

        value = strchr(key, '=');
        if (value == 0) continue;
        *value++ = 0;

        while (isspace(*key)) key ++;
        if (*key == '#') continue;
        tmp = value - 2;
        while ((tmp > key) && isspace(*tmp)) *tmp-- = 0;

        while (isspace(*value)) value ++;
        tmp = eol - 2;
        while ((tmp > value) && isspace(*tmp)) *tmp-- = 0;

        property_set(key, value);
    }
}

int create_socket(const char *name, int type, mode_t perm, uid_t uid, gid_t gid)
{
    struct sockaddr_un addr;
    int fd, ret;
    char *secon;

    fd = socket(PF_UNIX, type, 0);
    if (fd < 0) {
        ERROR("Failed to open socket '%s': %s\n", name, strerror(errno));
        return -1;
    }

    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    snprintf(addr.sun_path, sizeof(addr.sun_path), ANDROID_SOCKET_DIR"/%s", name);

    ret = unlink(addr.sun_path);
    if (ret != 0 && errno != ENOENT) {
        goto out_close;
    }

    ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
    if (ret) {
        goto out_unlink;
    }
    chown(addr.sun_path, uid, gid);
    chmod(addr.sun_path, perm);

    return fd;

out_unlink:
    unlink(addr.sun_path);
out_close:
    close(fd);
    return -1;
}

#define PROP_PATH_SYSTEM_BUILD "/system/build.prop"
#define PROP_PATH_SYSTEM_DEFAULT "/system/default.prop"
#define PROP_PATH_LOCAL_OVERRIDE "/data/local.prop"
#define PROP_PATH_FACTORY "/factory/factory.prop"

void start_property_service(void)
{
    int fd;

    load_properties_from_file(PROP_PATH_SYSTEM_BUILD);
    load_properties_from_file(PROP_PATH_SYSTEM_DEFAULT);
    load_override_properties();
    /*Read persistent properties after all default values have been loaded.*/
    load_persistent_properties();

    fd = create_socket(PROP_SERVICE_NAME, SOCK_STREAM, 0666, 0, 0);
    if (fd < 0) return;
    fcntl(fd, F_SETFD, FD_CLOEXEC);
    fcntl(fd, F_SETFL, O_NONBLOCK);

    listen(fd, 8);
    property_set_fd = fd;
}
```

从上述代码可以看到，init进程除了会预写入指定文件（例如：system/build.prop）属性外，还会创建一个UNIX Domain Socket，用于接受客户端的请求，构建属性。那这个socket请求是再哪里被处理的呢？
答案是：在init中的for循环处已经进行了相关处理。

> 更多关于UNIX Domain Socket IPC的介绍，可以考虑这篇文章：[UNIX Domain Socket IPC](http://blog.csdn.net/wzy_1988/article/details/44928691)

* * *

## **服务端处理设置属性请求**

接收属性设置请求的地方是在init进程中，相关代码如下所示：

```
int main(int argc, char **argv)
{
    // ...省略不相关代码

    for (;;) {
        // ...
        for (i = 0; i < fd_count; i ++) {
            if (ufds[i].fd == get_property_set_fd())
                handle_property_set_fd();
        }
    }
}
```

从上述代码可以看出，当属性服务器收到客户端请求时，init进程会调用handle_property_set_fd函数进行处理，函数位置是：system/core/init/property_service.c，我们来看一下这个函数的实现源码：

```
void handle_property_set_fd()
{
    prop_msg msg;
    int s;
    int r;
    int res;
    struct ucred cr;
    struct sockaddr_un addr;
    socklen_t addr_size = sizeof(addr);
    socklen_t cr_size = sizeof(cr);
    char *source_ctx = NULL;

    // 接收TCP连接
    if ((s = accept(property_set_fd, (struct sockaddr *) &addr, &addr_size)) < 0) {
        return;
    }

    // 接收客户端请求数据
    r = TEMP_FAILURE_RETRY(recv(s, &msg, sizeof(msg), 0));
    if (r != sizeof(prop_msg)) {
        ERROR("sys_prop: mis-match msg size received: %d expected : %d errno: %d\n", r, sizeof(prop_msg), errno);
        close(s);
        return;
    }

    switch(msg.cmd) {
    case PROP_MSG_SETPROP:
        msg.name[PROP_NAME_MAX - 1] = 0;
        msg.value[PROP_VALUE_MAX - 1] = 0;

        if (memcmp(msg.name, "ctl.", 4) == 0) {
            close(s);
            if (check_control_perms(msg.value, cr.uid, cr.gid, source_ctx)) {
                handle_control_message((char*) msg.name + 4, (char*) msg.value);
            } else {
                ERROR("sys_prop: Unable to %s service ctl [%s] uid:%d gid:%d pid:%d\n", msg.name + 4, msg.value, cr.uid, cr.gid, cr.pid);
            }
        } else {
            if (check_perms(msg.name, cr.uid, cr.gid, source_ctx)) {
                property_set((char *) msg.name, (char*) msg.value);
            }
            close(s);
        }
        break;
    default:
        close(s);
        break;
    }
}
```

当客户端的权限满足要求时，init就调用property_set进行相关处理。property_set源码实现如下：

```
int property_set(const char *name, const char *value)
{
    prop_info *pi;
    int ret;

    size_t namelen = strlen(name);
    size_t valuelen = strlen(value);

    if (! is_legal_property_name(name, namelen)) return -1;
    if (valuelen >= PROP_VALUE_MAX) return -1;

    // 从属性空间中寻找是否已经存在该属性值
    pi = (prop_info*) __system_property_find(name);
    if (pi != 0) {
        // ro开头的属性被设置后，不允许再被修改
        if (! strncmp(name, "ro.", 3)) return -1;

        __system_property_update(pi, value, valuelen);
    } else {
        ret = __system_property_add(name, namelen, value, valuelen);
    }

    // 有一些特殊的属性需要特殊处理，例如net.和persist.开头的属性
    if (strncmp("net.", name, strlen("net.")) == 0) {
        if (strcmp("net.change", name) == 0) {
            return 0;
        }
        property_set("net.change", name);
    } else if (persistent_properties_loaded && strncmp("persist.", name, strlen("persist.")) == 0) {
        write_persistent_property(name, value);
    }
    property_changed(name, value);
    return 0;
}
```

属性服务器端的工作基本到这里就完成了。最后，我们来看一下客户端是如何发送设置属性的socket请求。

* * *

## **客户端发送请求**

客户端设置属性时是调用了property_set(“sys.istest”, “true”)方法。从上述分析可知，该方法实现跟服务器端的property_set方法不同，该方法一定是发送了socket请求，该方法源码位置为：/system/core/libcutils/properties.c：

```
int property_set(const char *key, const char *value)
{
    return __system_property_set(key, value);
}
```

可以看到，property_set调用了__system_property_set方法，这个方法位于：/bionic/libc/bionic/system_properties.c文件中：

```
struct prop_msg
{
    unsigned cmd;
    char name[PROP_NAME_MAX];
    char value[PROP_VALUE_MAX];
};
typedef struct prop_msg prop_msg;

static int send_prop_msg(prop_msg *msg)
{
    struct pollfd pollfds[1];
    struct sockaddr_un addr;
    socklen_t alen;
    size_t namelen;
    int s;
    int r;
    int result = -1;

    s = socket(AF_LOCAL, SOCK_STREAM, 0);
    if (s < 0) {
        return result;
    }

    memset(&addr, 0, sizeof(addr));
    namelen = strlen(property_service_socket);
    strlcpy(addr.sun_path, property_service_socket, sizeof(addr.sun_path));
    addr.sun_family = AF_LOCAL;
    alen = namelen + offsetof(struct sockaddr_un, sun_path) + 1;

    if (TEMP_FAILURE_RETRY(connect(s, (struct sockaddr *) &addr, alen)) < 0) {
        close(s);
        return result;
    }

    r = TEMP_FAILURE_RETRY(send(s, msg, sizeof(prop_msg), 0));

    close(s);
    return result;
}

int __system_property_set(const char *key, const char *value)
{
    int err;
    prop_msg msg;

    if (key == 0) return -1;
    if (value == 0) value = "";
    if (strlen(key) >= PROP_NAME_MAX) return -1;
    if (strlen(value) >= PROP_VALUE_MAX) return -1;

    memset(&msg, 0, sizeof(msg));
    msg.cmd = PROP_MSG_SETPROP;
    strlcpy(msg.name, key, sizeof(msg.name));
    strlcpy(msg.value, value, sizeof(msg.value));

    err = send_prop_msg(&msg);
    if (err < 0) {
        return err;
    }
    return 0;
}
```
