#!/bin/bash

set -euo pipefail

# Define custom output directory
RESULT_DIR="/home/sysbench_tests/mem_results"

# Create it if it doesn't exist
mkdir -p "$RESULT_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# CSV filenames with full path
CSV_READ="$RESULT_DIR/sysbench_mem_read_$TIMESTAMP.csv"
CSV_WRITE="$RESULT_DIR/sysbench_mem_write_$TIMESTAMP.csv"

# Iterations
ITERATIONS=10

# Sysbench Memory Test Parameters
MEM_BLOCKSIZE=4M
RAM_MB=$(free -m | awk '/^Mem:/ {print $2}')
MEM_TOTALSIZE=$((RAM_MB * 2))M

# --- Memory READ test ---
echo "Creating results file: $CSV_READ"
echo "Iteration,Operation,Block Size,Total Size,Operations/sec,Transferred (MB/sec)" > "$CSV_READ"

for i in $(seq 1 $ITERATIONS); do
    echo "Running memory READ test iteration $i..."

    OUTPUT=$(sysbench memory --memory-block-size=$MEM_BLOCKSIZE --memory-total-size=$MEM_TOTALSIZE --memory-access-mode=seq --memory-oper=read --threads=1 run)

    ops_sec=$(echo "$OUTPUT" | grep "Total operations:" | awk '{print $4}' | tr -d '()')
    mb_sec=$(echo "$OUTPUT" | grep "transferred" | awk '{print $4}' | tr -d '()')

    echo "$i,read,$MEM_BLOCKSIZE,$MEM_TOTALSIZE,$ops_sec,$mb_sec" >> "$CSV_READ"
done

# --- Memory WRITE test ---
echo "Creating results file: $CSV_WRITE"
echo "Iteration,Operation,Block Size,Total Size,Operations/sec,Transferred (MB/sec)" > "$CSV_WRITE"

for i in $(seq 1 $ITERATIONS); do
    echo "Running memory WRITE test iteration $i..."

    OUTPUT=$(sysbench memory --memory-block-size=$MEM_BLOCKSIZE --memory-total-size=$MEM_TOTALSIZE --memory-access-mode=seq --memory-oper=write --threads=1 run)

    ops_sec=$(echo "$OUTPUT" | grep "Total operations:" | awk '{print $4}' | tr -d '()')
    mb_sec=$(echo "$OUTPUT" | grep "transferred" | awk '{print $4}' | tr -d '()')

    echo "$i,write,$MEM_BLOCKSIZE,$MEM_TOTALSIZE,$ops_sec,$mb_sec" >> "$CSV_WRITE"
done

echo "Done!"
echo "Memory READ results:  $CSV_READ"
echo "Memory WRITE results: $CSV_WRITE"