#!/bin/bash

set -euo pipefail

# Define custom output directory

read -p "Masukkan jumlah vm yang berjalan: " VM_COUNT
read -p "Masukkan nama instance: " INSTANCE_NAME

RESULT_DIR="/home/sysbench_tests/cpu_results"

# Create it if it doesn't exist
mkdir -p "$RESULT_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# CSV filenames with full path
# CSV_SINGLE="$RESULT_DIR/sysbench_cpu_single_$TIMESTAMP.csv"
# CSV_MULTI="$RESULT_DIR/sysbench_cpu_multi_$TIMESTAMP.csv"

CSV_SINGLE="$RESULT_DIR/sysbench_cpu_single_'$TIMESTAMP'_'$VM_COUNT'_'$INSTANCE_NAME'.csv"
CSV_MULTI="$RESULT_DIR/sysbench_cpu_multi_$TIMESTAMP_'$VM_COUNT'_'$INSTANCE_NAME'.csv"

# Iterations
ITERATIONS=10

# Sysbench CPU Test Parameters
MAX_PRIME=10000
SINGLE_THREAD=1
MULTI_THREAD=$(nproc)

# Single-thread test
echo "Creating results file: $CSV_SINGLE"
echo "Iteration,Threads,Total Time (s),Events/sec,Latency Avg (ms),Latency 95th (ms),Latency Max (ms)" > "$CSV_SINGLE"

for i in $(seq 1 $ITERATIONS); do
    echo "Running single-thread test $i..."
    
    OUTPUT=$(sysbench cpu --cpu-max-prime=$MAX_PRIME --threads=1 run)

    total_time=$(echo "$OUTPUT" | grep "total time:" | awk '{print $3}')
    events_sec=$(echo "$OUTPUT" | grep "events per second:" | awk '{print $4}')
    latency_avg=$(echo "$OUTPUT" | grep "avg:" | awk '{print $2}')
    latency_95th=$(echo "$OUTPUT" | grep "95th percentile:" | awk '{print $3}')
    latency_max=$(echo "$OUTPUT" | grep "max:" | awk '{print $2}')

    echo "$i,1,$total_time,$events_sec,$latency_avg,$latency_95th,$latency_max" >> "$CSV_SINGLE"
done

# Multi-thread test
echo "Creating results file: $CSV_MULTI"
echo "Iteration,Threads,Total Time (s),Events/sec,Latency Avg (ms),Latency 95th (ms),Latency Max (ms)" > "$CSV_MULTI"

for i in $(seq 1 $ITERATIONS); do
    echo "Running multi-thread test $i with $MULTI_THREAD threads..."

    OUTPUT=$(sysbench cpu --cpu-max-prime=$MAX_PRIME --threads=$MULTI_THREAD run)

    total_time=$(echo "$OUTPUT" | grep "total time:" | awk '{print $3}')
    events_sec=$(echo "$OUTPUT" | grep "events per second:" | awk '{print $4}')
    latency_avg=$(echo "$OUTPUT" | grep "avg:" | awk '{print $2}')
    latency_95th=$(echo "$OUTPUT" | grep "95th percentile:" | awk '{print $3}')
    latency_max=$(echo "$OUTPUT" | grep "max:" | awk '{print $2}')

    echo "$i,$MULTI_THREAD,$total_time,$events_sec,$latency_avg,$latency_95th,$latency_max" >> "$CSV_MULTI"
done

echo "Done!"
echo "Single-thread results: $CSV_SINGLE"
echo "Multi-thread results:  $CSV_MULTI"