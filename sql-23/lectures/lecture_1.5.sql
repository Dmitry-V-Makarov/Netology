
-- Practice 1
-- Table with 3 attributes: film title, actor name, number of films per actor
-- We basically take each actor as WINDOW and count the number of entries and then give it as a result
-- without film.title we would be able to use GROUP BY?
-- important! COUNT appears in every line!
SELECT film.title, actor.actor_id, actor.first_name, actor.last_name, COUNT(actor.actor_id) OVER (PARTITION BY actor.actor_id) AS filmography
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
ORDER BY film.title

-- Practice 2
-- staff first name, last_name, number of rentals

SELECT * FROM rental;

WITH cte_staff_rental AS (
SELECT staff.staff_id, staff.first_name, staff.last_name, COUNT (rental.rental_id)
FROM rental LEFT JOIN staff ON rental.staff_id = staff.staff_id
GROUP BY staff.staff_id
) SELECT * FROM cte_staff_rental;

-- Practice 3
-- last rented film per customer
CREATE OR REPLACE VIEW last_rental AS
WITH rental_d AS (SELECT ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rental_date DESC) AS row_n, *
FROM (  
SELECT c.customer_id, c.first_name, c.last_name, c.email, r.rental_date, f.title
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id 
LEFT JOIN inventory i ON r.rental_id = i.inventory_id 
LEFT JOIN film f ON f.film_id = i.film_id
WHERE f.title IS NOT NULL
ORDER BY c.customer_id, r.rental_date DESC) rental_d2)
SELECT * FROM rental_d WHERE row_n = 1;

SELECT * FROM last_rental;
