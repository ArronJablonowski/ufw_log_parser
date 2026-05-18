#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$script_dir/.." && pwd)
parser="$repo_dir/ufw_log_parser.sh"
fixture="$script_dir/fixtures/ufw.log"

export UFW_LOG_PARSER_IFACE_MACS='eth0=de:ad:be:ef:00:01'

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

assert_equal() {
    local expected=$1
    local actual=$2
    local label=$3

    if ! diff -u "$expected" "$actual"; then
        printf 'FAIL: %s\n' "$label" >&2
        exit 1
    fi
    printf 'ok: %s\n' "$label"
}

bash -n "$parser"

"$parser" "$fixture" > "$tmp_dir/text.out"
assert_equal "$script_dir/expected_text.txt" "$tmp_dir/text.out" "text output"

"$parser" --text - < "$fixture" > "$tmp_dir/stdin.out"
assert_equal "$script_dir/expected_text.txt" "$tmp_dir/stdin.out" "stdin output"

"$parser" --jsonl "$fixture" > "$tmp_dir/events.jsonl"
line_count=$(wc -l < "$tmp_dir/events.jsonl" | tr -d ' ')
[[ "$line_count" == "5" ]] || { printf 'FAIL: expected 5 JSONL events, got %s\n' "$line_count" >&2; exit 1; }
grep -q '"event":"ICMP"' "$tmp_dir/events.jsonl" || { printf 'FAIL: missing ICMP JSONL event\n' >&2; exit 1; }
grep -q '"src_mac":"unknown"' "$tmp_dir/events.jsonl" || { printf 'FAIL: missing unknown MAC JSONL event\n' >&2; exit 1; }
grep -q '"src_mac":"de:ad:be:ef:00:01"' "$tmp_dir/events.jsonl" || { printf 'FAIL: missing outbound local MAC JSONL event\n' >&2; exit 1; }
printf 'ok: jsonl output\n'

"$parser" --csv "$fixture" > "$tmp_dir/events.csv"
head -n 1 "$tmp_dir/events.csv" | grep -q '^timestamp,action,interface_in' || { printf 'FAIL: missing CSV header\n' >&2; exit 1; }
grep -q '"ICMP"' "$tmp_dir/events.csv" || { printf 'FAIL: missing ICMP CSV event\n' >&2; exit 1; }
printf 'ok: csv output\n'
