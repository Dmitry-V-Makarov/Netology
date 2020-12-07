============= оконные функции =============

1. Выведите таблицу с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

select f.title, a.last_name, count(f.film_id)
from film f
inner join film_actor fa on fa.film_id = f.film_id
inner join actor a on a.actor_id = fa.actor_id
group by a.actor_id, f.title

select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
from film f
inner join film_actor fa on fa.film_id = f.film_id
inner join actor a on a.actor_id = fa.actor_id

select f.title, a.last_name
from film f
inner join film_actor fa on fa.film_id = f.film_id
inner join actor a on a.actor_id = fa.actor_id

select * from film_actor fa

1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж каждого покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

explain analyze
select distinct c.last_name, f.title, avg(p.amount) over (partition by c.customer_id)
from customer c
left join payment p on p.customer_id = c.customer_id
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
order by c.last_name --405315

explain analyze
select c.last_name, f.title, avg(p.amount)
from customer c
left join payment p on p.customer_id = c.customer_id
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
group by c.customer_id, f.film_id
order by c.last_name --15828

select c.last_name, f.title, p.payment_date,
	avg(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (partition by c.customer_id),
	min(p.amount) over (partition by c.customer_id),
	max(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (partition by c.customer_id, date(p.payment_date) order by r.rental_id)
from customer c
left join payment p on p.customer_id = c.customer_id
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
order by c.last_name, p.payment_date, r.rental_id

select distinct c.customer_id, p.payment_date,
	sum(p.amount) over (partition by c.customer_id, date(p.payment_date) order by r.rental_id)
from customer c
left join payment p on p.customer_id = c.customer_id
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
order by c.customer_id, p.payment_date

select c.customer_id, p.payment_date,
	sum(p.amount) over (partition by c.customer_id, date(p.payment_date) order by r.rental_id),
	p.amount, r.rental_id
from customer c 
left join payment p on p.customer_id = c.customer_id
left join rental r on r.customer_id = c.customer_id 
left join inventory i on r.inventory_id = i.inventory_id
left join film f on f.film_id = i.film_id
order by c.customer_id, p.payment_date, r.rental_id

select c.customer_id, p.payment_id,
	lag(p.amount) over (partition by c.customer_id),
	p.amount,
	lead(p.amount) over (partition by c.customer_id)
from customer c
left join payment p on p.customer_id = c.customer_id

select * 
from (
	select c.customer_id, p.payment_id, date_trunc('month', p.payment_date),
		lag(p.amount) over (partition by date_trunc('month', p.payment_date)),
		p.amount,
		lead(p.amount) over (partition by date_trunc('month', p.payment_date)),
		p.amount - lag(p.amount) over (partition by date_trunc('month', p.payment_date)) as r
	from customer c
	left join payment p on p.customer_id = c.customer_id) as t
where t.r < 0

============= общие табличные выражения =============

2.  При помощи CTE выведите таблицу со следующим содержанием:
Фамилия и Имя сотрудника (staff) и количество прокатов двд (retal), которые он продал
* Создайте CTE:
 - Используйте таблицу staff
 - соедините с rental
 - || - оператор конкатенации
 * напишите запрос к полученной CTE:
 - сгруппируйте по fio
 - count - агрегатная функция подсчета значений
 - выведите значения в виде: fio, количество прокатов(rental_id)

with st_r as (
	select s.last_name, s.staff_id, r.rental_id
	from staff s
	left join rental r on r.staff_id = s.staff_id),
sum_total as (
	select sum(amount), p.rental_id
	from payment p
	group by p.rental_id 
	having sum(amount) > 0)	
select st_r.last_name, count(st_r.rental_id) / st.sum
from st_r
left join sum_total st on st.rental_id = st_r.rental_id
group by st_r.staff_id, st_r.last_name, st.sum
 
2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"

 
 ============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие останова
 + Напишите запрос к CTE
 
 with recursive r as (
 	--стартовая часть рекурсии
 	select 
 		1 as i,
 		1 as factorial
	union
	-- рекурсивная часть
	select
		r.i + 1 as i,
		r.factorial * (r.i + 1) as factorial
	from r
	where i < 10
 )
select * 
from r

 3.1. Числа Фиббоначи
 F0 = 0
 F1 = 1
 F(n+1) = F(n) + F(n-1)
 Напишите скрипт, позволяющий вывести числа Фиббоначи от 1 до 15
  * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие останова
 + Напишите запрос к CTE

 create table geo ( 
	id int primary key, 
	parent_id int references geo(id), 
	name varchar(1000) );

insert into geo (id, parent_id, name)
values 
	(1, null, 'Планета Земля'),
	(2, 1, 'Континент Евразия'),
	(3, 1, 'Континент Северная Америка'),
	(4, 2, 'Европа'),
	(5, 4, 'Россия'),
	(6, 4, 'Германия'),
	(7, 5, 'Москва'),
	(8, 5, 'Санкт-Петербург'),
	(9, 6, 'Берлин');

select * from geo
 
with recursive r as (
	select id, parent_id, name
		from geo
		where parent_id = 2
	union
	select geo.id, geo.parent_id, geo.name
		from geo
		join r on geo.parent_id = r.id 
)
select *
from r;

with recursive r as (
	select id, parent_id, name, 1 as level
		from geo
		where parent_id = 2
	union
	select geo.id, geo.parent_id, geo.name--, r.level + 1 as level
		from geo
		join r on geo.parent_id = r.id )
select *
from r;
 

============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

create or replace view p5_23 as
	with cte_1 as (
		select *, row_number() over (partition by r.customer_id order by r.rental_date desc) as lr
		from rental r)
	select c.last_name, c.email, f.title
	from cte_1
	left join customer c on c.customer_id = cte_1.customer_id
	left join inventory i on i.inventory_id = cte_1.inventory_id
	left join film f on f.film_id = i.film_id
	where cte_1.lr = 1
	
select * from p5_23

4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create or replace view p5_23_2 as 
	select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
	from film f
	inner join film_actor fa on fa.film_id = f.film_id
	inner join actor a on a.actor_id = fa.actor_id
	
select * from p5_23_2

============= материализованные представления =============

5. Создайте матеиализованное представление с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные

create materialized view m_v_1 as 
	with cte_1 as (
		select *, row_number() over (partition by r.customer_id order by r.rental_date desc) as lr
		from rental r)
	select c.last_name, c.email, f.title
	from cte_1
	left join customer c on c.customer_id = cte_1.customer_id
	left join inventory i on i.inventory_id = cte_1.inventory_id
	left join film f on f.film_id = i.film_id
	where cte_1.lr = 1
with no data;

explain analyze
	with cte_1 as (
		select *, row_number() over (partition by r.customer_id order by r.rental_date desc) as lr
		from rental r)
	select c.last_name, c.email, f.title
	from cte_1
	left join customer c on c.customer_id = cte_1.customer_id
	left join inventory i on i.inventory_id = cte_1.inventory_id
	left join film f on f.film_id = i.film_id
	where cte_1.lr = 1 --2291 / 23

refresh materialized view m_v_1

explain analyze
select * from m_v_1 --13 / 0.068

select 23/0.068

5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные
 
create materialized view m_v_2 as
	select f.title, c."name"
	from film f
	inner join film_category fc on fc.film_id = f.film_id
	inner join category c on c.category_id = fc.category_id
	group by c.category_id, f.film_id
	having avg(f.rental_duration) > 5
with data

select * from m_v_2

explain analyze
	with cte_1 as (
		select *, row_number() over (partition by r.customer_id order by r.rental_date desc) as lr
		from rental r)
	select c.last_name, c.email, f.title
	from cte_1
	left join customer c on c.customer_id = cte_1.customer_id
	left join inventory i on i.inventory_id = cte_1.inventory_id
	left join film f on f.film_id = i.film_id
	where cte_1.lr = 1 --2291 / 23

 Ссылка на сервис по анализу плана запроса https://explain.depesz.com/
 
 https://habr.com/ru/post/203320/
 
select * 
from information_schema."tables" t
where table_type = 'VIEW' and table_schema = 'dvd-rental'