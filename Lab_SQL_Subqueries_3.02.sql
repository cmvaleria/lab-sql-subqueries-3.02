# Lab | SQL Subqueries 3.02

use sakila;

# 1. How many copies of the film Hunchback Impossible exist in the inventory system?

select film_id, title from film
where title = 'HUNCHBACK IMPOSSIBLE'; #439

select count(film_id) as Hunchback_Impossible_Count from inventory
where film_id = 439;

#films in the inventory

# 2. List all films whose length is longer than the average of all the films.

select title, length, (select avg(length) from film) as total_average from film
where length < (select avg(length) from film)
order by length desc;


# 3. Use subqueries to display all actors who appear in the film Alone Trip.

select * from film_actor;

select actor_id 
from film_actor
where actor_id = (
	select film_id from film
	where title = 'ALONE TRIP')
group by actor_id;

# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select * from 
(select f.film_id, f.title, fc.category_id, c.name as name
from film_category as fc
left join film as f
on fc.film_id = f.film_id
left join category as c
on fc.category_id = c.category_id) as sq1
where name = 'Family';

# 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their
# primary keys and foreign keys, that will help you get the relevant information.

select * from customer;
select * from city;
select * from address;

select first_name, last_name, email, address_id from customer
where address_id in
(select a.address_id#, ci.city_id, ci.city, co.country
from address as a 
left join city as ci
on a.city_id = ci.city_id
join country as co
on ci.country_id = co.country_id
where co.country = 'Canada');


# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
#First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select actor_id, film_id from film_actor
where actor_id in (
	select actor_id from (
	select actor_id, count(actor_id) as film_acts from film_actor
	group by actor_id
	order by film_acts desc
	limit 1) as sq2);


# 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

# the most profitable customer:

select customer_id from 
(select customer_id, sum(amount) as total_payment from payment 
group by customer_id
order by total_payment desc
limit 1) as sq3;

#customer_id: 526

select rental_id, inventory_id, customer_id 
from rental
where customer_id in (
select customer_id from 
(select customer_id, sum(amount) as total_payment from payment 
group by customer_id
order by total_payment desc
limit 1) as sq3);

#can i make a Temporary table? 

CREATE TEMPORARY TABLE most_profitable_customer AS (
select rental_id, inventory_id, customer_id 
from rental
where customer_id in (
select customer_id from 
(select customer_id, sum(amount) as total_payment from payment 
group by customer_id
order by total_payment desc
limit 1) as sq3));

select * from most_profitable_customer;

select m.customer_id as the_best_customer, i.film_id, f.title as his_favorites_movies
from most_profitable_customer as m
left join inventory as i
on m.inventory_id = i.inventory_id
left join film as f
on i.film_id = f.film_id;

## :) was long ##

# 8. Customers who spent more than the average payments.

CREATE TEMPORARY TABLE total_payment_per_customer AS (
select customer_id, sum(amount) as total_payment
from payment
group by customer_id
order by total_payment desc);

select * from total_payment_per_customer 
where total_payment > (select avg(total_payment) from total_payment_per_customer);

## this should work, dont know why is not working :/
## lets try: 

select * from total_payment_per_customer 
where total_payment > 
	(select avg(total_payment) from (
	select customer_id, sum(amount) as total_payment
	from payment
	group by customer_id
	order by total_payment desc) as sq6)

## :) good 
