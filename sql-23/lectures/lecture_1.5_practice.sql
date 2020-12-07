============= ������� ������� =============

1. �������� ������� � 3-�� ������: �������� ������, ��� ������ � ���������� �������, � ������� �� ��������
* ����������� ������� film
* ��������� � film_actor
* ��������� � actor
* count - ���������� ������� �������� ��������
* ������� ���� � �������������� ����������� over � partition by

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

1.1. �������� �������, ���������� ����� �����������, ������������ ��� ������ � ������� ������ ������� ����������
* ����������� ������� customer
* ��������� � paymen
* ��������� � rental
* ��������� � inventory
* ��������� � film
* avg - �������, ����������� ������� ��������
* ������� ���� � �������������� ����������� over � partition by

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

============= ����� ��������� ��������� =============

2.  ��� ������ CTE �������� ������� �� ��������� �����������:
������� � ��� ���������� (staff) � ���������� �������� ��� (retal), ������� �� ������
* �������� CTE:
 - ����������� ������� staff
 - ��������� � rental
 - || - �������� ������������
 * �������� ������ � ���������� CTE:
 - ������������ �� fio
 - count - ���������� ������� �������� ��������
 - �������� �������� � ����: fio, ���������� ��������(rental_id)

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
 
2.1. �������� ������, � ���������� ������������ � ����� "C"
* �������� CTE:
 - ����������� ������� category
 - ������������ ������ � ������� ��������� like 
* ��������� ���������� ��������� ��������� � �������� film_category
* ��������� � �������� film
* �������� ���������� � �������:
title, category."name"

 
 ============= ����� ��������� ��������� (�����������) =============
 
 3.��������� ���������
 + �������� CTE
 * ��������� ����� �������� (�.�. "anchor") ������ ��������� ��������� ��������� ��������
 *  ����������� ����� ��������� �� ������ � ���������� �������� � ����� ������� ��������
 + �������� ������ � CTE
 
 with recursive r as (
 	--��������� ����� ��������
 	select 
 		1 as i,
 		1 as factorial
	union
	-- ����������� �����
	select
		r.i + 1 as i,
		r.factorial * (r.i + 1) as factorial
	from r
	where i < 10
 )
select * 
from r

 3.1. ����� ���������
 F0 = 0
 F1 = 1
 F(n+1) = F(n) + F(n-1)
 �������� ������, ����������� ������� ����� ��������� �� 1 �� 15
  * ��������� ����� �������� (�.�. "anchor") ������ ��������� ��������� ��������� ��������
 *  ����������� ����� ��������� �� ������ � ���������� �������� � ����� ������� ��������
 + �������� ������ � CTE

 create table geo ( 
	id int primary key, 
	parent_id int references geo(id), 
	name varchar(1000) );

insert into geo (id, parent_id, name)
values 
	(1, null, '������� �����'),
	(2, 1, '��������� �������'),
	(3, 1, '��������� �������� �������'),
	(4, 2, '������'),
	(5, 4, '������'),
	(6, 4, '��������'),
	(7, 5, '������'),
	(8, 5, '�����-���������'),
	(9, 6, '������');

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
 

============= ������������� =============

4. �������� view � ��������� ������ (���; email) � title ������, ������� �� ���� � ������ ���������
+ �������� �������������:
* �������� CTE, 
- ���������� ������ �� ������� rental, 
- ��������� ����������� row_number() � ���� �� customer_id
- ����������� � ���� ���� �� rental_date �� �������� (desc)
* ���������� customer � ���������� cte 
* ��������� � inventory
* ��������� � film
* ������������ �� row_number = 1

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

4.1. �������� ������������� � 3-�� ������: �������� ������, ��� ������ � ���������� �������, � ������� �� ��������
+ �������� �������������:
* ����������� ������� film
* ��������� � film_actor
* ��������� � actor
* count - ���������� ������� �������� ��������
* ������� ���� � �������������� ����������� over � partition by

create or replace view p5_23_2 as 
	select f.title, a.last_name, count(f.film_id) over (partition by a.actor_id)
	from film f
	inner join film_actor fa on fa.film_id = f.film_id
	inner join actor a on a.actor_id = fa.actor_id
	
select * from p5_23_2

============= ����������������� ������������� =============

5. �������� ���������������� ������������� � ��������� ������ (���; email) � title ������, ������� �� ���� � ������ ���������
�������������� ���������� � �������� ������ � �������������.
+ �������� ����������������� ������������� ��� ���������� (with NO DATA):
* �������� CTE, 
- ���������� ������ �� ������� rental, 
- ��������� ����������� row_number() � ���� �� customer_id
- ����������� � ���� ���� �� rental_date �� �������� (desc)
* ���������� customer � ���������� cte 
* ��������� � inventory
* ��������� � film
* ������������ �� row_number = 1
+ �������� �������������
+ �������� ������

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

5.1. ������� ���������� ����������������� �������������, ����������:
������ ��������� �������, ������� ����������������� ������ ������� ����� 5 ����
+ �������� ����������������� ������������� � ����������� (with DATA)
* ����������� ������� film
* ��������� � �������� film_category
* ��������� � �������� category
* ������������ ���������� ������� �� category.name
* ��� ������ ������ ���������� ������ ����������������� ������ �������
* �������������� ����������� �����, ��� ������ ��������� �� ������� ������������������ > 5 ����
 + �������� ������
 
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

 ������ �� ������ �� ������� ����� ������� https://explain.depesz.com/
 
 https://habr.com/ru/post/203320/
 
select * 
from information_schema."tables" t
where table_type = 'VIEW' and table_schema = 'dvd-rental'