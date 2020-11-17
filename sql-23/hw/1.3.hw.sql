
-- Practice 4 (from lecture 1.3)
-- Table with 3 attributes: film title, actor name, number of films per actor
/* SELECT film.title, actor.actor_id, actor.first_name, actor.last_name, COUNT(actor.actor_id) OVER (PARTITION BY actor.actor_id) AS filmography
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
ORDER BY film.title; */

-- Assignment 1 
-- SELECT store_id, COUNT (customer_id) cust_count FROM customer c GROUP BY store_id HAVING COUNT (customer_id) > 300;

-- Assignment 2
/* SELECT c.first_name, c.last_name, a.address, city.city 
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ON a.city_id = city.city_id; */

-- Assignment 3
/* SELECT staff.first_name, staff.last_name, city.city 
FROM staff
JOIN address a ON staff.address_id = a.address_id 
JOIN city ON a.city_id = city.city_id
WHERE staff.store_id = (SELECT store_id FROM customer c GROUP BY store_id HAVING COUNT (customer_id) > 300); */

-- Assignment 4
/* SELECT COUNT (DISTINCT actor.actor_id)
FROM actor
JOIN film_actor fa ON actor.actor_id = fa.actor_id 
JOIN film ON fa.film_id = film.film_id
WHERE film.film_id IN (SELECT f.film_id FROM film f WHERE f.rental_rate = 2.99); */
