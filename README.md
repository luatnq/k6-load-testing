# K6 load testing

# Run influxdb grafana
docker compose up -d influxdb grafana

# define script testing in folder scripts
# run script testing

docker compose run k6 run /scripts/http_get.js

# Note
Use local dockerfile if you want to use an extension of xk6 other than default (kafka, redis.....)