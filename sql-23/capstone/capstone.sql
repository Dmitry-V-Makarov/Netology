
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
		ORDER BY fv.actual_departure 
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

WITH prices AS (
SELECT f.flight_id, tf.fare_conditions, MIN(amount) min_amount, MAX(amount) max_amount
FROM bookings.flights f 
RIGHT JOIN bookings.ticket_flights tf 
ON f.flight_id = tf.flight_id
GROUP BY f.flight_id, tf.fare_conditions
HAVING tf.fare_conditions != 'Comfort' AND COUNT(tf.fare_conditions) > 1
)
SELECT b.flight_id, b.min_amount business_min, e.max_amount economy_max
FROM (SELECT * FROM prices WHERE fare_conditions = 'Business') b
LEFT JOIN (SELECT * FROM prices WHERE fare_conditions = 'Economy') e
ON b.flight_id = e.flight_id
WHERE b.min_amount < e.max_amount;


-- query 8
CREATE OR REPLACE VIEW bookings.dep_city AS (
SELECT DISTINCT city dep_city
FROM bookings.flights f
LEFT JOIN bookings.airports a 
ON f.departure_airport = a.airport_code
ORDER BY city
);

CREATE OR REPLACE VIEW bookings.arr_city AS (
SELECT DISTINCT city arr_city
FROM bookings.flights f
LEFT JOIN bookings.airports a 
ON f.arrival_airport = a.airport_code
ORDER BY city
);

-- all possible direct flights
SELECT CONCAT (dep_city, ' ', arr_city) all_possible_flights
FROM (
SELECT * FROM bookings.dep_city dc, bookings.arr_city ac
WHERE dep_city != arr_city) all_possible;

-- existing direct flights
SELECT CONCAT (departure_city, ' ', arrival_city) existing_flights
FROM (
SELECT DISTINCT
	a1.city departure_city,
	a2.city arrival_city
FROM bookings.flights f
LEFT JOIN bookings.airports a1 
ON f.departure_airport = a1.airport_code
LEFT JOIN bookings.airports a2 
ON f.arrival_airport = a2.airport_code
ORDER BY a1.city) existing_only;

WITH non_existing_direct AS (
-- choose all possible direct flights
SELECT CONCAT (dep_city, ' ', arr_city) possible_flights
FROM (
SELECT * FROM bookings.dep_city dc, bookings.arr_city ac
WHERE dep_city != arr_city) all_possible
EXCEPT
-- and subtract existing direct flights
SELECT CONCAT (departure_city, ' ', arrival_city) existing_flights
FROM (
SELECT DISTINCT
	a1.city departure_city,
	a2.city arrival_city
FROM bookings.flights f
LEFT JOIN bookings.airports a1 
ON f.departure_airport = a1.airport_code
LEFT JOIN bookings.airports a2 
ON f.arrival_airport = a2.airport_code
ORDER BY a1.city) existing_only)
SELECT * FROM non_existing_direct
ORDER BY possible_flights;


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
