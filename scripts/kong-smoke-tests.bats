#!/usr/bin/env bats

# Variables
KONG_HOST=${KONG_HOST:-"localhost"}
KONG_PROXY="http://$KONG_HOST:8000"
KONG_STATUS="http://$KONG_HOST:8100"
TEST_ROUTE_PATH="/test"
TEST_AUTH_PATH="/auth"

# Function to perform a curl request and return the response code
get_response_code() {
    curl -s -o /dev/null -w "%{http_code}" "$1"
}

@test "Health Check for Gateway Ports" {
    if ! command -v nc &> /dev/null; then
        skip "nc (netcat) is not installed. Skipping port check."
    fi

    for port in 8000 8100 8443; do
        nc -zv "$KONG_HOST" "$port" &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Port $port is open and listening."
        else
            echo "Port $port is closed!"
            false  # Mark test as failed
        fi
    done
}


@test "Status endpoint Functionality Test" {
    status_response_code=$(get_response_code "$KONG_STATUS/status/ready")
    [ "$status_response_code" -eq 200 ]
}

@test "Basic Proxy Functionality Test" {
    proxy_response_code=$(get_response_code "$KONG_PROXY$TEST_ROUTE_PATH")
    [ "$proxy_response_code" -eq 200 ]
}


@test "HTTPS Request Test" {
    response_code=$(curl -sk -o /dev/null -w "%{http_code}" https://$KONG_HOST:8443$TEST_ROUTE_PATH)
    [ "$response_code" -eq 200 ]
}

@test "Plugin Verification (Key-Auth)" {
    auth_response_code=$(get_response_code "$KONG_PROXY$TEST_AUTH_PATH")
    [ "$auth_response_code" -eq 401 ]
}

@test "Plugin Verification (Rate-Limiting-Advanced)" {
    rate_limit_exceeded=false
    for i in {1..10}; do
        response_code=$(get_response_code "$KONG_PROXY$TEST_ROUTE_PATH")
        if [ "$response_code" -eq 429 ]; then
            rate_limit_exceeded=true
            break
        fi
    done
    [ "$rate_limit_exceeded" = true ]
}


@test "Log and Metrics Verification" {
    output=$(curl -s "$KONG_STATUS/metrics" | grep "kong_nginx_requests_total" || true)
    [ -n "$output" ]
}


@test "Basic Error Handling Test" {
    error_response_code=$(get_response_code "$KONG_PROXY/invalid-route")
    [ "$error_response_code" -eq 404 ]
}
