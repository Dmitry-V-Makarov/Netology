

-- query 1
SELECT
	city,
	COUNT(airport_code) n_air
FROM
	bookings.airports a
GROUP BY
	city
HAVING
	COUNT(airport_code) > 1
ORDER BY
	city;

-- query 2
SELECT DISTINCT
	ap.airport_name,
	ap.airport_code,
	a.model
FROM
	bookings.flights f
LEFT JOIN bookings.airports ap ON
	f.departure_airport = ap.airport_code OR f.arrival_airport = ap.airport_code 
LEFT JOIN bookings.aircrafts a ON
	f.aircraft_code = a.aircraft_code
WHERE
	f.aircraft_code = (
	SELECT
		aircraft_code
	FROM
		bookings.aircrafts a
	WHERE range = (SELECT MAX(range) FROM bookings.aircrafts));
			
-- query 3
SELECT
	f.scheduled_departure,
	f.actual_departure,
	ROUND((EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure)) / 3600) ::numeric, 1) AS delay_in_hours
FROM
	bookings.flights f
WHERE 
	f.actual_departure IS NOT NULL AND EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure)) != 0
ORDER BY
	delay_in_hours DESC
LIMIT 10;

-- query 4
SELECT
	b.book_ref,
	t.ticket_no,
	tf.ticket_no,
	tf.fare_conditions,
	bp.boarding_no,
	bp.flight_id,
	bp.ticket_no,
	bp.seat_no
FROM
	bookings.bookings b
RIGHT JOIN bookings.tickets t ON
	b.book_ref = t.book_ref
RIGHT JOIN bookings.ticket_flights tf ON
	t.ticket_no = tf.ticket_no
LEFT JOIN bookings.boarding_passes bp ON
	tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id
WHERE
	bp.boarding_no IS NULL;

-- query 5
SELECT sub.flight_id, sub.seats_available
FROM (
SELECT
	f.flight_id,
	100 * (1- COUNT(bp.boarding_no IS NOT NULL) / COUNT(s.seat_no)::float) seats_available
FROM
	bookings.flights f
LEFT JOIN bookings.ticket_flights tf ON
	f.flight_id = tf.flight_id
RIGHT JOIN bookings.boarding_passes bp ON
	tf.ticket_no = bp.ticket_no 
LEFT JOIN bookings.aircrafts a ON
	f.aircraft_code = a.aircraft_code
LEFT JOIN bookings.seats s ON
	a.aircraft_code = s.aircraft_code
GROUP BY
	f.flight_id
ORDER BY
	seats_available DESC) sub;

SELECT
	f.actual_departure, f.departure_airport, f.flight_id
FROM
	bookings.flights f
LEFT JOIN bookings.ticket_flights tf ON
	f.flight_id = tf.flight_id
LEFT JOIN bookings.boarding_passes bp ON
	tf.flight_id = bp.flight_id
WHERE f.actual_departure IS NOT NULL
ORDER BY
	f.departure_airport, f.actual_departure

-- query 6
SELECT
	f.aircraft_code,
	a.model,
	ROUND(100.0 * COUNT(f.flight_id) / (SELECT COUNT(flight_id) FROM bookings.flights f2), 2) AS aircraft_share
FROM
	bookings.flights f
LEFT JOIN bookings.aircrafts a ON
	f.aircraft_code = a.aircraft_code
GROUP BY
	f.aircraft_code,
	a.model;

-- query 7
-- CTE with distinct flights showing 2 classes only + row number
WITH economy_business_only AS
(
-- CTE showing distinct flights with all classes
WITH all_classes AS
(
	SELECT CONCAT(f.departure_airport , ' ', f.arrival_airport) flight, tf.fare_conditions, ROUND(AVG(tf.amount), 2) f_cost
	FROM bookings.flights f 
	LEFT JOIN bookings.airports a 
	ON f.arrival_airport = a.airport_code
	LEFT JOIN bookings.ticket_flights tf 
	ON f.flight_id = tf.flight_id
	GROUP BY flight, tf.fare_conditions 
	HAVING CONCAT(f.departure_airport , ' ', f.arrival_airport) IS NOT NULL AND tf.fare_conditions IS NOT NULL
	ORDER BY flight, tf.fare_conditions
)
-- selecting Economy AND Business flights
SELECT ROW_NUMBER() OVER(PARTITION BY flight ORDER BY fare_conditions) row_n, *
FROM (
	SELECT * FROM all_classes
	WHERE fare_conditions != 'Comfort' AND flight IN (
	SELECT flight FROM all_classes 
	GROUP BY flight
	HAVING COUNT(fare_conditions) = 2)
	) econ_AND_business
)
-- showing flights where economy class does not have the smallest price (i.e it is cheaper to travel in business class)
SELECT flight, econ_price, smallest_price 
FROM (
	SELECT row_n, flight, f_cost AS econ_price, MIN(f_cost) OVER(PARTITION BY flight) smallest_price
	FROM economy_business_only
	WHERE row_n = 2
	) compare_econ_smallest
WHERE econ_price != smallest_price;

-- query 8
CREATE VIEW dep_city AS (
	SELECT r.departure_city 
	FROM bookings.routes r
);

CREATE VIEW arr_city AS (
	SELECT r.arrival_city 
	FROM bookings.routes r
);

-- all possible direct flights
SELECT DISTINCT CONCAT (departure_city, ' ', arrival_city) combinations
FROM (SELECT departure_city, arrival_city FROM dep_city CROSS JOIN arr_city) cross_join
ORDER BY combinations;

-- existing direct flights
SELECT DISTINCT CONCAT (departure_city, ' ', arrival_city) combinations
FROM bookings.routes r
ORDER BY combinations;


-- choose all possible direct flights
SELECT DISTINCT CONCAT (departure_city, ' ', arrival_city) combinations
FROM (SELECT departure_city, arrival_city FROM dep_city CROSS JOIN arr_city) cross_join
EXCEPT
-- and subtract existing direct flights
SELECT DISTINCT CONCAT (departure_city, ' ', arrival_city) combinations
FROM bookings.routes r
ORDER BY combinations;


-- query 9
SELECT * FROM bookings.routes r;
SELECT * FROM bookings.airports a ORDER BY airport_name;

/* 
 * step 1: add latitude and longitude to routes
 * step 2.1: calculate distance in rad: d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b)}, 
 * step 2.2: calculate distance in km: L = d·R, where R = 6371 km
 * step 3: add aicraft range based on aircraft code
 * step 4: add comparison column
 */

-- airport lat and long
WITH ap_lat_long AS (
SELECT
	dep_air,
	dep_name,
	arr_air,
	arr_name,
	ac,
	lat_a,
	long_a,
	latitude lat_b,
	longitude long_b
FROM
	(
	SELECT
		r.departure_airport dep_air,
		r.departure_airport_name dep_name,
		r.arrival_airport arr_air,
		r.arrival_airport_name arr_name,
		r.aircraft_code ac,
		a.latitude lat_a,
		a.longitude long_a
	FROM
		bookings.routes r
	-- departure airport lat and long only
	LEFT JOIN bookings.airports a ON
		r.departure_airport = a.airport_code) dep_lat_long
-- departure and arrival lat and long
LEFT JOIN bookings.airports a2 ON
	dep_lat_long.arr_air = a2.airport_code)
SELECT 
	*, 
	acos(sin(radians(lat_a))*sin(radians(lat_b))+cos(radians(lat_a))*cos(radians(lat_b))*cos(radians(long_b - long_a))) d_radians,  
	acos(sin(radians(lat_a))*sin(radians(lat_b))+cos(radians(lat_a))*cos(radians(lat_b))*cos(radians(long_b - long_a))) * 6371 d_km
FROM ap_lat_long apll
LEFT JOIN bookings.aircrafts a3 
ON apll.ac = a3.aircraft_code;
	
/* (CASE 
		WHEN apll.d_km - apll."range" > 200 THEN 'Enough'
		WHEN apll.d_km - apll."range" <= 200 AND apll.d_km - apll."range" > 0 THEN 'Almost Enough'
		WHEN apll.d_km - apll."range" <= 0 THEN 'Not Enough'
	END) range_eval*/
