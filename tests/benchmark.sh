#!/bin/bash

# Number of test runs
num_tests=10

# Initialize accumulators for each workload type
rand_read_iops=0
rand_read_bw=0
rand_read_latency=0

rand_write_iops=0
rand_write_bw=0
rand_write_latency=0

seq_read_iops=0
seq_read_bw=0
seq_read_latency=0

seq_write_iops=0
seq_write_bw=0
seq_write_latency=0

echo "Starting fio benchmark with $num_tests runs for each workload type..."

for i in $(seq 1 $num_tests); do
    echo "Run $i: Running fio benchmark"
    # Run fio for all jobs in the config file
    output=$(fio /fio-benchmark.fio --output-format=json)

    # Extract random read metrics
    rand_read_iops=$(echo "$output" | jq '.jobs[] | select(.jobname=="random-read").read.iops')
    rand_read_bw_kib=$(echo "$output" | jq '.jobs[] | select(.jobname=="random-read").read.bw')
    rand_read_bw=$(echo "scale=2; $rand_read_bw_kib / 1024" | bc)
    rand_read_latency=$(echo "$output" | jq '.jobs[] | select(.jobname=="random-read").read.latency.mean')

    # Extract random write metrics
    rand_write_iops=$(echo "$output" | jq '.jobs[] | select(.jobname=="random-write").write.iops')
    rand_write_bw_kib=$(echo "$output" | jq '.jobs[] | select(.jobname=="random-write").write.bw')
    rand_write_bw=$(echo "scale=2; $rand_write_bw_kib / 1024" | bc)
    rand_write_latency=$(echo "$output" | jq '.jobs[] | select(.jobname=="random-write").write.latency.mean')

    # Extract sequential read metrics
    seq_read_iops=$(echo "$output" | jq '.jobs[] | select(.jobname=="seq-read").read.iops')
    seq_read_bw_kib=$(echo "$output" | jq '.jobs[] | select(.jobname=="seq-read").read.bw')
    seq_read_bw=$(echo "scale=2; $seq_read_bw_kib / 1024" | bc)
    seq_read_latency=$(echo "$output" | jq '.jobs[] | select(.jobname=="seq-read").read.latency.mean')

    # Extract sequential write metrics
    seq_write_iops=$(echo "$output" | jq '.jobs[] | select(.jobname=="seq-write").write.iops')
    seq_write_bw_kib=$(echo "$output" | jq '.jobs[] | select(.jobname=="seq-write").write.bw')
    seq_write_bw=$(echo "scale=2; $seq_write_bw_kib / 1024" | bc)
    seq_write_latency=$(echo "$output" | jq '.jobs[] | select(.jobname=="seq-write").write.latency.mean')

    # Accumulate metrics
    rand_read_iops=$(echo "$rand_read_iops + $rand_read_iops" | bc)
    rand_read_bw=$(echo "$rand_read_bw + $rand_read_bw" | bc)
    rand_read_latency=$(echo "$rand_read_latency + $rand_read_latency" | bc)

    rand_write_iops=$(echo "$rand_write_iops + $rand_write_iops" | bc)
    rand_write_bw=$(echo "$rand_write_bw + $rand_write_bw" | bc)
    rand_write_latency=$(echo "$rand_write_latency + $rand_write_latency" | bc)

    seq_read_iops=$(echo "$seq_read_iops + $seq_read_iops" | bc)
    seq_read_bw=$(echo "$seq_read_bw + $seq_read_bw" | bc)
    seq_read_latency=$(echo "$seq_read_latency + $seq_read_latency" | bc)

    seq_write_iops=$(echo "$seq_write_iops + $seq_write_iops" | bc)
    seq_write_bw=$(echo "$seq_write_bw + $seq_write_bw" | bc)
    seq_write_latency=$(echo "$seq_write_latency + $seq_write_latency" | bc)
done

# Calculate averages for each workload type
avg_rand_read_iops=$(echo "$rand_read_iops / $num_tests" | bc)
avg_rand_read_bw=$(echo "$rand_read_bw / $num_tests" | bc)
avg_rand_read_latency=$(echo "$rand_read_latency / $num_tests" | bc)

avg_rand_write_iops=$(echo "$rand_write_iops / $num_tests" | bc)
avg_rand_write_bw=$(echo "$rand_write_bw / $num_tests" | bc)
avg_rand_write_latency=$(echo "$rand_write_latency / $num_tests" | bc)

avg_seq_read_iops=$(echo "$seq_read_iops / $num_tests" | bc)
avg_seq_read_bw=$(echo "$seq_read_bw / $num_tests" | bc)
avg_seq_read_latency=$(echo "$seq_read_latency / $num_tests" | bc)

avg_seq_write_iops=$(echo "$seq_write_iops / $num_tests" | bc)
avg_seq_write_bw=$(echo "$seq_write_bw / $num_tests" | bc)
avg_seq_write_latency=$(echo "$seq_write_latency / $num_tests" | bc)

# Print summary
echo "========== Benchmark Summary =========="
echo "Random Read:"
echo "  Average IOPS: $avg_rand_read_iops"
echo "  Average Bandwidth: $avg_rand_read_bw MiB/sec"
echo "  Average Latency: $avg_rand_read_latency µs"

echo "Random Write:"
echo "  Average IOPS: $avg_rand_write_iops"
echo "  Average Bandwidth: $avg_rand_write_bw MiB/sec"
echo "  Average Latency: $avg_rand_write_latency µs"

echo "Sequential Read:"
echo "  Average IOPS: $avg_seq_read_iops"
echo "  Average Bandwidth: $avg_seq_read_bw MiB/sec"
echo "  Average Latency: $avg_seq_read_latency µs"

echo "Sequential Write:"
echo "  Average IOPS: $avg_seq_write_iops"
echo "  Average Bandwidth: $avg_seq_write_bw MiB/sec"
echo "  Average Latency: $avg_seq_write_latency µs"