# 10.0.1.10 - Climate and Ballast Control

Industrial control host for onboard systems. Listed as a development environment in the
scope, but it exposes control interfaces over plain TCP with no or weak authentication.

## Services

| Port | Service | Notes |
|------|---------|-------|
| 6768 | Lido Deck Climate Control | Custom text protocol, no authentication |
| 9000 | Ballast Control System | Custom text protocol, weak default login |
| 9091 | Go HTTP API | Prometheus metrics exposed |

## What was found

- Unauthenticated climate control (Critical). The climate service on port 6768 needs no
  login and its SET command accepts an out of range value. The reported setpoint reads
  about 1e32 degrees Celsius, an integer overflow. Unsafe control of a physical system
  is a safety risk. See `enumeration/climate-control-status.txt` and
  `evidence/climate-overflow-exploitation/`.
- Ballast control default credentials (Critical). The ballast service on port 9000 logs
  in with `guest:guest` at role level 1, which exposes STATUS and other commands. Higher
  privilege actions such as SET return "Engineers only". See
  `evidence/ballast-exploitation/SUCCESS-guest-guest-20260110-145736.txt` and
  `evidence/ballast-exploitation/SUCCESSFUL_CREDENTIALS.txt`.
- Exposed Prometheus metrics (Medium and Info). The Go API on port 9091 serves `/metrics`
  without authentication.

## Layout

- `enumeration/` Protocol banners and command responses for both services.
- `evidence/ballast-exploitation/` Login attempts, credential brute results, and the
  successful `guest:guest` session.
- `evidence/climate-overflow-exploitation/` Overflow and input tests against the SET command.
- `scripts/` Test and exploit scripts for both services.
