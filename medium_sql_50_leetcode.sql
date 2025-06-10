
-- 570. Managers with at Least 5 Direct Reports

With Count_managers as 
(select 
managerId, 
Count(id) as count_emps
from Employee
group by managerId)

select em.name as name
from Count_managers cm
join Employee em on em.id = cm.managerId
where count_emps >= 5

-- 20 May 2025 
-- ## 1934: Confirmation Rate 

with requests_cte as 
(select 
    user_id,
    count(time_stamp) as requests_count
from confirmations
group by user_id),
confirmed_cte as 
    (select 
    user_id, 
    count(time_stamp) as confirmed_count
    from Confirmations
    where action = 'confirmed'
    group by user_id)


select 
    rcte.user_id, 
    COALESCE(ROUND(cast(ccte.confirmed_count as decimal) / rcte.requests_count, 2), 0)  as confirmation_rate
from requests_cte rcte
left join confirmed_cte ccte on rcte.user_id = ccte.user_id 


-- 21 May 2025
-- ## 1193. Monthly Transactions I 

select 
    to_char(trans_date, 'YYYY-MM') as month, 
    country, 
    count(id) as trans_count, 
    sum(case when state = 'approved' then 1 ELSE 0 END) as approved_count,
    sum(amount) as trans_total_amount,
    sum(case when state = 'approved' then amount else 0 end) as approved_total_amount
from transactions 
group by month, country


-- Using window function
SELECT DISTINCT
    to_char(trans_date, 'YYYY-MM') AS month,
    country,
    COUNT(id) OVER (PARTITION BY to_char(trans_date, 'YYYY-MM'), country) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) OVER (PARTITION BY to_char(trans_date, 'YYYY-MM'), country) AS approved_count,
    SUM(amount) OVER (PARTITION BY to_char(trans_date, 'YYYY-MM'), country) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) OVER (PARTITION BY to_char(trans_date, 'YYYY-MM'), country) AS approved_total_amount
FROM transactions;



-- 23 May 2025
-- ## 1174. Immediate Food Delivery II
-- https://leetcode.com/problems/immediate-food-delivery-ii?envType=study-plan-v2&envId=top-sql-50


with First_order_dates as 
    (select 
        customer_id, 
        delivery_id,
        min(order_date) over (partition by customer_id order by order_date) as first_order_date
    from Delivery),
    First_orders as 
    (select  
        de.delivery_id, 
        de.customer_id, 
        de.order_date, 
        de.customer_pref_delivery_date, 
        fo.first_order_date
    from Delivery de
    left join First_order_dates fo 
        on fo.customer_id = de.customer_id 
        and fo.delivery_id = de.delivery_id
    where de.order_date = fo.first_order_date),
    Immediate_orders as (select 
        customer_id, 
        delivery_id, 
        sum(case when order_date = customer_pref_delivery_date then 1 else 0 end)  over(partition by customer_id) as immediate_count,
        count(delivery_id) over(partition by customer_id) as total_count
    from First_orders)

select round((sum(immediate_count) / sum(total_count)) *100, 2) as immediate_percentage 
from Immediate_orders


-- ## 550. Game Play Analysis IV

WITH Logged_two_days AS (
    SELECT 
        player_id,
        event_date,
        MIN(event_date) OVER(PARTITION BY player_id) AS first_event_date
    FROM Activity
),
Delta_dates AS (
    SELECT 
        player_id,
        event_date,
        first_event_date,
        CASE WHEN event_date - first_event_date = 1 THEN 1 ELSE 0 END AS delta_date
    FROM Logged_two_days
),
Two_day_players AS (
    SELECT COUNT(DISTINCT player_id) AS two_day_player
    FROM Delta_dates
    WHERE delta_date = 1),
Total_players AS (
    SELECT COUNT(DISTINCT player_id) AS distinct_player
    FROM Activity)

SELECT 
    ROUND(1.0 * tdp.two_day_player / tp.distinct_player, 2) AS fraction
FROM Two_day_players tdp
CROSS JOIN Total_players tp;


-- 24 May 2025
-- ## 1070. Product Sales Analysis III

with First_sales as 
    (select 
        product_id,
        sale_id,
        min(year) over(partition by product_id) as first_year
    from Sales)

select ss.product_id, fs.first_year, ss.quantity, ss.price
from Sales ss
join First_sales fs 
    on fs.product_id = ss.product_id and fs.sale_id = ss.sale_id and ss.year = fs.first_year



-- ## 1045. Customers Who Bought All Products

with Customer_product_count as 
    (select 
        customer_id,
        count(distinct product_key) as count_product
    from Customer
    group by customer_id)

select customer_id
from Customer_product_count
where count_product = (select count(product_key) from Product)


-- ## 1164. Product Price at a Given Date

with First_price_dates as 
    (select 
        product_id,
        new_price,
        change_date,
        MIN(change_date) over(partition by product_id) as first_price_date
    from Products), 
    Latest_before_16 as 
    (select 
        product_id,
        max(change_date) as latest_change_date
    from Products 
    where change_date <= '2019-08-16'
    group by product_id),
    Price_before_16 as 
    (select 
        pr.product_id,
        pr.new_price as price
    from Products pr
    join Latest_before_16 la 
        on pr.product_id = la.product_id AND pr.change_date = la.latest_change_date),
    After_16 as 
    (select 
        product_id,
        10 as price
    from First_price_dates
    where first_price_date > '2019-08-16')

    
select * from Price_before_16 
UNION 
select * from After_16



-- 1204. Last Person to Fit in the Bus

with Last_turns as 
    (select 
        max(turn) as last_turn
    from Queue),
    Ordered_by_turn as 
    (select 
        qu.*,
        sum(weight) over(order by turn) as sum_weight
    from Queue qu
    order by turn)

select person_name 
from Ordered_by_turn
where sum_weight <= 1000
order by sum_weight desc
limit 1


-- ## 1907. Count Salary Categories

with Categories as (
    select 
        account_id,
        case when income < 20000 THEN 1 ELSE 0 END AS low_salary,
        case when income >= 20000 AND income <= 50000 THEN 1 ELSE 0 END AS average_salary,
        case when income > 50000 THEN 1 ELSE 0 END AS high_salary
    from Accounts
),
Accounts_count as (
    select account_id, 'Low Salary' as category, low_salary as category_flag from Categories
    union all
    select account_id, 'Average Salary' as category, average_salary as category_flag from Categories
    union all
    select account_id, 'High Salary' as category, high_salary as category_flag from Categories
)

select 
    category, 
    sum(category_flag) as accounts_count
from Accounts_count
group by category;

-- 25 May 2025
-- ## 1907. Count Salary Categories
-- https://stackoverflow.com/questions/1128737/equivalent-to-unpivot-in-postgresql

--  array[a, b, c] returns an array object, with the values of a, b, and c as it's elements. 
--  unnest(array[a, b, c]) breaks the results into one row for each of the array's elements.

with Categories as 
    (select 
        account_id,
        case when income < 20000 THEN 1 ELSE 0 END AS low_salary,
        CASE WHEN income >= 20000 AND income <= 50000 THEN 1 ELSE 0 END AS average_salary,
        CASE WHEN income > 50000 THEN 1 ELSE 0 END AS high_salary
    from Accounts),
    Accounts_count as 
    (select 
        account_id,
        unnest(array['low_salary',  'average_salary',  'high_salary']) AS array_object,
        unnest(array[low_salary,  average_salary,  high_salary]) AS row_elements
    from Categories),
    Categories_renamed as 
    (select 
        array_object, 
        sum(row_elements) as accounts_count
    from Accounts_count
    group by array_object)

select 
    case when array_object = 'low_salary' THEN 'Low Salary'
        when array_object = 'average_salary' THEN 'Average Salary'
        when array_object = 'high_salary' THEN 'High Salary' 
    END as category, 
    accounts_count
from Categories_renamed




-- 28 May
-- ## 176. Second Highest Salary

with Ranked_salaries as 
    (select 
        dense_rank() over (order by salary desc) as salary_rank,  
        salary
    from Employee)
select 
    (select 
        salary 
    from Ranked_salaries
    where salary_rank = 2
    limit 1) as "SecondHighestSalary"


-- 29 May
-- ## 585. Investments in 2016

with Count_2015 as 
    (select 
        tiv_2015,
        count(tiv_2015) as count_tiv_2015
    from Insurance ins
    group by tiv_2015),
    Duplicate_2015 as
    (select *
    from Insurance
    where tiv_2015 IN 
        (select tiv_2015 
        from Count_2015
        where count_tiv_2015 >=2)),
    Count_latlon as 
        (select 
            concat(lat, lon) as latlon,
            count(concat(lat, lon)) as count_latlon
        from Insurance
        group by latlon),
    Unique_latlon as 
    (select 
       *
    from Insurance ins
    join Count_latlon cl
        on cl.latlon = concat(ins.lat, ins.lon) and count_latlon = 1)

select round(sum(dup.tiv_2016)::numeric, 2) as tiv_2016 
from  Duplicate_2015 dup 
join Unique_latlon ul 
    on dup.pid = ul.pid


-- 2 June
-- ## 1321. Restaurant Growth

WITH Sum_per_day as 
    (select 
        visited_on, 
        SUM(cu.amount) as sum_amount 
    from Customer cu
    group by visited_on), 
    Sum_amounts as 
    (select 
        visited_on,
        sum_amount,
        SUM(sum_amount) over(
                            order by visited_on
                            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
                            as amount 
    from Sum_per_day),
    Moving_averages as 
    (select 
        visited_on,
        amount,
        AVG(sum_amount) over(
                            order by visited_on
                            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
                            as average_amount 
    from Sum_amounts 
    group by visited_on),
    Rounded_averages as 
    (select 
        visited_on,
        amount,
        round(average_amount, 2) as average_amount
    from Moving_averages)

select * from Rounded_averages
where visited_on > (select min(visited_on) + interval '5' day from Customer)


-- 3 Jun 2025
-- ## 1341. Movie Rating

with Count_movies as 
    (select 
        user_id,
        count(movie_id) as count_movie
    from MovieRating
    group by user_id),
    Max_rating as 
    (select 
        cm.user_id, 
        cm.count_movie,
        us.name
    from Count_movies cm
    left join Users us on us.user_id = cm.user_id
    order by cm.count_movie desc),
    Name_sorted as
    (select 
        name as title
    from Max_rating
    order by count_movie desc, name
    limit 1),
    Avg_movie as 
    (select 
        movie_id,
        AVG(rating) as avg_rating
    from MovieRating
    where created_at BETWEEN '2020-02-01' AND '2020-02-29'
    group by movie_id
    order by avg_rating desc),
    Avg_movie_name as
    (select 
        mo.title as title
    from Avg_movie am
    left join Movies mo on mo.movie_id = am.movie_id
    order by am.avg_rating desc, mo.title 
    limit 1
   ),
   Movie_user as 
    (select title from Name_sorted
    UNION ALL
    select title from Avg_movie_name)

select title as results from Movie_user


-- 4 Jun 2025
-- 626. Exchange Seats

with Prev_next as 
    (select 
        id,
        student,
        lag(id) over(order by id) as prev_id,
        lag(student) over(order by id) as prev_stu,
        lead(id) over(order by id) as next_id,
        lead(student)  over(order by id) as next_stu
    from Seat),
    Prev_next_odd as 
    (select 
        id, 
        COALESCE(next_stu, student) as student
    from Prev_next
    where MOD(id, 2) <> 0 ), 
    Prev_next_even as 
    (select 
        id, 
        prev_stu as student
    from Prev_next
    where MOD(id, 2) = 0 ),
    Last_row as 
    (select 
        id, 
        student
    from Prev_next
    order by id desc
    limit 1),
    Result_set as 
    (select * from Prev_next_odd
    UNION
    select * from Prev_next_even
)

select * from Result_set
order by id


-- ## 602. Friend Requests II: Who Has the Most Friends

with Requestors as 
    (select requester_id 
    from RequestAccepted),
    Acceptors as 
    (select accepter_id
    from RequestAccepted),
    Request_Accept as 
    (select requester_id as id from Requestors 
    UNION ALL
    select accepter_id as id from Acceptors),
    Count_most as 
    (select 
        id,
        count(id) as num     
    from Request_Accept
    group by id)

select * from Count_most
order by num desc
limit 1
