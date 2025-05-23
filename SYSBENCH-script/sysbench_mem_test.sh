#!/bin/bash

# Define custom output directory
RESULT_DIR="/home/sysbench_tests/mem_results"

# Create it if it doesn't exist
mkdir -P "$RESULT_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# CSV filenames with full path
CSV_READ="$RESULT_DIR/sysbench_mem_read_$TIMESTAMP.csv"
CSV_WRITE="$RESULT_DIR/sysbench_mem_write_$TIMESTAMP.csv"

# Iterations
ITERATIONS=5

# Sysbench Memory Test Parameters
MEM_BLOCKSIZE=""
MEM_TOTALSIZE=""

# --- Memory READ test ---
echo "Creating results file: $CSV_READ"
echo "Iteration,Operation,Threads,Block Size,Total Size,Operations/sec,Transferred (MB/sec)" > "$CSV_READ"

for i in $(seq 1 $ITERATIONS); do
    echo "Running memory READ test iteration $i..."

    OUTPUT=$(sysbench memory --memory-block-size=$MEM_BLOCKSIZE --memory-total-size=$MEM_TOTALSIZE --memory-access-mode=seq --memory-oper=read --threads=1 run)

    ops_sec=$(echo "$OUTPUT" | grep "Operations performed" | awk '{print $3}' | tr -d '()')
    mb_sec=$(echo "$OUTPUT" | grep "transferred" | awk '{print $1}')

    echo "$i,read,$THREADS,$MEM_BLOCKSIZE,$MEM_TOTALSIZE,$ops_sec,$mb_sec" >> "$CSV_READ"
done

# --- Memory WRITE test ---
echo "Creating results file: $CSV_WRITE"
echo "Iteration,Operation,Threads,Block Size,Total Size,Operations/sec,Transferred (MB/sec)" > "$CSV_WRITE"

for i in $(seq 1 $ITERATIONS); do
    echo "Running memory WRITE test iteration $i..."

    OUTPUT=$(sysbench memory --memory-block-size=$MEM_BLOCKSIZE --memory-total-size=$MEM_TOTALSIZE --memory-access-mode=seq --memory-oper=write --threads=1 run)

    ops_sec=$(echo "$OUTPUT" | grep "Operations performed" | awk '{print $3}' | tr -d '()')
    mb_sec=$(echo "$OUTPUT" | grep "transferred" | awk '{print $1}')

    echo "$i,write,$THREADS,$MEM_BLOCKSIZE,$MEM_TOTALSIZE,$ops_sec,$mb_sec" >> "$CSV_WRITE"
done

echo "Done!"
echo "Memory READ results:  $CSV_READ"
echo "Memory WRITE results: $CSV_WRITE"