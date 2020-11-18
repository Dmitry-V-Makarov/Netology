
-- Practice 5 (from lecture 1.4)
/* SELECT sub.title, COUNT(sub.feat) feat_count
FROM (SELECT film_id, title, unnest(special_features) feat FROM film GROUP BY film_id ORDER BY film_id) as sub
GROUP BY sub.title ORDER BY sub.title; */


-- Assignment

CREATE SCHEMA lec 
    CREATE TABLE language (
        id serial NOT NULL, 
        customer_id INT NOT NULL, 
        ship_date DATE NOT NULL
    )