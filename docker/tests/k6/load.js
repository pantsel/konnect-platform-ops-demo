import http from 'k6/http';
import { sleep } from 'k6';

// Get command-line arguments
const args = JSON.parse(__ENV.K6_OPTIONS || '{}');
const vus = args.vus || 50;
const duration = args.duration || '10s';

export let options = {
    vus: vus, // Number of virtual users to simulate
    duration: duration, // Duration of the test
    thresholds: {
        http_req_failed: ['rate<0.01'], // http errors should be less than 0.11%
        http_req_duration: ['p(95)<500'], // 95% of requests must complete within 500ms
    }
};

export default function () {
    // Make a GET request to the endpoint
    let response = http.get(`${__ENV.K6_TEST_URL}/auth?apikey=test`);

    // Validate response to ensure it's successful
    if (response.status !== 200) {
        console.error(`Request failed with status: ${response.status}`);
    }

    // Sleep for a random short duration (1-3s)
    sleep(1 + Math.random() * 2);
}
