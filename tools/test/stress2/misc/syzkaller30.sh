#!/bin/sh

# panic: sched_pickcpu: Failed to find a cpu.
# cpuid = 1
# time = 1607419071
# KDB: stack backtrace:
# db_trace_self_wrapper() at db_trace_self_wrapper+0x2b/frame 0xfffffe01bb640770
# vpanic() at vpanic+0x181/frame 0xfffffe01bb6407c0
# panic() at panic+0x43/frame 0xfffffe01bb640820
# sched_pickcpu() at sched_pickcpu+0x4a2/frame 0xfffffe01bb6408d0
# sched_add() at sched_add+0x5d/frame 0xfffffe01bb640900
# setrunnable() at setrunnable+0x77/frame 0xfffffe01bb640930
# wakeup_one() at wakeup_one+0x1d/frame 0xfffffe01bb640950
# do_lock_umutex() at do_lock_umutex+0x64c/frame 0xfffffe01bb640a40
# __umtx_op_wait_umutex() at __umtx_op_wait_umutex+0x49/frame 0xfffffe01bb640a80
# sys__umtx_op() at sys__umtx_op+0x7a/frame 0xfffffe01bb640ac0
# amd64_syscall() at amd64_syscall+0x147/frame 0xfffffe01bb640bf0
# fast_syscall_common() at fast_syscall_common+0xf8/frame 0xfffffe01bb640bf0
# --- syscall (454, FreeBSD ELF64, sys__umtx_op), rip = 0x800254a8c, rsp = 0x7fffdf3f7e88, rbp = 0x7fffdf3f7eb0 ---
# KDB: enter: panic
# [ thread pid 58597 tid 106100 ]
# Stopped at      kdb_enter+0x37: movq    $0,0x10a7766(%rip)
# db> x/s version
# version: FreeBSD 13.0-CURRENT #0 r368405: Mon Dec  7 10:33:35 CET 2020
# pho@t2.osted.lan:/usr/src/sys/amd64/compile/PHO
# db>

[ `uname -p` != "amd64" ] && exit 0

# Fixed by r368462

# May change policy for random threads to to domainset_fixed
exit 0

. ../default.cfg
cat > /tmp/syzkaller30.c <<EOF
// https://syzkaller.appspot.com/bug?id=6652adb41773e5c471c98342fefcbfb041af9ac8
// autogenerated by syzkaller (https://github.com/google/syzkaller)
// Reported-by: syzbot+4e3b1009de98d2fabcda@syzkaller.appspotmail.com

#define _GNU_SOURCE

#include <pwd.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/endian.h>
#include <sys/syscall.h>
#include <unistd.h>

int main(void)
{
  syscall(SYS_mmap, 0x20000000ul, 0x1000000ul, 7ul, 0x1012ul, -1, 0ul);

  *(uint64_t*)0x200000c0 = 0;
  syscall(SYS_cpuset_setaffinity, 2ul, 2ul, 0x100000000000000ul, 0x20ul,
          0x200000c0ul);
  return 0;
}
EOF
mycc -o /tmp/syzkaller30 -Wall -Wextra -O0 /tmp/syzkaller30.c ||
    exit 1

(cd /tmp; timeout 3m ./syzkaller30)

rm -rf /tmp/syzkaller30 syzkaller30.c /tmp/syzkaller.*
exit 0
