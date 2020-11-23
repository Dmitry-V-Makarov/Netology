
-- Assignment 1
SELECT customer_id, rental_id, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rental_date DESC) row_n, rental_date 
FROM rental;

-- Assignment 2
EXPLAIN ANALYZE
-- CREATE MATERIALIZED VIEW n_rented AS
SELECT first_name, last_name, COUNT(sub.special_features) n_films
FROM (
SELECT c.customer_id, c.first_name, c.last_name, f.film_id, f.special_features 
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id 
INNER JOIN inventory i ON r.inventory_id = i.inventory_id 
INNER JOIN film f ON f.film_id = i.film_id
WHERE 'Behind the Scenes' = ANY(f.special_features)
-- WHERE f.title IS NOT NULL AND array_to_string(f.special_features, ',') like '%Behind the Scenes%'
-- WHERE 'Behind the Scenes' IN (SELECT unnest(f.special_features))
) sub
GROUP BY customer_id, 1, 2
ORDER BY n_films DESC;
-- WITH NO DATA;

CREATE INDEX public_customer_id ON customer(customer_id);
DROP INDEX public_customer_id;
CREATE INDEX public_film_id ON film(film_id);
DROP INDEX public_film_id;
CREATE INDEX public_rental_id ON rental(inventory_id, customer_id);
DROP INDEX public_rental_id;

CREATE INDEX film_index ON film USING GIN(special_features);

REFRESH MATERIALIZED VIEW n_rented;

SELECT * FROM n_rented;





