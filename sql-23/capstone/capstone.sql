
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
	scheduled_departure,
	actual_departure,
	("delay_in_s"::varchar(24) || ' seconds')::interval as delay_in_HMS
FROM
(SELECT
	f.scheduled_departure,
	f.actual_departure,
	ROUND((EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure))) ::numeric, 1) AS delay_in_s
FROM
	bookings.flights f
WHERE 
	f.actual_departure IS NOT NULL AND EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure)) != 0
ORDER BY
	delay_in_s DESC
LIMIT 10) sub;


-- query 4
SELECT DISTINCT b.book_ref 
FROM
	bookings.bookings b 
RIGHT JOIN bookings.tickets t ON 
	b.book_ref = t.book_ref
LEFT JOIN bookings.boarding_passes bp ON
	t.ticket_no = bp.ticket_no
WHERE
	bp.boarding_no IS NULL
ORDER BY
	b.book_ref;


-- query 5
-- people onboard, percentage of empty seats per flight of actually departed flights with cumulative sum of departed previously that day by departure airport
SELECT 
	fv.flight_id, 
	fv.flight_no, 
	fv.departure_airport_name dep_name, 
	fv.arrival_airport_name arr_name, 
	fv.aircraft_code ac,
	fv.actual_departure act_depart,
	COUNT (fv.flight_id) onboard,
	ts.t_seats,
	ts.t_seats - COUNT (fv.flight_id) e_seats,
	ROUND(100 * (1 - COUNT(fv.flight_id) / ts.t_seats::numeric), 2) e_seats_rel,
	SUM(COUNT (fv.flight_id)) 
		OVER(PARTITION BY fv.departure_airport_name, DATE(fv.actual_departure) 
		ORDER BY fv.departure_airport_name, fv.actual_departure 
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumul_day
FROM bookings.flights_v fv
LEFT JOIN bookings.ticket_flights tf ON
	fv.flight_id = tf.flight_id
RIGHT JOIN bookings.boarding_passes bp ON
	tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id 
-- capacity of each AC
LEFT JOIN (SELECT aircraft_code, COUNT(aircraft_code) t_seats FROM bookings.seats s GROUP BY aircraft_code) ts ON
	fv.aircraft_code = ts.aircraft_code
GROUP BY 
	fv.flight_id, 
	fv.flight_no, 
	fv.departure_airport_name, 
	fv.arrival_airport_name, 
	fv.aircraft_code,
	ts.t_seats, 
	fv.actual_departure
-- only actual departures
HAVING fv.actual_departure IS NOT NULL;
-- ORDER BY fv.departure_airport_name, fv.actual_departure;


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

-- distance and range comparison category for each flight
WITH dist_range_comparison AS (
-- airport lat and lon
WITH ap_lat_lon AS (
SELECT
	dep_air,
	dep_name,
	arr_air,
	arr_name,
	ac,
	lat_a,
	lon_a,
	latitude lat_b,
	longitude lon_b
FROM
	(
	SELECT
		r.departure_airport dep_air,
		r.departure_airport_name dep_name,
		r.arrival_airport arr_air,
		r.arrival_airport_name arr_name,
		r.aircraft_code ac,
		a.latitude lat_a,
		a.longitude lon_a
	FROM
		bookings.routes r
	-- departure airport lat and lon only
	LEFT JOIN bookings.airports a ON
		r.departure_airport = a.airport_code) dep_lat_lon
-- both departure and arrival lat and lon
LEFT JOIN bookings.airports a2 ON
	dep_lat_lon.arr_air = a2.airport_code)
SELECT 
	dep_air,
	dep_name,
	arr_air,
	arr_name,
	model,  
	ROUND((acos(sin(radians(lat_a))*sin(radians(lat_b))+cos(radians(lat_a))*cos(radians(lat_b))*cos(radians(lon_b - lon_a))) * 6371)::numeric, 1) dist_km,
	"range"
FROM ap_lat_lon
LEFT JOIN bookings.aircrafts ac 
ON ap_lat_lon.ac = ac.aircraft_code)
SELECT 
	*,
	(CASE 
		WHEN "range" - dist_km > 100 THEN 'Enough'
		WHEN "range" - dist_km <= 100 AND "range" - dist_km > 0 THEN 'Almost enough'
		WHEN "range" - dist_km <= 0 THEN 'Not Enough'
	END) coverage
FROM dist_range_comparison
-- WHERE "range" - dist_km <= 0
ORDER BY dist_km DESC;
