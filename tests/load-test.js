import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 20 },
    { duration: '3m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '2m', target: 20 },
    { duration: '2m', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
  },
};

const baseUrl = __ENV.BASE_URL || 'http://k8s-redempti-redempti-ccf6f16de4-811560803.ap-southeast-1.elb.amazonaws.com/';

export default function () {
  const response = http.get(baseUrl, {
    timeout: '5s',
  });

  check(response, {
    'status is 200': (result) => result.status === 200,
    'latency under 1s': (result) => result.timings.duration < 1000,
  });

  sleep(1);
}
