create schema p4

======================== Создание таблиц ========================

1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* псевдоним - ограничений нет

create table author (
	id serial primary key,
	author_name varchar(100) not null,
	nick_name varchar(50),
	born_date date not null
)

select * from author


1*  Создайте таблицу "Произведения" с полями: id произведения, год, название, id автора
* для id произведения подойдет serial, ограничение primary key
* название - not null
* год > 0 CHECK (год > 0)
* id автора пока оставьте без ограничений

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

set search_path to имя_схемы

======================== Заполнение таблицы ========================

2. Вставьте данные по 3-м любым писателям в таблицу авторов:
Жюль Габриэль Верн, 08.02.1828
Михаил Юрьевич Лермонтов, Гр. Диарбекир, 03.10.1814
Харуки Мураками, 12.01.1949
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;
    
insert into author (author_name, nick_name, born_date)
values 
	('Жюль Габриэль Верн', null, '08.02.1828'),
	('Михаил Юрьевич Лермонтов', 'Гр. Диарбекир', '03.10.1814'),
	('Харуки Мураками', null, '12.01.1949')
    
select * from author
     
2. Вставьте данные по 5-м любым произведениям, id автора - заполните NULL:
Двадцать тысяч льё под водой, 1916
Бородино, 1837
Герой нашего времени, 1840
Норвежский лес, 1980
Хроники заводной птицы, 1994

insert into books (book_name, book_year, author_id)
values 
	('Двадцать тысяч льё под водой', 1916, null),
	('Бородино', 1837, null),
	('Герой нашего времени', 1840, null),
	('Норвежский лес', 1980, null),
	('Хроники заводной птицы', 1994, null)
	
select * from books

insert into books (book_name, book_year, author_id)
values 
	('Двадцать тысяч льё под водой', 1916, 3)
	
delete from books

insert into books (book_name, book_year)
select 
	unnest(array['Двадцать тысяч льё под водой', 'Бородино', 'Герой нашего времени', 'Норвежский лес', 'Хроники заводной птицы']),
	unnest(array[1916, 1837, 1840, 1980, 1994])

select unnest(array[1, 2, 3])
	
======================== Модификация таблицы ========================

3. Добавьте поле "место рождения" в таблицу
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;

alter table author add column born_place varchar(50) 

select * from author
 
 3* В таблице произведений измените колонку id автора - внешний ключ - ссылка на авторов
 * ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition
 
alter table books add constraint book_author_fkey foreign key (author_id) references author(id)

alter table books drop constraint book_author_fkey

select * from books

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное место рождения
писателю:
Жюль Габриэль Верн - Франция
Михаил Юрьевич Лермонтов - Российская Империя
Харуки Мураками - Япония
* UPDATE table
  SET column1 = value1,
   column2 = value2 ,...
  WHERE
   condition;

update author
set born_place = 'Франция'
where id = 1

update author
set born_place = 'Российская Империя'
where id between 1 and 3

update author
set born_place = 'Япония'
where id = 3

update author
set born_place = 'Франция'

select * from author

4*. В таблице произведений проставьте id авторов:

Жюль Габриэль Верн: 
    Двадцать тысяч льё под водой
Михаил Юрьевич Лермонтов: 
    Бородино
    Герой нашего времени
Харуки Мураками:
    Норвежский лес
    Хроники заводной птицы
 
update books
set author_id = 4
where id = 17

update books
set author_id = 5
where id = 18 or id = 19

update books
set author_id = (select id from author where author_name = 'Харуки Мураками')
where id in (20, 21)

select * from books b
 
 ======================== Удаление данных ========================
 
 5. Удалите произведение " Двадцать тысяч льё под водой"

delete from books
where id = 10

delete from books
 
 5* Попробуйте удалить писателя Харуки Мураками, удалите писателя Жюль Габриэ?ль Верн
 
delete from author 
where id = 4

truncate author cascade

select * from author a

drop table books

drop table author

drop schema p4

 ======================================================= Сложные типы данных =======================================================
 
 ======================== json ========================
 Создайте таблицу orders
 
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

customer: 'ФИО', purchase: {[product_id: 5, qty: 2], [product_id: 7, qty: 3]}

customer - purchase
purchase - product - qty

|{название_товара: quantity, product_id: quantity, product_id: quantity}|общая сумма заказа|


6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

select pg_typeof(info->'customer')
from orders

select pg_typeof(info->>'customer')
from orders

select sum((info->'items'->>'qty')::int)
from orders

6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::int)
from orders
where info->'items'->>'product' like 'Toy%'

======================== array ========================
7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

select special_features, array_length(special_features, 1)
from film

select special_features, array_length(special_features, 2)
from film

select array_length(array[1,2,3,4,5], 1)

select array_length('{{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}}'::text[], 2)

7* Выведите все фильмы содержащие специальные атрибуты: 'Trailers','Commentaries'
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

-- ПЛОХАЯ ПРАКТИКА -- 

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
	
-- ХОРОШАЯ ПРАКТИКА -- 

select title, special_features
from film
where array_position(special_features, 'Trailers') is not null or
	array_position(special_features, 'Commentaries') is not null
	

array_position -- возвращает первое вхождение
array_positions -- возвращает массив всех вхождений

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
	'Commentaries' = any(special_features) -- some - синоним 
	
select title, special_features
from film
where 'Trailers' = all(special_features) or
	'Commentaries' = all(special_features)
	
https://postgrespro.ru/docs/postgresql/12/functions-subquery

https://postgrespro.ru/docs/postgrespro/12/functions-array
