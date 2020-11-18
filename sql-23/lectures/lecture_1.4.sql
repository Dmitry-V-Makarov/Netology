
-- Practice 1
/* CREATE TABLE author_train (
	id serial PRIMARY KEY,
	full_name VARCHAR(100) NOT NULL,
	alias VARCHAR(50) UNIQUE NOT NULL,
	birthdate DATE NOT NULL
);

INSERT INTO author_train (full_name, alias, birthdate) VALUES ('Alex Smith', 'Alex', '1980-11-27');

SELECT * FROM author_train; */

-- Practice 2
/* INSERT INTO author_train (full_name, alias, birthdate) 
VALUES 
	('Mitch Rurk', 'Mickey', '1985-04-02'), 
	('John Dirk', 'Hammer', '1975-02-28'); */

-- SELECT * FROM author_train;

-- ALTER TABLE author_train ADD COLUMN birth_place VARCHAR(100)

/* UPDATE author_train 
SET birth_place = 'New York'
WHERE birth_place IS NULL; */

-- Practice 3
/* CREATE TABLE works_train (
	work_id serial PRIMARY KEY,
	work_year SMALLINT NOT NULL,
	work_title VARCHAR(300) NOT NULL,
	author_ref INTEGER REFERENCES author_train(id)
); */ 

/* INSERT INTO works_train (work_year, work_title, author_ref) 
VALUES 
	(1985, 'Catcher in the Rye', 1), 
	(1999, 'Untouchables', 2),
	(2000, 'New Book', 3); */

/* SELECT * FROM works_train w
JOIN author_train a ON w.author_ref = a.id */

-- DELETE FROM author_train WHERE id = 3;

-- Practice 4
/* CREATE TABLE orders_train (
ID serial NOT NULL PRIMARY KEY,
info json NOT NULL
); */

/* INSERT INTO orders_train (info)
VALUES
(
'{"customer": "John Doe", "items": {"product": "Beer", "qty": 6}}'
),
(
'{"customer": "Lily Bush", "items": {"product": "Diaper", "qty": 24}}'
),
(
'{"customer": "Josh William", "items": {"product": "Toy Car", "qty": 1}}'
),
(
'{"customer": "Mary Clark", "items": {"product": "Toy Train", "qty": 2}}'
); */

-- SELECT SUM (CAST (info -> 'items' ->> 'qty' as INTEGER)) as total FROM orders;

-- Practice 5
-- SELECT sub.title, COUNT(feat) GROUP BY sub.title FROM (SELECT film_id, title, unnest(special_features) feat FROM film GROUP BY film_id ORDER BY film_id) sub;

/* SELECT sub.title, COUNT(sub.feat) feat_count
FROM (SELECT film_id, title, unnest(special_features) feat FROM film GROUP BY film_id ORDER BY film_id) as sub
GROUP BY sub.title ORDER BY sub.title; */

