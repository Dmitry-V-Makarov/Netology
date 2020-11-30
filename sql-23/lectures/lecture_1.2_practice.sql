1. �������� �������� id ������, ��������, ��������, ��� ������ �� ������� ������.
������������ ���� ���, ����� ��� ��� ���������� �� ����� Film (FilmTitle ������ title � ��)

- ����������� ER - ���������, ����� ����� ���������� �������
- as - ��� ������� ��������� 

select film_id as Filmfilm_id, title as Filmtitle, description Filmdescription, release_year Filmrelease_year
from film

select 
	film_id as "Filmfilm_id", 
	title as "Filmtitle", 
	description "�������� ������", 
	release_year "Film release year"
from 
	film

2. � ����� �� ������ ���� ��� ��������:
rental_duration - ����� ������� ������ � ����  
rental_rate - ��������� ������ ������ �� ���� ���������� �������. 
��� ������� ������ �� ������ ������� �������� ��������� ��� ������ � ����

- ����������� ER - ���������, ����� ����� ���������� �������
- ��������� ������ � ���� - ��������� rental_rate � rental_duration

select film_id, title, rental_duration/rental_rate
from film f

2* � ���������� ������� ������� ������������ ������� ��������� cost_per_day

- as - ��� ������� ��������� 

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


3.1 ������������� ������ ������� �� �������� ��������� �� ���� ������ (�.2)

- ����������� order by (�� ��������� ��������� �� �����������)
- desc - ���������� �� ��������

select film_id, title, rental_rate/rental_duration as cost_per_day
from film f
order by cost_per_day desc

select film_id, title, round(rental_rate/rental_duration, 2) as cost_per_day
from film f
order by cost_per_day desc

round(1 / 2, 2) = 0 

3.1* ������������ ������ �������� �� ����������� ����� ������� (amount)

- ����������� ER - ���������, ����� ����� ���������� �������
- ����������� order by 
- asc - ���������� �� ����������� 

select payment_id, amount
from payment
order by amount, payment_id desc

3.2 ������� ���-10 ����� ������� ������� �� ��������� �� ���� ������

- ����������� limit

select film_id, title, rental_rate/rental_duration as cost_per_day
from film f
order by cost_per_day desc
limit 10

3.3 ������� ���-5 ����� ������� ������� �� ��������� ������ �� ����, ������� � 4-�� �������

- �������������� Limit � offset

select film_id, title, rental_rate/rental_duration as cost_per_day
from film f
order by cost_per_day desc
offset 57
limit 10

3.3* ������� ���-15 ����� ������ ��������, ������� � ������� 14000

- �������������� Limit � Offset

select payment_id, amount
from payment 
order by amount
offset 13999
limit 15

4. ������� ��� ���������� ���� ������� �������

- �������������� distinct

select distinct release_year
from film

select distinct release_year, film_id
from film

select distinct extract(year from payment_date)
from payment 

select * from film_actor fa

4* ������� ���������� ����� �����������

- ����������� ER - ���������, ����� ����� ���������� �������
- �������������� distinct

select distinct first_name
from customer


==========

���������� �������

FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE ��� WITH ROLLUP
HAVING
select <-- ��������� ������ (����������)
DISTINCT
ORDER BY

������, ���������



����������

select tc.table_name, tc.constraint_name 
from information_schema.table_constraints tc
where tc.constraint_schema = 'public' and tc.constraint_type = 'PRIMARY KEY'

��������_�����.��������_������� --from
��������_�������.��������_������� --select

==========

5.1. ������� ���� ������ �������, ������� ������� 'PG-13', � ����: "�������� - ��� �������"

- ����������� ER - ���������, ����� ����� ���������� �������
- "||" - �������� ������������ 
- where - ����������� ����������
- "=" - �������� ���������

select title || ' - ' || release_year, rating
from film 

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

5.2 ������� ���� ������ �������, ������� �������, ������������ �� 'PG'

- cast(�������� ������� as ���) - ��������������
- like - ����� �� �������
- ilike - ������������������� �����

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

5.2* �������� ���������� �� ����������� � ������ ���������� ���������'jam' (���������� �� �������� ���������), � ����: "��� �������" - ����� �������.

- "||" - �������� ������������
- where - ����������� ����������
- ilike - ������������������� �����

select concat(first_name, ' ', last_name), 
	lower(concat(first_name, ' ', last_name)),
	upper(concat(first_name, ' ', last_name))
from customer
where first_name ilike '%jam%'

select amount
from payment
where amount::text like '7%'

6. �������� id �����������, ������������ ������ � ���� � 27-05-2005 �� 28-05-2005 ������������

- ����������� ER - ���������, ����� ����� ���������� �������
- between - ������ ���������� (������ ... >= ... and ... <= ...)

select customer_id, rental_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005'
-- where rental_date between '2005-05-27' and '2005-05-28' ���� ������

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

6* ������� ������� ����������� ����� 30-04-2007

- ����������� ER - ���������, ����� ����� ���������� �������
- > - ������� ������ (< - ������� ������)

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
	' �������� ', 
	date_part('month', date('28-02-2020')), 
	' ������� ����� ', 
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

