
-- Assignment

CREATE SCHEMA lec

CREATE TABLE lec.etnos (
    id serial PRIMARY KEY, 
    etnos VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE lec.country (
    id serial PRIMARY KEY, 
    country VARCHAR(100) NOT NULL UNIQUE,
    founded DATE NOT NULL,
    republic BOOLEAN NOT NULL
);
CREATE TABLE lec.etnos_country (
    etnos_id INTEGER REFERENCES lec.etnos(id),
    country_id INTEGER REFERENCES lec.country(id),
    PRIMARY KEY (etnos_id, country_id)
);
CREATE TABLE lec.lang (
    id serial PRIMARY KEY,
    lang VARCHAR(100) NOT NULL UNIQUE,
    attrib TEXT []
);
CREATE TABLE lec.etnos_lang (
        etnos_id INTEGER REFERENCES lec.etnos(id),
        lang_id INTEGER REFERENCES lec.lang(id),
        PRIMARY KEY (etnos_id, lang_id)
    );

INSERT INTO lec.etnos (etnos) 
VALUES 
	('Russians'), 
	('Latvians'),
	('Germans'),
	('Estonians'),
	('British');

-- better to use
insert into lec.etnos (etnos) 
select unnest(array['Russians', 'Latvians', 'Germans', 'Estonians', 'British']);
	
INSERT INTO lec.country (country, founded, republic) 
VALUES 
	('RussianFed', '1991-12-12', TRUE), 
	('Latvia', '1991-08-21', TRUE),
	('Germany', '1990-10-03', TRUE),
	('Estonia', '1991-08-20', TRUE),
	('UK', '1801-01-01', FALSE);

INSERT INTO lec.etnos_country (etnos_id, country_id) 
VALUES 
	(1, 1), 
	(2, 2),
	(1, 2),
	(1, 3),
	(1, 4),
	(1, 5),
	(2, 5),
	(5, 5);

INSERT INTO lec.lang (lang, attrib) 
VALUES 
	('Russian', ARRAY ['modern', 'Slavic']), 
	('Latvian', ARRAY ['modern', 'Baltic']),
	('German', ARRAY ['modern', 'Germanic']),
	('Estonian', ARRAY ['modern', 'Finnic']),
	('English', ARRAY ['modern', 'Germanic']);

INSERT INTO lec.etnos_lang (etnos_id, lang_id) 
VALUES 
	(1, 1), 
	(2, 2),
	(3, 3),
	(4, 4),
	(5, 5),
	(1, 5),
	(2, 1),
	(4, 1);

INSERT INTO lec.etnos_country (etnos_id, country_id) 
VALUES 
	(3, 3), 
	(4, 4);

SELECT * FROM lec.country;
SELECT * FROM lec.etnos;
SELECT * FROM lec.lang;

SELECT c.country, e.etnos FROM lec.country c 
JOIN lec.etnos_country ec ON c.id = ec.country_id 
JOIN lec.etnos e ON ec.etnos_id = e.id
ORDER BY c.country;

SELECT e.etnos, l.lang FROM lec.lang l 
JOIN lec.etnos_lang el ON l.id = el.lang_id 
JOIN lec.etnos e ON el.etnos_id = e.id
ORDER BY e.etnos;
	

