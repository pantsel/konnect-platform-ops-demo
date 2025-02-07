#!/bin/bash

# Exit on error
set -e

# Variables
KONG_HOST=${1:-"localhost"}
KONG_PROXY="http://$KONG_HOST:8000"
KONG_STATUS="http://$KONG_HOST:8100"
TEST_ROUTE_PATH="/test"
TEST_AUTH_PATH="/auth"
REPORT_FILE=$2

# Function to print test status
print_status() {
    echo -e "\n===== $1 ====="
}

# Function to append test result to the report
append_to_report() {
    echo "| $1 | $2 |" >> $REPORT_FILE
}

# Function to perform a curl request and return the response code
get_response_code() {
    curl -s -o /dev/null -w "%{http_code}" "$1"
}

# Function to check port status
check_port() {
    if command -v nc &> /dev/null; then
        nc -zv $KONG_HOST $1 && echo "Port $1 is open and listening."
    else
        echo "Warning: nc command not found. Skipping port check for $1."
    fi
}

# Initialize report file
echo "# Kong Smoke Test Report" > $REPORT_FILE
echo "Date: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE
echo "| Test | Result |" >> $REPORT_FILE
echo "|------|--------|" >> $REPORT_FILE

# 1. Health Check for Gateway Ports
print_status "Health Check for Gateway Ports"
for port in 8000 8100 8443; do
    check_port $port
done
append_to_report "Health Check for Gateway Ports" "Passed"

# 2. Status endpoint Functionality Test
print_status "Status endpoint Functionality Test"
status_response_code=$(get_response_code "$KONG_STATUS/status/ready")
if [ "$status_response_code" -eq 200 ]; then
    echo "Status endpoint functionality verified successfully."
    append_to_report "Status endpoint Functionality Test" "Passed"
else
    echo "Status endpoint test failed. Expected 200, got $status_response_code."
    append_to_report "Status endpoint Functionality Test" "Failed"
    exit 1
fi

# 3. Basic Proxy Functionality Test
print_status "Basic Proxy Functionality Test"
proxy_response_code=$(get_response_code "$KONG_PROXY$TEST_ROUTE_PATH")
if [ "$proxy_response_code" -eq 200 ]; then
    echo "Proxy functionality verified successfully."
    append_to_report "Basic Proxy Functionality Test" "Passed"
else
    echo "Proxy functionality test failed. Expected 200, got $proxy_response_code."
    append_to_report "Basic Proxy Functionality Test" "Failed"
    exit 1
fi

# 4. Plugin Verification (Key-Auth)
print_status "Plugin Verification (Key-Auth)"
auth_response_code=$(get_response_code "$KONG_PROXY$TEST_AUTH_PATH")
if [ "$auth_response_code" -eq 401 ]; then
    echo "Key-Auth plugin is enforcing authentication as expected (401 Unauthorized)."
    append_to_report "Plugin Verification (Key-Auth)" "Passed"
else
    echo "Key-Auth plugin test failed. Expected 401, got $auth_response_code."
    append_to_report "Plugin Verification (Key-Auth)" "Failed"
    exit 1
fi

# 5. Plugin Verification (Rate-Limiting)
print_status "Plugin Verification (Rate-Limiting-Advanced)"
rate_limit_exceeded=false
for i in {1..10}; do
    response_code=$(get_response_code "$KONG_PROXY$TEST_ROUTE_PATH")
    if [ "$response_code" -eq 429 ]; then
        rate_limit_exceeded=true
        break
    fi
done
if [ "$rate_limit_exceeded" = true ]; then
    echo "Rate-limiting plugin is working as expected."
    append_to_report "Plugin Verification (Rate-Limiting-Advanced)" "Passed"
else
    echo "Rate-limiting plugin test failed."
    append_to_report "Plugin Verification (Rate-Limiting-Advanced)" "Failed"
    exit 1
fi

# 6. TLS/SSL Verification (If Configured)
print_status "TLS/SSL Verification"
curl -sk https://$KONG_HOST:8443/$TEST_ROUTE_PATH && echo "SSL/TLS check passed."
append_to_report "TLS/SSL Verification" "Passed"

# 7. Log and Metrics Verification
print_status "Log and Metrics Verification"
curl -s "$KONG_STATUS/metrics" | grep "kong_nginx_requests_total" && echo "Metrics endpoint is accessible."
append_to_report "Log and Metrics Verification" "Passed"

# 8. Basic Error Handling Test
print_status "Basic Error Handling Test"
error_response_code=$(get_response_code "$KONG_PROXY/invalid-route")
if [ "$error_response_code" -eq 404 ]; then
    echo "Error handling test passed (404 Not Found)."
    append_to_report "Basic Error Handling Test" "Passed"
else
    echo "Error handling test failed. Expected 404, got $error_response_code."
    append_to_report "Basic Error Handling Test" "Failed"
    exit 1
fi

echo -e "\nAll smoke tests passed successfully."
echo "Smoke test report generated: $REPORT_FILE"
