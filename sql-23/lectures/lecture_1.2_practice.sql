1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select film_id as Filmfilm_id, title as Filmtitle, description Filmdescription, release_year Filmrelease_year
from film

select 
	film_id as "Filmfilm_id", 
	title as "Filmtitle", 
	description "Описание фильма", 
	release_year "Film release year"
from 
	film

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration

select film_id, title, rental_duration/rental_rate
from film f

2* В полученной таблице задайте вычисленному столбцу псевдоним cost_per_day

- as - для задания синонимов 

select film_id, title, rental_duration/rental_rate as cost_per_day
from film f
order by cost_per_day

select f.title, c."name", f.film_id
from film f
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id


select t.title
from (
	select f.title
	from film f) as t

select film.title, category."name", film.film_id
from film 
left join film_category on film_category.film_id = film.film_id
left join category on category.category_id = film_category.category_id

select 'select' from language


3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)

- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select film_id, title, rental_rate/rental_duration as cost_per_day
from film f
order by cost_per_day desc

select film_id, title, round(rental_rate/rental_duration, 2) as cost_per_day
from film f
order by cost_per_day desc

round(1 / 2, 2) = 0 

3.1* Отсортируйте таблцу платежей по возрастанию суммы платежа (amount)

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select payment_id, amount
from payment
order by amount, payment_id desc

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды

- используйте limit

select film_id, title, rental_rate/rental_duration as cost_per_day
from film f
order by cost_per_day desc
limit 10

3.3 Вывести топ-5 самых дорогих фильмов по стоимости аренды за день, начиная с 4-ой позиции

- воспользуйтесь Limit и offset

select film_id, title, rental_rate/rental_duration as cost_per_day
from film f
order by cost_per_day desc
offset 57
limit 10

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000

- воспользуйтесь Limit и Offset

select payment_id, amount
from payment 
order by amount
offset 13999
limit 15

4. Вывести все уникальные годы выпуска фильмов

- воспользуйтесь distinct

select distinct release_year
from film

select distinct release_year, film_id
from film

select distinct extract(year from payment_date)
from payment 

select * from film_actor fa

4* Вывести уникальные имена покупателей

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select distinct first_name
from customer


==========

логический порядок

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE или WITH ROLLUP
HAVING
select <-- объявляем алиасы (псевдонимы)
DISTINCT
ORDER BY

алиасы, видимость



метаданные

select tc.table_name, tc.constraint_name 
from information_schema.table_constraints tc
where tc.constraint_schema = 'public' and tc.constraint_type = 'PRIMARY KEY'

название_схемы.название_таблицы --from
название_таблицы.название_столбца --select

==========

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации 
- where - конструкция фильтрации
- "=" - оператор сравнения

select title || ' - ' || release_year, rating
from film 

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'

- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск

select concat(title, ' - ', release_year), rating
from film 
where cast(rating as text) like 'PG%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'PG___'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%PG%' and length(rating::text) = 5

select concat(title, ' - ', release_year), rating
from film 
where rating::text ilike '%13%'

select concat(title, ' - ', release_year), lower(rating::text)
from film 
where lower(rating::text) like '%pg%'

select concat(title, ' - ', release_year), rating
from film 
where upper(rating::text) like '%PG%'

select pg_typeof(rating) --enum
from film

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания), в виде: "имя фамилия" - одной строкой.

- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск

select concat(first_name, ' ', last_name), 
	lower(concat(first_name, ' ', last_name)),
	upper(concat(first_name, ' ', last_name))
from customer
where first_name ilike '%jam%'

select amount
from payment
where amount::text like '7%'

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 по 28-05-2005 включительно

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)

select customer_id, rental_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005'
-- where rental_date between '2005-05-27' and '2005-05-28' если облако

select customer_id, rental_id, rental_date
from rental
where rental_date >= '27-05-2005' and rental_date <= '28-05-2005'

select customer_id, rental_id, rental_date
from rental
where rental_date between '27-05-2005 00:00:00'and '28-05-2005 23:59:59'

select customer_id, rental_id, rental_date
from rental
where rental_date between '27-05-2005 00:00:00'and '29-05-2005 00:00:00'

select customer_id, rental_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005'::date + interval '1 day'

6* Вывести платежи поступившие после 30-04-2007

- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select payment_id, payment_date
from payment 
where payment_date > '30-04-2007'::date + interval '1 day'

select payment_id, payment_date
from payment 
where payment_date > date('30-04-2007') + interval '1 day'

select date('28-02-2020') + interval '125 day' + interval '3 month'

select extract(year from date('28-02-2020')), 
	extract(month from date('28-02-2020')),
	extract(week from date('28-02-2020')),
	extract(day from date('28-02-2020'))
	
select concat(date_part('year', date('28-02-2020')), 
	' соединим ', 
	date_part('month', date('28-02-2020')), 
	' добавим точку ', 
	date_part('day', date('28-02-2020')))
	
select format(date('28-02-2020'), 'y-d-m')

	
	
select sum(amount), date_part('month', payment_date)
from payment 
group by date_part('month', payment_date)

format('Y-d-m')
select sum(amount), date_trunc('month', payment_date)
from payment 
group by date_trunc('month', payment_date)

select 'ffFFffFF', lower('ffFFffFF'), upper('ffFFffFF')

create function foo () returns int as $$
declare x int;
begin 
	select 2 + 2 into x;
	return x;
end;
$$ language plpgsql

select foo()

