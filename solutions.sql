use sakila;

-- Question 1.

select * from film;
select * from rental;
select * from inventory;

with t2 as
(select t1.category_id, t1.title, t1.numbers_rented, dense_rank() over (partition by t1.category_id order by numbers_rented desc) as rented_units
from (select i.film_id, f.title, fc.category_id, count(i.film_id) as numbers_rented
from inventory as i 
join rental as r
	on i.inventory_id=r.inventory_id
join film as f
	on f.film_id=i.film_id
join film_category as fc
	on i.film_id = fc.film_id
join category as c
	on fc.category_id = c.category_id
group by i.film_id, fc.category_id
order by category_id, numbers_rented desc) as t1
)
select t2.category_id, t2.title, t2.numbers_rented
from t2
where t2.rented_units = 1;

-- Question 2:
select fc.category_id, sum(p.amount)
from payment as p
join rental as r
	on p.rental_id = r.rental_id
join inventory as i
	on r.inventory_id = i.inventory_id
join film_category as fc
	on fc.film_id = i.film_id
group by fc.category_id;

-- Question 3:
select * from customer;
select * from film_category;
select * from payment;
select * from inventory;
select * from rental;

with t2 as
(select *, dense_rank() over (partition by t1.category_id order by no_of_rentals desc) as renter_rank_by_cat
from 
(select r.customer_id, fc.category_id, count(r.customer_id) as no_of_rentals, 
concat(cust.first_name," ",cust.last_name) as full_name
from rental as r
join inventory as i
	on r.inventory_id = i.inventory_id
join film_category as fc
	on fc.film_id = i.film_id
join customer as cust
	on r.customer_id = cust.customer_id
group by r.customer_id, fc.category_id
order by category_id asc, no_of_rentals desc
) as t1
) select t2.category_id, t2.customer_id, t2.full_name, t2.no_of_rentals, t2.renter_rank_by_cat from t2
where t2.renter_rank_by_cat = 2;

-- Question 4:

with t2 as
(select t1.title, t1.rented_units, dense_rank() over (order by t1.rented_units desc) as ranking_serial
from
(
select f.title, count(i.film_id) as rented_units
from rental as r
join inventory as i
	on r.inventory_id = i.inventory_id
join film as f
	on i.film_id = f.film_id
group by f.title
order by rented_units desc
) as t1
) select * from t2
where ranking_serial = 2
;

-- Question 5:
select c.name, count(i.film_id) as sold_films
from inventory as i 
join rental as r
	on i.inventory_id=r.inventory_id
join film as f
	on f.film_id=i.film_id
join film_category as fc
	on i.film_id = fc.film_id
join category as c
	on fc.category_id = c.category_id
group by c.name
order by sold_films desc;

-- Question 6:

with t2 as
(select t1.film_id, t1.title, t1.category_id, row_number() over (partition by t1.category_id) as ranking_serial from
(select i.film_id, f.title, fc.category_id, count(i.film_id) as numbers_rented
from inventory as i 
join rental as r
	on i.inventory_id=r.inventory_id
join film as f
	on f.film_id=i.film_id
join film_category as fc
	on i.film_id = fc.film_id
join category as c
	on fc.category_id = c.category_id
group by i.film_id, fc.category_id
order by category_id, numbers_rented desc) t1
) select * from t2
where ranking_serial < 11;

-- Question 7:
select * from rental;
select * from inventory;

select f.film_id, f.title, avg(datediff( cast(r.return_date as date), cast(r.rental_date as date))) as average_rental_days
from rental as r
join inventory as i
	on r.inventory_id = i.inventory_id
join film as f
	on i.film_id = f.film_id
group by f.film_id;

-- Question 8:
with t2 as
(select t1.film_id, t1.title, t1.category_id, t1.weekday, t1.numbers_rented, 
row_number() over (partition by t1.weekday order by numbers_rented desc) as ranking_serial from
(select i.film_id, f.title, fc.category_id, dayname(r.rental_date) as weekday, count(i.film_id) as numbers_rented
from inventory as i 
join rental as r
	on i.inventory_id=r.inventory_id
join film as f
	on f.film_id=i.film_id
join film_category as fc
	on i.film_id = fc.film_id
join category as c
	on fc.category_id = c.category_id
group by i.film_id, fc.category_id, weekday
order by category_id, numbers_rented desc) t1
) select t2.weekday, t2.title, t2.ranking_serial, t2.numbers_rented from t2
where ranking_serial < 11;

-- Question 9:
select * from payment;
select * from rental;

select dayname(rental_date) as weekday, sum(amount) as sum_of_rentals_by_weekdays
from rental
join payment
on rental.rental_id = payment.payment_id
group by weekday;

with t2 as
(select *, dense_rank() over (partition by t1.rating order by rented_no) as rank_number_of_times_rented
from
(select f.rating, i.film_id, f.title, count(r.inventory_id) as rented_no
from rental as r
join inventory as i
	on r.inventory_id = i.inventory_id
join film as f
	on i.film_id = f.film_id
group by i.film_id, f.rating
order by rating, rented_no desc)as t1)
select t2.rating, t2.film_id, t2.title, t2.rented_no as no_of_times_rented from t2
where rank_number_of_times_rented = 1
;

-- Question 10:
select * from film;
select distinct rating from film;
select * from rental;

-- Question 11:

select f.rating, avg(datediff(cast(r.return_date as date), cast(r.rental_date as date))) as avg_rental_days
from rental as r
join inventory as i
	on r.inventory_id = i.inventory_id
join film as f
	on i.film_id = f.film_id
group by f.rating
;

-- Qustion 12:
-- By date
select * from rental;
select * from film;

select cast(rental_date as date) as date_rented, dayname(cast(rental_date as date)) as day_of_a_week,
count(cast(rental_date as date)) as count_of_movies_rented
from rental
group by date_rented, day_of_a_week
order by count_of_movies_rented desc;
-- By days
select cast(rental_date as date) as date_rented, dayname(cast(rental_date as date)) as day_of_a_week,
count(cast(rental_date as date)) as count_of_movies_rented
from rental
group by date_rented, day_of_a_week
order by count_of_movies_rented desc;




-- Question 13:

select f.rating, cast(rental_date as date) as date_rented, dayname(cast(rental_date as date)) as day_of_a_week,
count(cast(rental_date as date)) as count_of_movies_rented
from rental as r
join inventory as i
	on r.inventory_id = i.inventory_id
join film as f
	on i.film_id = f.film_id
group by f.rating, date_rented, day_of_a_week
order by rating, count_of_movies_rented desc;
