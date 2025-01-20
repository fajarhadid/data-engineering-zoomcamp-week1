# Week 1: Docker, Postgres, Terraform, and GCP
## Overview
This project involves setting up a Dockerized PostgreSQL database for NYC taxi data, creating a data pipeline, performing query analysis, and deploying infrastructure using Terraform. The README provides step-by-step instructions and queries for various tasks.

## Docker Setup
### PostgreSQL Container
Run the following command to start a PostgreSQL Docker container:
```bash
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB="ny_taxi" \
    -v d://data-engineering-zoomcamp//week_1//2_docker_sql//ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database \
    postgres:16.6
```
### pgAdmin Container
Run the following command to launch a Docker Container containing pgAdmin running in server mode:
```bash
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    --network=pg-network
    --name pgadmin
    dpage/pgadmin4
```

## Data Pipeline
### Building Docker Image
Build a Docker image for the data ingestion pipeline:
```bash
docker build -t taxi_data_ingestion:v001 .
```

### Running Data Pipeline Container
Run the data ingestion pipeline container:
```bash
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"

docker run -it ingest_data.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db=ny_taxi \
    --table_name=green_taxi_trips \
    --url=${URL}
```

## Docker Compose
Docker Compose is used to orchestrate multiple containers. It provides a way to define and run multi-container Docker applications. In this project, it is used to define and run the entire stack in a more organized manner.

To deploy the entire stack using Docker Compose use this command:
```bash
docker-compose up
```

In detached mode (so you don't need to open new terminal):
```bash
docker-compose up -d
```

To stop the containers use this command:
```bash
docker compose down
```

## NYC Green Taxi Trips Analysis Queries
### Question 3: Trip Segmentation Count
This query count the total trips between October 1st 2019 and November 1st 2019 with the following criteria:
1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive)
3.In between 3 (exclusive) and 7 miles (inclusive)
4. In between 7 (exclusive) and 10 miles (inclusive)
5. Over 10 miles

```sql
SELECT
	SUM(CASE WHEN trip_distance <= 1 THEN 1 ELSE 0 END) AS up_to_1_miles,
	SUM(CASE WHEN trip_distance > 1 AND trip_distance <= 3 THEN 1 ELSE 0 END)
		AS between_1_and_3_miles,
	SUM(CASE WHEN trip_distance > 3 AND trip_distance <= 7 THEN 1 ELSE 0 END)
		AS between_3_and_7_miles,
	SUM(CASE WHEN trip_distance > 7 AND trip_distance <= 10 THEN 1 ELSE 0 END)
		AS between_7_and_10_miles,
	SUM(CASE WHEN trip_distance > 10 THEN 1 ELSE 0 END) AS over_10_miles
FROM green_taxi_trips
WHERE lpep_dropoff_datetime >= '2019-10-01'
  AND lpep_dropoff_datetime < '2019-11-01';
```
Result:
![Query_Result](data/images/Q3.png)

### Question 4: Longest trip for each day
This query retrieve pick up day with the longest trip distance.
```sql
SELECT lpep_pickup_datetime
FROM green_taxi_trips
WHERE trip_distance = 
	(SELECT MAX(trip_distance) FROM green_taxi_trips);
```
Result:
![Query_Result](data/images/Q4.png)

### Question 5: Three biggest pickup zones
This query identify the top pickup locations where the total total_amount exceeds 13,000 across all trips for the date 2019-10-18.
```sql
SELECT "Zone"
FROM zones z
JOIN green_taxi_trips t
ON z."LocationID" = t."PULocationID"
WHERE DATE(lpep_pickup_datetime) = '2019-10-18'
GROUP BY 1
HAVING SUM(total_amount) > 13000;
```
Result:
![Query_Result](data/images/Q5.png)

### Question 6: Largest tip
This query find the drop-off zone with the largest tip for passengers picked up in October 2019 from the zone named "East Harlem North".
```sql
SELECT "Zone"
FROM zones z
JOIN green_taxi_trips t
ON z."LocationID" = t."DOLocationID"
WHERE "PULocationID" = 74
    AND DATE(t.lpep_pickup_datetime) BETWEEN '2019-10-01' AND '2019-10-31'
ORDER BY tip_amount DESC
LIMIT 1;
```
Result:
![Query_Result](data/images/Q6.png)
