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
		else '�����-�� ��������� ��� ��������� �������'::text
	end
from
	(select *
	from table_one t1
	full outer join table_two t2 on t1.name_one = t2.name_two
	where name_one is null or name_two is null) as t


============= ���������� =============

1. �������� ������ �������� ���� ������� � �� ������ (������� language)
* ����������� ������� film
* ��������� � language
* �������� ���������� � �������:
title, language."name"

select f.title, l."name"
from film f
left join "language" l on f.language_id = l.language_id

1.1 �������� ��� ������ � �� ���������:
* ����������� ������� film
* ��������� � �������� film_category
* ��������� � �������� category
* �������� ���������� � �������:
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

2. �������� ������ ���� �������, ����������� � ������ Lambs Cincinatti (film_id = 508). 
* ����������� ������� film
* ��������� � film_actor
* ��������� � actor
* ������������, ��������� where � "title like" (��� ��������) ��� "film_id =" (��� id)

select f.title, concat(a.last_name, ' ', a.first_name) -- a.last_name || ' ' || a.first_name
from film f
left join film_actor fa on f.film_id = fa.film_id
left join actor a on a.actor_id = fa.actor_id
where f.film_id = 508

2.1 �������� ��� �������� �� ������ Woodridge (city_id = 576)
* ����������� ������� store
* ��������� ������� � address 
* ��������� ������� � city 
* ��������� ������� � country 
* ������������ , ��������� where � "city like" (��� �������� ������) ��� "city_id ="  (��� id)
* �������� ������ ����� ������� ��������� � �� id:
store_id, postal_code, country, city, district, address, address2, phone

select s.store_id, a.postal_code, c2.country, c.city, a.district, a.address, a.address2, a.phone
from store s
left join address a on a.address_id = s.address_id
left join city c on c.city_id = a.city_id
left join country c2 on c.country_id = c2.country_id
where c.city_id = 576

============= ���������� ������� =============

3. ����������� ���������� ������� � ������ Grosse Wonderful (id - 384)
* ����������� ������� film
* ��������� � film_actor
* ������������, ��������� where � "title like" (��� ��������) ��� "film_id =" (��� id) 
* ��� �������� ����������� ������� count, ����������� actor_id � �������� ��������� ������ �������
--�� count(f.film_id) / count(fa.film_id)

select f.title, count(fa.actor_id)
from film f
left join film_actor fa on fa.film_id = f.film_id
where f.film_id = 384
group by f.film_id

-- ������� ��������
select f.title, count(fa.actor_id), f.description
from film f
left join film_actor fa on fa.film_id = f.film_id
group by f.film_id

-- ������ ��������
select f.title, count(fa.actor_id), f.description
from film f
left join film_actor fa on fa.film_id = f.film_id
group by fa.film_id, f.title, f.description

FROM
ON
JOIN
WHERE
GROUP by --�����, �� �� � ������ ���� ��� �����������
WITH CUBE ��� WITH ROLLUP
HAVING
select --������ 
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

3.1 ���������� ������� ��������� ������ �� ���� �� ���� �������
* ����������� ������� film
* ��������� ������ �� ���� rental_rate/rental_duration
* avg - �������, ����������� ������� ��������
--4 ���������

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

============= ����������� =============

4. �������� ������ �������, � ������� ��������� ������ 10 �������

* ����������� ������� film
* ��������� � film_actor
* ������������ �������� ������� �� film_id
* ��� ������ ������ ���������� ����������� �������
* �������������� ����������� �����, ��� ������ ������� � ������������ > 10
--having, numeric, alias

select f.title, count(fa.actor_id)
from film f
left join film_actor fa on fa.film_id = f.film_id
group by f.film_id
having count(fa.actor_id) > 10

/*select distinct f.title
from film f
left join film_actor fa on fa.film_id = f.film_id*/


4.1 �������� ������ ��������� �������, ������� ����������������� ������ ������� ����� 5 ����
* ����������� ������� film
* ��������� � �������� film_category
* ��������� � �������� category
* ������������ ���������� ������� �� category.name
* ��� ������ ������ ���������� ������ ����������������� ������ �������
* �������������� ����������� �����, ��� ������ ��������� �� ������� ������������������ > 5 ����

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

============= ���������� =============

5. �������� ���������� �������, �� ���������� ������ �� ���� ������, ��� ������� �������� �� ���� �������
* �������� ���������, ������� ����� ��������� ������� �������� ��������� ������ �� ���� (������� 3.1)
* ����������� ������� film
* ������������ ������ � �������������� �������, ��������� �������� > (���������)
* count - ���������� ������� �������� ��������

select avg(rental_rate/rental_duration) from film 

select f.title, rental_rate/rental_duration, (select avg(rental_rate/rental_duration) from film )
from film f
where rental_rate/rental_duration > (select avg(rental_rate/rental_duration) from film )


6. �������� ������, � ���������� ������������ � ����� "C"
* �������� ���������:
 - ����������� ������� category
 - ������������ ������ � ������� ��������� like 
* ��������� � �������� film_category
* ��������� � �������� film
* �������� ���������� � �������:
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
	where name like 'C%') --54.86 / 0.55��

explain analyze
select f.title, t."name"
from (
	select category_id, name
	from category
	where name like 'C%') as t
right join film_category fc on t.category_id = fc.category_id
right join film f on f.film_id = fc.film_id
where t.name is not null --53.29 / 0.475��

explain analyze
select f.title, t."name"
from (
	select category_id, name
	from category
	where name like 'C%') as t
left join film_category fc on t.category_id = fc.category_id
left join film f on f.film_id = fc.film_id --53.29 / 0.475��

explain analyze
select f.title, c."name"
from film f
left join film_category fc on f.film_id = fc.film_id
left join 
	(select category_id, name
	from category
	where name like 'C%') c on c.category_id = fc.category_id
where c.name is not null --53.29 / 0.475��

explain analyze
select f.title, c."name"
from film f
left join film_category fc on fc.film_id = f.film_id and fc.category_id in (
	select category_id
	from category
	where name like 'C%')
left join category c on fc.category_id = c.category_id
where c.category_id is not null --47.11 / 0.465��
	

6.1. �������� ������, � ���������� ������������ � ����� "C", �� ����������� ������ ���������� � ������� ����������
* ����������� ������� film
* ��������� � �������� film_category
* �������� ���������:
 - ����������� ������� category
 - ������������ ������ � ������� ��������� like 
* ����������� ��������� ������ ���������� � ���������� � ������� ��������� in



7. �������� ������� � 3-�� ������: �������� ������, ��� ������ � ���������� �������, � ������� �� ��������
* ����������� ������� film
* ��������� � film_actor
* ��������� � actor
* count - ���������� ������� �������� ��������
* ������� ���� � �������������� ����������� over � partition by
-- ������ 2 ��� kcu

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