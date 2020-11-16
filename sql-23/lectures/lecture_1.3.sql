-- Practice 1
/* SELECT film.title, language.name 
FROM film 
LEFT JOIN language ON film.language_id = language.language_id; */

/* SELECT actor.first_name, actor.last_name
FROM film 
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film.film_id = 508; */

-- Practice 2
/* SELECT COUNT (DISTINCT actor.last_name)
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film.film_id = 384; */

--Practice 3
-- Выведите список фильмов, в которых снималось больше 10 актеров
/* SELECT film.title, COUNT (DISTINCT actor.last_name)
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
GROUP BY film.title
HAVING COUNT (DISTINCT actor.last_name) > 10; */
