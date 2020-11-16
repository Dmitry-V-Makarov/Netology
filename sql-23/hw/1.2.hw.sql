-- Main part

-- Assignment 2
-- SELECT * FROM customer WHERE active = 0;

-- Assignment 3
-- SELECT * FROM film WHERE release_year = 2006;

-- Assignment 4
-- SELECT * FROM payment ORDER BY payment_date DESC LIMIT 10;


-- Additional exercises

-- Assignment 5 and 6
SELECT  
  tc.constraint_schema, 
  tc.table_name,
  tc.constraint_name,
  col.data_type 
FROM information_schema.table_constraints tc LEFT JOIN information_schema.columns col
ON tc.table_name = col.table_name
WHERE tc.constraint_type = 'PRIMARY KEY'