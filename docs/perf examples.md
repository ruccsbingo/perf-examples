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

下面展示一下perf 3.10.0版本追踪磁盘I/O的调用堆栈。

```
➜  ~ perf record -e block:block_rq_issue -ag 
➜  ~ ll perf.data
-rw------- 1 root root 3.9M Feb 22 16:35 perf.data
➜  ~ perf report -n --stdio

# To display the perf.data header info, please use --header/--header-only options.
#
# Samples: 9  of event 'block:block_rq_issue'
# Event count (approx.): 9
#
# Children      Self       Samples  Command       Shared Object      Symbol                          
# ........  ........  ............  ............  .................  ................................
#
   100.00%     0.00%             0  kworker/2:1H  [kernel.kallsyms]  [k] ret_from_fork               
            |
            ---ret_from_fork

   100.00%     0.00%             0  kworker/2:1H  [kernel.kallsyms]  [k] kthread                     
            |
            ---kthread
               ret_from_fork

   100.00%     0.00%             0  kworker/2:1H  [kernel.kallsyms]  [k] worker_thread               
            |
            ---worker_thread
               kthread
               ret_from_fork

   100.00%     0.00%             0  kworker/2:1H  [kernel.kallsyms]  [k] process_one_work            
            |
            ---process_one_work
               worker_thread
               kthread
               ret_from_fork
```

在上面的列子中，**perf record**命令用来追踪 block:block_rq_issue事件，参数-a指定追踪所有的CPUs,参数-g指定捕获程序调用的堆栈。当执行Ctrl-C时，追踪的数据被写入perf.data文件中。**perf report**命令用来可视化保存在perf.data中的数据，参数 --stdio指定按照树状结构展示。

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
# CPU counter statistics for the specified command:
perf stat command

# Detailed CPU counter statistics (includes extras) for the specified command:
perf stat -d command

# CPU counter statistics for the specified PID, until Ctrl-C:
perf stat -p PID

# CPU counter statistics for the entire system, for 5 seconds:
perf stat -a sleep 5

# Various basic CPU statistics, system wide, for 10 seconds:
perf stat -e cycles,instructions,cache-references,cache-misses,bus-cycles -a sleep 10

# Various CPU level 1 data cache statistics for the specified command:
perf stat -e L1-dcache-loads,L1-dcache-load-misses,L1-dcache-stores command

# Various CPU data TLB statistics for the specified command:
perf stat -e dTLB-loads,dTLB-load-misses,dTLB-prefetch-misses command

# Various CPU last level cache statistics for the specified command:
perf stat -e LLC-loads,LLC-load-misses,LLC-stores,LLC-prefetches command

# Using raw PMC counters, eg, counting unhalted core cycles:
perf stat -e r003c -a sleep 5 

# PMCs: counting cycles and frontend stalls via raw specification:
perf stat -e cycles -e cpu/event=0x0e,umask=0x01,inv,cmask=0x01/ -a sleep 5

# Count syscalls per-second system-wide:
perf stat -e raw_syscalls:sys_enter -I 1000 -a

# Count system calls by type for the specified PID, until Ctrl-C:
perf stat -e 'syscalls:sys_enter_*' -p PID

# Count system calls by type for the entire system, for 5 seconds:
perf stat -e 'syscalls:sys_enter_*' -a sleep 5

# Count scheduler events for the specified PID, until Ctrl-C:
perf stat -e 'sched:*' -p PID

# Count scheduler events for the specified PID, for 10 seconds:
perf stat -e 'sched:*' -p PID sleep 10

# Count ext4 events for the entire system, for 10 seconds:
perf stat -e 'ext4:*' -a sleep 10

# Count block device I/O events for the entire system, for 10 seconds:
perf stat -e 'block:*' -a sleep 10

# Count all vmscan events, printing a report every second:
perf stat -e 'vmscan:*' -a -I 1000

```

- 性能分析

```
# Sample on-CPU functions for the specified command, at 99 Hertz:
perf record -F 99 command

# Sample on-CPU functions for the specified PID, at 99 Hertz, until Ctrl-C:
perf record -F 99 -p PID

# Sample on-CPU functions for the specified PID, at 99 Hertz, for 10 seconds:
perf record -F 99 -p PID sleep 10

# Sample CPU stack traces (via frame pointers) for the specified PID, at 99 Hertz, for 10 seconds:
perf record -F 99 -p PID -g -- sleep 10


```



