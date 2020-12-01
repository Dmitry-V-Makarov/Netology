create schema p4

======================== �������� ������ ========================

1. �������� ������� "�����" � ������:
- id 
- ���
- ��������� (����� �� ����)
- ���� ��������
* ����������� 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* ��� id �������� serial, ����������� primary key
* ��� � ���� �������� - not null
* ��������� - ����������� ���

create table author (
	id serial primary key,
	author_name varchar(100) not null,
	nick_name varchar(50),
	born_date date not null
)

select * from author


1*  �������� ������� "������������" � ������: id ������������, ���, ��������, id ������
* ��� id ������������ �������� serial, ����������� primary key
* �������� - not null
* ��� > 0 CHECK (��� > 0)
* id ������ ���� �������� ��� �����������

create table books (
	id serial primary key,
	book_name varchar(100) not null,
	book_year int2 check (book_year > 0 and book_year < 2100),
	author_id int
)

int2 = smallint
int4 = integer
int8 = bigint
-32768 +32767 / 0 +65535

select * from books

set search_path to ���_�����

======================== ���������� ������� ========================

2. �������� ������ �� 3-� ����� ��������� � ������� �������:
���� �������� ����, 08.02.1828
������ ������� ���������, ��. ���������, 03.10.1814
������ ��������, 12.01.1949
* ����� ��������� ��������� ����� ������������:
    INSERT INTO table (column1, column2, �)
    VALUES
     (value1, value2, �),
     (value1, value2, �) ,...;
    
insert into author (author_name, nick_name, born_date)
values 
	('���� �������� ����', null, '08.02.1828'),
	('������ ������� ���������', '��. ���������', '03.10.1814'),
	('������ ��������', null, '12.01.1949')
    
select * from author
     
2. �������� ������ �� 5-� ����� �������������, id ������ - ��������� NULL:
�������� ����� ��� ��� �����, 1916
��������, 1837
����� ������ �������, 1840
���������� ���, 1980
������� �������� �����, 1994

insert into books (book_name, book_year, author_id)
values 
	('�������� ����� ��� ��� �����', 1916, null),
	('��������', 1837, null),
	('����� ������ �������', 1840, null),
	('���������� ���', 1980, null),
	('������� �������� �����', 1994, null)
	
select * from books

insert into books (book_name, book_year, author_id)
values 
	('�������� ����� ��� ��� �����', 1916, 3)
	
delete from books

insert into books (book_name, book_year)
select 
	unnest(array['�������� ����� ��� ��� �����', '��������', '����� ������ �������', '���������� ���', '������� �������� �����']),
	unnest(array[1916, 1837, 1840, 1980, 1994])

select unnest(array[1, 2, 3])
	
======================== ����������� ������� ========================

3. �������� ���� "����� ��������" � �������
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;

alter table author add column born_place varchar(50) 

select * from author
 
 3* � ������� ������������ �������� ������� id ������ - ������� ���� - ������ �� �������
 * ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition
 
alter table books add constraint book_author_fkey foreign key (author_id) references author(id)

alter table books drop constraint book_author_fkey

select * from books

 ======================== ����������� ������ ========================

4. �������� ������, ��������� ���������� ����� ��������
��������:
���� �������� ���� - �������
������ ������� ��������� - ���������� �������
������ �������� - ������
* UPDATE table
  SET column1 = value1,
   column2 = value2 ,...
  WHERE
   condition;

update author
set born_place = '�������'
where id = 1

update author
set born_place = '���������� �������'
where id between 1 and 3

update author
set born_place = '������'
where id = 3

update author
set born_place = '�������'

select * from author

4*. � ������� ������������ ���������� id �������:

���� �������� ����: 
    �������� ����� ��� ��� �����
������ ������� ���������: 
    ��������
    ����� ������ �������
������ ��������:
    ���������� ���
    ������� �������� �����
 
update books
set author_id = 4
where id = 17

update books
set author_id = 5
where id = 18 or id = 19

update books
set author_id = (select id from author where author_name = '������ ��������')
where id in (20, 21)

select * from books b
 
 ======================== �������� ������ ========================
 
 5. ������� ������������ " �������� ����� ��� ��� �����"

delete from books
where id = 10

delete from books
 
 5* ���������� ������� �������� ������ ��������, ������� �������� ���� ������?�� ����
 
delete from author 
where id = 4

truncate author cascade

select * from author a

drop table books

drop table author

drop schema p4

 ======================================================= ������� ���� ������ =======================================================
 
 ======================== json ========================
 �������� ������� orders
 
 CREATE TABLE orders (
     ID serial NOT NULL PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{ "customer": "John Doe", "items": {"product": "Beer","qty": 6}}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
 );
 
select * from orders

customer: '���', purchase: {[product_id: 5, qty: 2], [product_id: 7, qty: 3]}

customer - purchase
purchase - product - qty

|{��������_������: quantity, product_id: quantity, product_id: quantity}|����� ����� ������|


6. �������� ����� ���������� �������:
* CAST ( data AS type) �������������� �����
* SUM - ���������� ������� �����
* -> ���������� JSON
*->> ���������� �����

select pg_typeof(info->'customer')
from orders

select pg_typeof(info->>'customer')
from orders

select sum((info->'items'->>'qty')::int)
from orders

6*  �������� ������� ���������� �������, ��������� ������������ �� "Toy"

select avg((info->'items'->>'qty')::int)
from orders
where info->'items'->>'product' like 'Toy%'

======================== array ========================
7. �������� ������� ��� ����������� ����������� ������� (special_features) �
������ -- ������� ��������� �������� ������� special_features
* array_length(anyarray, int) - ���������� ����� ��������� ����������� �������

select special_features, array_length(special_features, 1)
from film

select special_features, array_length(special_features, 2)
from film

select array_length(array[1,2,3,4,5], 1)

select array_length('{{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}}'::text[], 2)

7* �������� ��� ������ ���������� ����������� ��������: 'Trailers','Commentaries'
* ����������� ���������:
@> - ��������
<@ - ���������� �
*  ARRAY[��������] - ��� �������� �������

-- ������ �������� -- 

select title, special_features
from film
where special_features::text ilike '%Trailers%' or special_features::text ilike '%comm%'

select distinct title
from (
	select title, unnest(special_features) sf
	from film) as t
where t.sf = 'Trailers' or t.sf = 'Commentaries'

select title, special_features
from film
where special_features[1] = 'Trailers' or special_features[1] = 'Commentaries' or
	special_features[2] = 'Trailers' or special_features[2] = 'Commentaries' or
	special_features[3] = 'Trailers' or special_features[3] = 'Commentaries' or
	special_features[4] = 'Trailers' or special_features[4] = 'Commentaries' or
	special_features[5] = 'Trailers' or special_features[5] = 'Commentaries'
	
-- ������� �������� -- 

select title, special_features
from film
where array_position(special_features, 'Trailers') is not null or
	array_position(special_features, 'Commentaries') is not null
	

array_position -- ���������� ������ ���������
array_positions -- ���������� ������ ���� ���������

select title, special_features
from film
where special_features && array['Trailers'] or
	special_features && array['Commentaries']
	
select title, special_features
from film
where special_features @> array['Trailers'] or
	special_features @> array['Commentaries']
	
select title, special_features
from film
where special_features <@ array['Trailers'] or
	special_features <@ array['Commentaries'] or
	special_features <@ array['Commentaries','Trailers']
	
select title, special_features
from film
where 'Trailers' = any(special_features) or
	'Commentaries' = any(special_features) -- some - ������� 
	
select title, special_features
from film
where 'Trailers' = all(special_features) or
	'Commentaries' = all(special_features)
	
https://postgrespro.ru/docs/postgresql/12/functions-subquery

https://postgrespro.ru/docs/postgrespro/12/functions-array
