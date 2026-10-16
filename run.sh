#!/bin/bash
# Synthesis (DC) + place & route (ICC2) of rtl/mac.v. Results land in ./work
set -e
ROOT=$(cd "$(dirname "$0")" && pwd)
source $ROOT/setup.sh
mkdir -p $ROOT/work && cd $ROOT/work

echo "== synthesis";     dc_shell   -f $ROOT/scripts/syn.tcl < /dev/null > syn.log 2>&1
echo "== place & route"; icc2_shell -f $ROOT/scripts/pnr.tcl < /dev/null > pnr.log 2>&1
grep -q PNR_DONE pnr.log || { echo "P&R failed, see work/pnr.log"; exit 1; }
echo "== done: reports in work/rpt, netlist/DEF in work/out"
