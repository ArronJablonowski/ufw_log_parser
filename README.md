# ufw_log_parser.sh

`ufw_log_parser.sh` parses Uncomplicated Firewall logs into readable text, JSON Lines, or CSV for troubleshooting and incident response.

It extracts:

* Timestamp
* UFW action: block, allow, or audit
* Input and output interfaces
* Source MAC and IP
* Destination IP and port
* Source port
* Protocol
* Event type, including TCP/UDP port traffic, mDNS, ICMP, ICMPv6, and generic packets
* Packet length and TTL when present

For local outbound traffic where UFW does not include `MAC=`, the parser resolves the outbound interface MAC address once at startup and uses it as the source MAC.

## UFW logging verbosity

UFW has 5 levels of verbosity:

* `off` - logging is disabled
* `low` - logs blocked packets that do not match the current firewall ruleset, rate limited
* `medium` - all logs from `low`, plus invalid packets and new connection/allows, rate limited
* `high` - all logs from `medium` with less rate limiting
* `full` - similar to `high` without rate limits

For a Unix workstation, `medium` is often a useful starting point. It may be too verbose on some servers.

```bash
sudo ufw logging medium
```

## Usage

Parse the default UFW log:

```bash
./ufw_log_parser.sh
```

Parse a specific log file:

```bash
./ufw_log_parser.sh /var/log/ufw.log
```

Parse only recent entries. This is faster than parsing the entire file and then piping the parser output to `tail`:

```bash
tail -n 30 /var/log/ufw.log | ./ufw_log_parser.sh -
```

Watch a running feed:

```bash
tail -F /var/log/ufw.log | ./ufw_log_parser.sh -
```

Emit JSON Lines for `jq`, enrichment scripts, or SIEM ingestion:

```bash
tail -F /var/log/ufw.log | ./ufw_log_parser.sh --jsonl -
```

Emit CSV:

```bash
./ufw_log_parser.sh --csv /var/log/ufw.log
```

Show all options:

```bash
./ufw_log_parser.sh --help
```

## Output formats

Default text output is intended for terminals:

```text
[ May 18 12:00:01 ] [ !BLOCK! ] [ src-mac: 11:22:33:44:55:66 192.0.2.5 --X 192.0.2.10:22 TCP spt:51515 in:en0 ]
```

JSON Lines output is intended for tooling:

```json
{"timestamp":"May 18 12:00:01","action":"BLOCK","interface_in":"en0","interface_out":"","src_mac":"11:22:33:44:55:66","src_ip":"192.0.2.5","dst_ip":"192.0.2.10","src_port":"51515","dst_port":"22","protocol":"TCP","event":"port","length":"60","ttl":"64","raw":"..."}
```

## Performance notes

The parser uses one `awk` process and avoids spawning tools inside the per-line loop. For large logs, filter before parsing whenever you only need a small window:

```bash
tail -n 500 /var/log/ufw.log | ./ufw_log_parser.sh -
```

If you truly do not need historical logs, rotate or truncate the UFW log through your normal system administration process:

```bash
sudo truncate -s 0 /var/log/ufw.log
```

## Tests

Run the fixture-based test suite:

```bash
./tests/run_tests.sh
```

The tests cover text output, stdin parsing, JSON Lines, CSV, mDNS, loopback traffic, and blocked ICMP packets without a MAC address.
They also cover outbound local traffic where the source MAC is filled from the outbound interface.

## Example use cases

* Validate VLAN segmentation.
* Determine whether a route or service is reachable.
* Watch UFW while troubleshooting or performing incident response.
* Spot local multicast and discovery traffic.
* Review scan or probe attempts against a workstation or server.

![ufw_log_parser screenshot](https://github.com/ArronJablonowski/ufw_log_parser/blob/main/ufw_parser.png?raw=true)
