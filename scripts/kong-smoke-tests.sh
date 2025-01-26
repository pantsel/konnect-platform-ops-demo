#!/bin/bash

# Exit on error
set -e

# Variables
KONG_HOST=${1:-"localhost"}
KONG_PROXY="http://$KONG_HOST:8000"
KONG_STATUS="http://$KONG_HOST:8100"
TEST_ROUTE_PATH="/test"
TEST_AUTH_PATH="/auth"
# KONG_CONTAINER=$2
REPORT_FILE=$2

# Function to print test status
print_status() {
    echo -e "\n===== $1 ====="
}

# 1. Health Check for Gateway Ports
print_status "Health Check for Gateway Ports"
for port in 8000 8100 8443; do
    nc -zv $KONG_HOST $port && echo "Port $port is open and listening."
done

# 2. Status endpoint Functionality Test
print_status "Status endpoint Functionality Test"
status_response_code=$(curl -s -o /dev/null -w "%{http_code}" "$KONG_STATUS/status/ready")
if [ "$status_response_code" -eq 200 ]; then
    echo "Status endpoint functionality verified successfully."
else
    echo "Status endpoint test failed. Expected 200, got $status_response_code."
    exit 1
fi

# 3. Basic Proxy Functionality Test
print_status "Basic Proxy Functionality Test"

# Test the route
proxy_response_code=$(curl -s -o /dev/null -w "%{http_code}" "$KONG_PROXY$TEST_ROUTE_PATH")
if [ "$proxy_response_code" -eq 200 ]; then
    echo "Proxy functionality verified successfully."
else
    echo "Proxy functionality test failed. Expected 200, got $proxy_response_code."
    exit 1
fi

# 4. Plugin Verification (Key-Auth)
print_status "Plugin Verification (Key-Auth)"
# Test the route without the API key (should fail)
auth_response_code=$(curl -s -o /dev/null -w "%{http_code}" "$KONG_PROXY$TEST_AUTH_PATH")
if [ "$auth_response_code" -eq 401 ]; then
    echo "Key-Auth plugin is enforcing authentication as expected (401 Unauthorized)."
else
    echo "Key-Auth plugin test failed. Expected 401, got $auth_response_code."
    exit 1
fi

# 5. Plugin Verification (Rate-Limiting)
print_status "Plugin Verification (Rate-Limiting-Advanced)"

# Test rate-limiting plugin
rate_limit_exceeded=false
for i in {1..10}; do
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$KONG_PROXY$TEST_ROUTE_PATH")
    if [ "$response_code" -eq 429 ]; then
        rate_limit_exceeded=true
        break
    fi
done

if [ "$rate_limit_exceeded" = true ]; then
    echo "Rate-limiting plugin is working as expected."
else
    echo "Rate-limiting plugin test failed."
    exit 1
fi

# 6. TLS/SSL Verification (If Configured)
print_status "TLS/SSL Verification"
curl -sk https://$KONG_HOST:8443/$TEST_ROUTE_PATH
echo "SSL/TLS check passed."

# 7. Log and Metrics Verification
print_status "Log and Metrics Verification"
curl -s "$KONG_STATUS/metrics" | grep "kong_nginx_requests_total"
echo "Metrics endpoint is accessible."

# 8. Basic Error Handling Test
print_status "Basic Error Handling Test"
error_response_code=$(curl -s -o /dev/null -w "%{http_code}" "$KONG_PROXY/invalid-route")
if [ "$error_response_code" -eq 404 ]; then
    echo "Error handling test passed (404 Not Found)."
else
    echo "Error handling test failed. Expected 404, got $error_response_code."
    exit 1
fi

echo -e "\nAll smoke tests passed successfully."
# Generate a report of the smoke tests in markdown format

echo "# Kong Smoke Test Report" > $REPORT_FILE
echo "Date: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Function to append test result to the report
append_to_report() {
    echo "| $1 | $2 |" >> $REPORT_FILE
}

# Table header
echo "| Test | Result |" >> $REPORT_FILE
echo "|------|--------|" >> $REPORT_FILE

# 1. Health Check for Gateway Ports
append_to_report "Health Check for Gateway Ports" "Passed"

# 2. Status endpoint Functionality Test
if [ "$status_response_code" -eq 200 ]; then
    append_to_report "Status endpoint Functionality Test" "Passed"
else
    append_to_report "Status endpoint Functionality Test" "Failed"
fi

# 3. Basic Proxy Functionality Test
if [ "$proxy_response_code" -eq 200 ]; then
    append_to_report "Basic Proxy Functionality Test" "Passed"
else
    append_to_report "Basic Proxy Functionality Test" "Failed"
fi

# 4. Plugin Verification (Key-Auth)
if [ "$auth_response_code" -eq 401 ]; then
    append_to_report "Plugin Verification (Key-Auth)" "Passed"
else
    append_to_report "Plugin Verification (Key-Auth)" "Failed"
fi

# 5. Plugin Verification (Rate-Limiting)
if [ "$rate_limit_exceeded" = true ]; then
    append_to_report "Plugin Verification (Rate-Limiting-Advanced)" "Passed"
else
    append_to_report "Plugin Verification (Rate-Limiting-Advanced)" "Failed"
fi

# 6. TLS/SSL Verification (If Configured)
append_to_report "TLS/SSL Verification" "Passed"

# 7. Log and Metrics Verification
append_to_report "Log and Metrics Verification" "Passed"

# 8. Basic Error Handling Test
if [ "$error_response_code" -eq 404 ]; then
    append_to_report "Basic Error Handling Test" "Passed"
else
    append_to_report "Basic Error Handling Test" "Failed"
fi

echo "Smoke test report generated: $REPORT_FILE"