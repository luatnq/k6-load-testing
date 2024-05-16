# K6 load testing

# Run influxdb grafana
docker compose up -d influxdb grafana

# define script testing in folder scripts
# run script testing

docker compose run k6 run /scripts/http_get.js