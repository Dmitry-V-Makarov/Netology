SELECT ticket_no, COUNT (book_ref) n_tickets 
FROM bookings.tickets
GROUP BY ticket_no
ORDER BY COUNT (book_ref) DESC
LIMIT 10;

-- query 1
SELECT city, COUNT(airport_code) n_air
FROM bookings.airports a 
GROUP BY city
HAVING COUNT(airport_code) > 1
ORDER BY city;

-- query 2