

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
SELECT b.book_ref, t.ticket_no, tf.ticket_no, tf.fare_conditions, bp.boarding_no, bp.flight_id, bp.ticket_no, bp.seat_no 
FROM bookings.bookings b 
RIGHT JOIN bookings.tickets t 
ON b.book_ref = t.book_ref 
RIGHT JOIN bookings.ticket_flights tf 
ON t.ticket_no = tf.ticket_no 
LEFT JOIN bookings.boarding_passes bp 
ON tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id 
WHERE bp.boarding_no IS NULL;

-- query 5

