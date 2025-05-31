#!/bin/bash

set -euo pipefail

read -p "Masukkan jumlah vm yang berjalan: " VM_COUNT
read -p "Masukkan nama instance: " INSTANCE_NAME

# Define custom output directory
RESULT_DIR="/home/sysbench_tests/mem_results_${VM_COUNT}_${INSTANCE_NAME}"

# Create it if it doesn't exist
mkdir -p "$RESULT_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# CSV filenames with full path
CSV_READ="$RESULT_DIR/sysbench_mem_read_${TIMESTAMP}_${VM_COUNT}_${INSTANCE_NAME}.csv"
CSV_WRITE="$RESULT_DIR/sysbench_mem_write_${TIMESTAMP}_${VM_COUNT}_${INSTANCE_NAME}.csv"

# Iterations
ITERATIONS=10

# Sysbench Memory Test Parameters
MEM_BLOCKSIZE=32M
MEM_TOTALSIZE=100G
THREADS=$(nproc)

# --- Memory READ test ---
echo "Creating results file: $CSV_READ"
echo "Iteration,Operation,Block Size,Total Size,Operations/sec,Transferred (MB/sec)" > "$CSV_READ"

for i in $(seq 1 $ITERATIONS); do
    echo "Running memory READ test iteration $i..."

    OUTPUT=$(sysbench memory --memory-block-size=$MEM_BLOCKSIZE --memory-total-size=$MEM_TOTALSIZE --memory-access-mode=seq --memory-oper=read --threads=$THREADS run)

    ops_sec=$(echo "$OUTPUT" | grep "Total operations:" | awk '{print $5}' | tr -d '()')
    mb_sec=$(echo "$OUTPUT" | grep "transferred" | awk '{print $4}' | tr -d '()')

    echo "$i,read,$MEM_BLOCKSIZE,$MEM_TOTALSIZE,$ops_sec,$mb_sec" >> "$CSV_READ"
done

# --- Memory WRITE test ---
echo "Creating results file: $CSV_WRITE"
echo "Iteration,Operation,Block Size,Total Size,Operations/sec,Transferred (MB/sec)" > "$CSV_WRITE"

for i in $(seq 1 $ITERATIONS); do
    echo "Running memory WRITE test iteration $i..."

    OUTPUT=$(sysbench memory --memory-block-size=$MEM_BLOCKSIZE --memory-total-size=$MEM_TOTALSIZE --memory-access-mode=seq --memory-oper=write --threads=$THREADS run)

    ops_sec=$(echo "$OUTPUT" | grep "Total operations:" | awk '{print $5}' | tr -d '()')
    mb_sec=$(echo "$OUTPUT" | grep "transferred" | awk '{print $4}' | tr -d '()')

    echo "$i,write,$MEM_BLOCKSIZE,$MEM_TOTALSIZE,$ops_sec,$mb_sec" >> "$CSV_WRITE"
done

echo "Done!"
echo "Memory READ results:  $CSV_READ"
echo "Memory WRITE results: $CSV_WRITE"
