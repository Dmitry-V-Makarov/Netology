create table table_one (
	name_one varchar(255) not null
);

create table table_two (
	name_two varchar(255) not null
);

insert into table_one (name_one)
values ('one'), ('two'), ('three'), ('four'), ('five')

insert into table_two (name_two)
values ('four'), ('five'), ('six'), ('seven'), ('eight')

select * from table_one

select * from table_two

--left, right, inner, full outer, cross

select *
from table_one t1
left join table_two t2 on t1.name_one = t2.name_two

select *
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two

select *
from table_one t1
join table_two t2 on t1.name_one = t2.name_two

select *
from table_one t1
inner join table_two t2 on t1.name_one = t2.name_two

select *
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two

select *
from table_one t1
full join table_two t2 on t1.name_one = t2.name_two
where name_one is null or name_two is null

select * from table_one
union 
select * from table_two

select * from table_one
union all
select * from table_two

select 1 as x, 1 as y
union
select 1 as x, 1 as y

select 1 as x, 1 as y
union all
select 1 as x, 1 as y

select * from table_one
except 
select * from table_two

select 1 as x, 1 as y
except
select 1 as x, 1 as y

select * 
from table_one 
cross join table_two

select * 
from table_one, table_two

select concat(name_one, name_two)
from table_one t1
full outer join table_two t2 on t1.name_one = t2.name_two
where name_one is null or name_two is null

select 
	case 
		when t.name_one is null then t.name_two
		--when t.name_two is null then t.name_one
		when t.name_one = t.name_two then t.name_one
		else 'какой-то результат для остальных случаев'::text
	end
from
	(select *
	from table_one t1
	full outer join table_two t2 on t1.name_one = t2.name_two
	where name_one is null or name_two is null) as t


============= соединения =============

1. Выведите список названий всех фильмов и их языков (таблица language)
* Используйте таблицу film
* Соедините с language
* Выведите информацию о фильмах:
title, language."name"

select f.title, l."name"
from film f
left join "language" l on f.language_id = l.language_id

1.1 Выведите все фильмы и их категории:
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Выведите информацию о фильмах:
title, category."name"
--using

select f.title, c."name"
from film f
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id

select f.title, c."name"
from film f
left join film_category fc using(film_id)
left join category c using(category_id)

2. Выведите список всех актеров, снимавшихся в фильме Lambs Cincinatti (film_id = 508). 
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* Отфильтруйте, используя where и "title like" (для названия) или "film_id =" (для id)

select f.title, concat(a.last_name, ' ', a.first_name) -- a.last_name || ' ' || a.first_name
from film f
left join film_actor fa on f.film_id = fa.film_id
left join actor a on a.actor_id = fa.actor_id
where f.film_id = 508

2.1 Выведите все магазины из города Woodridge (city_id = 576)
* Используйте таблицу store
* Соедините таблицу с address 
* Соедините таблицу с city 
* Соедините таблицу с country 
* отфильтруйте , используя where и "city like" (для названия города) или "city_id ="  (для id)
* Выведите полный адрес искомых магазинов и их id:
store_id, postal_code, country, city, district, address, address2, phone

select s.store_id, a.postal_code, c2.country, c.city, a.district, a.address, a.address2, a.phone
from store s
left join address a on a.address_id = s.address_id
left join city c on c.city_id = a.city_id
left join country c2 on c.country_id = c2.country_id
where c.city_id = 576

============= агрегатные функции =============

3. Подсчитайте количество актеров в фильме Grosse Wonderful (id - 384)
* Используйте таблицу film
* Соедините с film_actor
* Отфильтруйте, используя where и "title like" (для названия) или "film_id =" (для id) 
* Для подсчета используйте функцию count, используйте actor_id в качестве выражения внутри функции
--ФЗ count(f.film_id) / count(fa.film_id)

select f.title, count(fa.actor_id)
from film f
left join film_actor fa on fa.film_id = f.film_id
where f.film_id = 384
group by f.film_id

-- хорошая практика
select f.title, count(fa.actor_id), f.description
from film f
left join film_actor fa on fa.film_id = f.film_id
group by f.film_id

-- плохая практика
select f.title, count(fa.actor_id), f.description
from film f
left join film_actor fa on fa.film_id = f.film_id
group by fa.film_id, f.title, f.description

FROM
ON
JOIN
WHERE
GROUP by --знает, но не в каждой СУБД это реализовано
WITH CUBE или WITH ROLLUP
HAVING
select --алиасы 
DISTINCT
ORDER by

select f.title, f.description, count(fa.actor_id)
from film f
left join film_actor fa on fa.film_id = f.film_id
group by 1, 2, fa.film_id
order by 2, 1

select f.title as tt, f.description as dd, count(fa.actor_id)
from film f
left join film_actor fa on fa.film_id = f.film_id
group by tt, dd, fa.film_id

3.1 Посчитайте среднюю стоимость аренды за день по всем фильмам
* Используйте таблицу film
* Стоимость аренды за день rental_rate/rental_duration
* avg - функция, вычисляющая среднее значение
--4 агрегации

select avg(rental_rate/rental_duration)
from film 

select sum(rental_rate/rental_duration)
from film 

select max(rental_rate/rental_duration)
from film 

select min(rental_rate/rental_duration)
from film 

select round((select count(film_id) from film) / (select count(film_id) from film_actor), 2)

select round(1000::numeric / 5462::numeric, 2)

decimal(10,2)

string_agg
array_agg

============= группировки =============

4. Выведите список фильмов, в которых снималось больше 10 актеров

* Используйте таблицу film
* Соедините с film_actor
* Сгруппируйте итоговую таблицу по film_id
* Для каждой группы посчитайте колличество актеров
* Воспользуйтесь фильтрацией групп, для выбора фильмов с колличеством > 10
--having, numeric, alias

select f.title, count(fa.actor_id)
from film f
left join film_actor fa on fa.film_id = f.film_id
group by f.film_id
having count(fa.actor_id) > 10

/*select distinct f.title
from film f
left join film_actor fa on fa.film_id = f.film_id*/


4.1 Выведите список категорий фильмов, средняя продолжительность аренды которых более 5 дней
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней

select f.title, c."name"
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
group by c.category_id, f.film_id
having avg(f.rental_duration) > 5

select f.title, count(fa.actor_id)
from film f
left join film_actor fa on fa.film_id = f.film_id
left join actor a on a.actor_id = fa.actor_id
group by f.film_id

============= подзапросы =============

5. Выведите количество фильмов, со стоимостью аренды за день больше, чем среднее значение по всем фильмам
* Напишите подзапрос, который будет вычислять среднее значение стоимости аренды за день (задание 3.1)
* Используйте таблицу film
* Отфильтруйте строки в результирующей таблице, используя опретаор > (подзапрос)
* count - агрегатная функция подсчета значений

select avg(rental_rate/rental_duration) from film 

select f.title, rental_rate/rental_duration, (select avg(rental_rate/rental_duration) from film )
from film f
where rental_rate/rental_duration > (select avg(rental_rate/rental_duration) from film )


6. Выведите фильмы, с категорией начинающейся с буквы "C"
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"
--position and time

select category_id, name
from category
where name like 'C%'

explain analyze
select f.title, c."name"
from film f
left join film_category fc on f.film_id = fc.film_id
left join category c on c.category_id = fc.category_id
where fc.category_id in (
	select category_id
	from category
	where name like 'C%') --54.86 / 0.55мс

explain analyze
select f.title, t."name"
from (
	select category_id, name
	from category
	where name like 'C%') as t
right join film_category fc on t.category_id = fc.category_id
right join film f on f.film_id = fc.film_id
where t.name is not null --53.29 / 0.475мс

explain analyze
select f.title, t."name"
from (
	select category_id, name
	from category
	where name like 'C%') as t
left join film_category fc on t.category_id = fc.category_id
left join film f on f.film_id = fc.film_id --53.29 / 0.475мс

explain analyze
select f.title, c."name"
from film f
left join film_category fc on f.film_id = fc.film_id
left join 
	(select category_id, name
	from category
	where name like 'C%') c on c.category_id = fc.category_id
where c.name is not null --53.29 / 0.475мс

explain analyze
select f.title, c."name"
from film f
left join film_category fc on fc.film_id = f.film_id and fc.category_id in (
	select category_id
	from category
	where name like 'C%')
left join category c on fc.category_id = c.category_id
where c.category_id is not null --47.11 / 0.465мс
	

6.1. Выведите фильмы, с категорией начинающейся с буквы "C", но используйте данные подзапроса в условии фильтрации
* Используйте таблицу film
* Соедините с таблицей film_category
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Используйте результат работы подзапроса в фильтрации с помощью оператора in



7. Выведите таблицу с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by
-- разбор 2 доп kcu

select tc.table_name, tc.constraint_name, c.column_name, c.data_type
from information_schema.table_constraints tc
left join information_schema.key_column_usage kcu on kcu.table_name = tc.table_name
	and tc.constraint_name = kcu.constraint_name
	and tc.constraint_schema = kcu.constraint_schema
left join information_schema.columns c on c.table_name = kcu.table_name
	and c.column_name = kcu.column_name
where tc.constraint_schema = 'dvd-rental' and tc.constraint_type = 'PRIMARY KEY'

--424 / 252 / 144 / 24

pg_modeler

select tc.table_name, tc.constraint_name
from information_schema.table_constraints tc
where tc.constraint_schema = 'dvd-rental' and tc.constraint_type = 'PRIMARY KEY'

select tc.table_name, tc.constraint_name
from information_schema.table_constraints tc
left join information_schema.key_column_usage kcu on kcu.table_name = tc.table_name
where tc.constraint_schema = 'dvd-rental' and tc.constraint_type = 'PRIMARY KEY'