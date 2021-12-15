-- 1. In this activity, you will be using data from files_for_activities/mysql_dump.sql. 
-- 		Refer to the case study files to find more information. Please answer the following questions.
-- a. How many accounts do we have?
select count(*) from bank.account;

-- b. How many of the accounts are defaulted?
select count(*) from bank.account a
join bank.loan l on a.account_id=l.account_id
where status = 'B';
-- c. What is the percentage of defaulted people in the dataset?
select x.num/y.num from
(select count(*) as num from bank.account a
join bank.loan l on a.account_id=l.account_id
where status = 'B')x join (select count(*) as num from bank.account)y on 1=1;
-- d. What can we conclude from here?
-- very few people default

-- 2. Find the account_id, amount and date of the first transaction of the defaulted people if its amount is at least twice the average of 
-- 		non-default people transactions.
select * from 
(select rank() over(partition by l.account_id order by t.date asc) as myrank, l.account_id, t.amount, t.date from bank.loan l join bank.trans t
on l.account_id=t.account_id where l.status = 'B')sub1 where myrank=1 and amount > (select avg(amount) from bank.loan where status <> 'B');
select * from bank.trans;



-- 3. Create a pivot table showing the average amount of transactions using frequency for each district.
select district,
avg( case when frequency = 'POPLATEK MESICNE' then avg_amount end) as 'POPLATEK MESICNE',
avg( case when frequency = 'POPLATEK PO OBRATU' then avg_amount end) as 'POPLATEK PO OBRATU',
avg( case when frequency = 'POPLATEK TYDNE' then avg_amount end) as 'POPLATEK TYDNE'
from (
  select account.district_id as district, account.frequency, round(avg(trans.amount),2) as avg_amount
  from trans
  join account
  on trans.account_id = account.account_id
  group by account.district_id, account.frequency) sub1
group by district
order by district;

select distinct frequency from bank.account;
select * from bank.account;

select 
a2 as district
,avg(case when frequency = 'POPLATEK MESICNE' then amount end) as "POPLATEK MESICNE"
,avg(case when frequency = 'POPLATEK PO OBRATU' then amount end) as 'POPLATEK PO OBRATU'
,avg(case when frequency = 'POPLATEK TYDNE' then amount end) as 'POPLATEK TYDNE'
from bank.trans t join bank.account a on t.account_id=a.account_id
join bank.district d on a.district_id = d.a1
group by a2,a1
order by a1;

-- 4. Write a simple stored procedure to find the number of movies released in the year 2006.
delimiter //
create procedure movie_count1 ()
begin
select COUNT(*) into param1 from sakila.film
where release_year = 2006;
end;
//
delimiter ;

call movie_count1(@x);
select @x;
