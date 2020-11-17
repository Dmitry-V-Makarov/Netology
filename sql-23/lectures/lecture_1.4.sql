
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
