#!/bin/bash
# ============================================================================
# run_all.sh —— 依次运行全部 4 个测试并汇总 PASS/FAIL
# 每个测试用独立的 -cm_name，simv.vdb 会累积合并 → urg 报告 = 4 测试总覆盖率
# ============================================================================
cd /home/yian/eda_sim/spi_uvm_sim

tests="spi_smoke_test spi_mode_test spi_rand_test spi_corner_test"
pass=0
fail=0
failed_list=""

for t in $tests; do
  echo ""
  echo "======================================================"
  echo ">>> Running $t"
  echo "======================================================"
  ./simv +UVM_TESTNAME=$t +UVM_VERBOSITY=UVM_MEDIUM +ntb_random_seed=1 \
    -cm line+cond+fsm+tgl+branch+assert -cm_name $t -l run_$t.log

  # 判定：日志必须存在、UVM 汇总 ERROR/FATAL 为 0、无 VCS 运行时错误
  if [ ! -f run_$t.log ] || grep -qE "UVM_(ERROR|FATAL) *: *[1-9]" run_$t.log || grep -qE "^Error-\[" run_$t.log; then
    echo ">>> $t : FAIL"
    fail=$((fail+1))
    failed_list="$failed_list $t"
  else
    echo ">>> $t : PASS"
    pass=$((pass+1))
  fi
done

echo ""
echo "========================================================"
echo "  SUMMARY: PASS=$pass  FAIL=$fail"
if [ $fail -eq 0 ]; then
  echo "  All tests PASSED!"
else
  echo "  Failed tests:$failed_list"
fi
echo "========================================================"
exit $fail
