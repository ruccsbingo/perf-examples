# perf 用法

![png](images/perf_events_map.png)



perf是一个基于事件的监控工具，借助这个事件监控工具，能解决很多高级的性能瓶颈，以及发现各种疑难杂症。它能解答如下几类问题：

- 为什么内核频繁占用CPU？代码的调用堆栈是什么？
- 哪些代码调用引起CPU L2 cache misses？
- memory是否到达瓶颈，造成CPUs阻塞？
- 哪些代码调用整整分配内存，分配了多少内存？
- 什么正在触发TCP重传？
- 某个内核函数是否正在被调用？调用频率是多少？
- 正在执行的线程被换出CPU的原因是什么？

perf是Linux内核的一部分，被放置在 tools/perf文件目录下。它使用了很多Linux的tracing特性，有一些并没有通过perf的命令暴露出来，需要使用ftrace接口代替。

接下来的几大主要模块：Events, One-Lines, Presentations, Prerequisites, CPU statistics, Timed Profiling, 以及Flames Graphs。

## 一个简单的调用堆栈截图



## 一些有用的短命令

- 列出系统支持的事件

```
# Listing all currently known events:
perf list

# Listing sched tracepoints:
perf list 'sched:*'
```

- 计数相关事件

```

```





