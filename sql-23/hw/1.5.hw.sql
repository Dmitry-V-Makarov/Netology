
-- Assignment 1
SELECT customer_id, rental_id, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY rental_date DESC) row_n, rental_date 
FROM rental;

-- Assignment 2
-- EXPLAIN ANALYZE
-- CREATE MATERIALIZED VIEW n_rented AS
SELECT first_name, last_name, COUNT(sub.special_features) n_films
FROM (
SELECT c.customer_id, c.first_name, c.last_name, f.film_id, f.special_features 
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id 
LEFT JOIN inventory i ON r.rental_id = i.inventory_id 
LEFT JOIN film f ON f.film_id = i.film_id
WHERE 'Behind the Scenes' = ANY(f.special_features) -- Option 1
-- WHERE f.title IS NOT NULL AND array_to_string(f.special_features, ',') like '%Behind the Scenes%' -- Option 2
-- Option 3 would be to unnest special_features /not optimal/
) sub
GROUP BY customer_id, first_name, last_name
ORDER BY n_films DESC;
-- WITH NO DATA;

REFRESH MATERIALIZED VIEW n_rented;

SELECT * FROM n_rented;





