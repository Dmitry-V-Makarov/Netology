-- to ensure CamelCase in code, use double quotes
-- https://dev.mysql.com/doc/sakila/en/sakila-structure-tables.html
SELECT film_id AS "FilmID", title AS "FilmTitle", description AS "FilmDesc", release_year AS "FilmRelYear", rental_rate / rental_duration AS "DayRate" FROM film ORDER BY "DayRate" DESC;
SELECT DISTINCT release_year FROM film;
SELECT * FROM film WHERE rating = 'PG-13';
SELECT * FROM film_actor;