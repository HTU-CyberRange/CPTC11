# Exposed Prometheus Metrics Endpoint

## Summary
A Prometheus metrics endpoint is publicly accessible at http://10.0.1.10:9091/metrics without authentication, exposing sensitive application internals including memory statistics, goroutine counts, network traffic data, and custom ship control metrics. This information disclosure aids attackers in reconnaissance and understanding the application architecture.

## Title
Exposed Prometheus Metrics Endpoint

## CVSS
CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:L/VI:N/VA:N/SC:N/SI:N/SA:N
**Score: 6.9 (Medium)**

## Short Recommendation
Implement authentication for the metrics endpoint or restrict access to internal monitoring systems only via firewall rules or network segmentation.

## Affected Components
- **Address**: 10.0.1.10
- **Port**: 9091 (HTTP)
- **Component**: Prometheus metrics endpoint
- **Technology**: Go application with Prometheus client library

## Technical Description
The application exposes a Prometheus-compatible metrics endpoint at `/metrics` without authentication. This endpoint returns 9518 bytes of detailed application metrics in Prometheus exposition format, including:

**Runtime Metrics:**
- Go version (go1.24.5)
- Garbage collection statistics (720 GC cycles, 0.08s total pause time)
- Memory allocation details (869KB heap allocated, 11.4MB heap system)
- Goroutine count (49 goroutines)
- Thread count (8 OS threads)

**Process Metrics:**
- CPU time (312.04 seconds total)
- Network traffic (89.9MB received, 70.1MB transmitted)
- Memory usage (12.2MB resident, 1.26GB virtual)
- File descriptor usage (48 open FDs, 524287 max)
- Process start time (timestamp: 1767886723)

**Custom Application Metrics:**
- Ship stability metrics (metacentric height: 1.9)
- Tank levels (4 tanks at 5000 liters each)
- Pump health status (all 4 pumps showing status 0 - broken/offline)
- Ship pitch and list angles (both 0 degrees)

This level of detail provides attackers with:
- Application architecture and technology stack
- Runtime performance characteristics
- Resource consumption patterns
- Custom business logic details (ship control system)
- Version information for targeted exploits

## Evidence

**Discovery Command:**
```bash
curl -i http://10.0.1.10:9091/metrics
```

**Results (excerpt):**
```
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.24.5"} 1

# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 49

# HELP process_network_receive_bytes_total Number of bytes received by the process over the network.
# TYPE process_network_receive_bytes_total counter
process_network_receive_bytes_total 8.9976865e+07

# HELP ship_pump_health 0 = Broken, 1 = OK
# TYPE ship_pump_health gauge
ship_pump_health{pump="aft"} 0
ship_pump_health{pump="fore"} 0
ship_pump_health{pump="port"} 0
ship_pump_health{pump="starboard"} 0

# HELP ship_tank_level_liters Current water level in tanks
# TYPE ship_tank_level_liters gauge
ship_tank_level_liters{tank="aft"} 5000
ship_tank_level_liters{tank="fore"} 5000
```

[Full metrics output stored in evidence file]

## Proof of Concept Commands

**Access Method:**
```bash
# Access metrics endpoint
curl http://10.0.1.10:9091/metrics
```

**Expected Result:** 9518 bytes of Prometheus metrics returned without authentication

**Verify Exposure:**
```bash
# Check if endpoint is accessible from external network
curl http://10.0.1.10:9091/metrics | grep -E 'go_info|process_network|ship_'
```

**Extract Sensitive Info:**
```bash
# Extract Go version
curl -s http://10.0.1.10:9091/metrics | grep 'go_info{version'

# Extract network traffic stats
curl -s http://10.0.1.10:9091/metrics | grep 'process_network'

# Extract custom application metrics
curl -s http://10.0.1.10:9091/metrics | grep 'ship_'
```

## Recommendation

**Immediate (Within 24 Hours):**
- Add firewall rule to restrict access to 10.0.1.10:9091 from external networks:
  ```bash
  # Allow only internal monitoring subnet
  iptables -A INPUT -p tcp --dport 9091 -s 10.0.1.0/24 -j ACCEPT
  iptables -A INPUT -p tcp --dport 9091 -j DROP
  ```
- Or add basic authentication to metrics endpoint:
  ```go
  http.Handle("/metrics", basicAuth(promhttp.Handler()))
  ```

**Urgent (Within 1 Week):**
- Implement proper authentication for metrics endpoint (OAuth, API keys, mTLS)
- Network segmentation: Move metrics endpoint to internal management network
- Configure reverse proxy with authentication (nginx, haproxy)
- Review and reduce metrics exposure - remove sensitive custom metrics if not needed
- Add rate limiting to prevent metric scraping abuse

**Short-term:**
- Implement IP allowlisting for known Prometheus/monitoring servers
- Enable HTTPS for metrics endpoint with valid certificate
- Add monitoring/alerting for unusual metrics endpoint access patterns
- Regular audit of exposed metrics for sensitive information

**Long-term:**
- Service mesh with mTLS for all monitoring endpoints
- Centralized metrics collection with proper access controls
- Regular security reviews of exposed endpoints
- Implement metrics data classification (public, internal, confidential)

## References
- OWASP Top 10 2021: A01:2021 - Broken Access Control
- CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
- CWE-548: Exposure of Information Through Directory Listing
- Prometheus Security Best Practices: https://prometheus.io/docs/operating/security/
- NIST SP 800-53: SC-8 (Transmission Confidentiality)

## Re-test Status
Not yet retested

## Re-test Notes
Retesting should verify:
1. Accessing `http://10.0.1.10:9091/metrics` from external network returns 401/403 or connection refused
2. Authentication required to access metrics endpoint
3. Only authorized monitoring systems can access /metrics
4. Network firewall blocks external access to port 9091
5. If accessible, verify sensitive custom metrics removed or redacted

**Test Command:**
```bash
curl -i http://10.0.1.10:9091/metrics
```

**Expected After Fix:**
- Connection timeout (firewall blocked), OR
- 401 Unauthorized (authentication required), OR
- 403 Forbidden (access denied)

## Impact

**Confidentiality (MEDIUM):** Information disclosure enables reconnaissance:
- **Technology fingerprinting**: Go 1.24.5 - attackers can search for version-specific vulnerabilities
- **Architecture mapping**: 49 goroutines, 8 threads reveals application structure
- **Traffic analysis**: 89.9MB received, 70.1MB transmitted - understand usage patterns
- **Business logic exposure**: Ship ballast control system with 4 pumps and 4 tanks
- **Operational status**: All pumps showing broken status (0) - reveals system health issues
- **Resource capacity**: Memory limits, CPU usage helps plan DoS attacks
- **Process uptime**: Start time reveals patch/reboot schedule

**Integrity (NONE):** Read-only endpoint, no direct integrity impact.

**Availability (LOW):**
- Metrics data helps attackers plan resource exhaustion attacks
- Knowing goroutine/thread counts aids in crafting targeted DoS
- Understanding GC patterns helps optimize attack timing

**Business Impact:**
- **Competitive intelligence**: Custom "ship" metrics reveal business domain and application purpose
- **Attack surface mapping**: Clear understanding of application architecture
- **Security posture assessment**: Exposed debug endpoint suggests poor security hygiene
- **Operational exposure**: Broken pump status (all showing 0) indicates system reliability issues

**Attack Scenarios:**

**Scenario 1: Reconnaissance for Targeted Attack**
1. Attacker discovers metrics endpoint via port scan
2. Extracts Go version (1.24.5)
3. Searches for known vulnerabilities in Go 1.24.5
4. Identifies memory/concurrency bugs to exploit
5. Uses goroutine count and memory stats to craft exploit

**Scenario 2: Denial of Service Planning**
1. Monitor metrics over time to understand baseline performance
2. Identify GC pause patterns and memory pressure points
3. Note file descriptor limits (524287 max, 48 currently used)
4. Craft attack to exhaust file descriptors or trigger memory pressure
5. Time attack during high goroutine count periods

**Scenario 3: Business Logic Exploitation**
1. Discover custom ship metrics exposing ballast system
2. Understand system has 4 pumps, 4 tanks, stability metrics
3. Identify all pumps showing "broken" status
4. Search for ship control APIs to manipulate tank levels
5. Exploit pump control to destabilize ship (if control APIs exist)

**Scenario 4: Long-term Monitoring**
1. Script periodic metrics collection
2. Build profile of application behavior patterns
3. Identify maintenance windows (low traffic periods)
4. Detect system updates/patches via process restart times
5. Plan attacks during vulnerable windows

**Likelihood:** HIGH - Endpoint is publicly accessible with no authentication. Any attacker can access metrics with a simple HTTP GET request. Discovery takes seconds via automated port scanning.

**Real-World Comparison:**
Similar to CVE-2019-3826 (Prometheus metrics exposure in various platforms), this finding demonstrates how operational monitoring endpoints become attack vectors when exposed without authentication. Organizations like Kubernetes, Docker, and cloud providers all implement strict authentication for metrics endpoints for this reason.
