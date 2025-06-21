-- 2356. Number of Unique Subjects Taught by Each Teacher
-- SOLVED
select 
    teacher_id,
    count(distinct subject_id) as cnt
from Teacher
group by teacher_id


-- 610. Triangle Judgement
-- solved
SELECT 
    x,
    y,
    z,
    CASE WHEN (x + y> z) AND (x + z > y) AND (y + z > x)
         THEN 'Yes' ELSE 'No' END AS triangle
from Triangle


-- 1789. Primary Department for Each Employee
-- solved 
with Many_deps as  
    (select 
        employee_id,
        department_id
    from Employee
    where primary_flag = 'Y'),
    One_dep as 
    (select 
        employee_id,
        count(department_id) 
    from Employee
    group by employee_id
    having count(department_id) = 1),
    One_dep_id as 
    (select 
        em.employee_id,
        em.department_id
    from One_dep od
    left join Employee em
        on em.employee_id = od.employee_id)

select * from Many_deps
UNION
select * from One_dep_id


-- 1729. Find Followers Count
-- solved
select 
    user_id,
    count(follower_id) as followers_count
from Followers
group by user_id
order by user_id

-- 596. Classes With at Least 5 Students
-- solved
with Class_count as 
    (select 
        class,
        count(student) 
    from Courses
    group by class
    having count(student) >= 5)

select class from Class_count

-- 1633. Percentage of Users Attended a Contest
-- solved 
select 
    contest_id,
    ROUND(CAST(count(user_id) as decimal) / (select count(user_id) from Users) * 100, 2) as percentage
from Register
group by contest_id
order by percentage desc, contest_id asc


-- 1251. Average Selling Price
-- solved 
with Units_revenue as
    (select
        pr.product_id,
        pr.price,
        us.units,
        pr.price * us.units as revenue
    from Prices pr
    left join UnitsSold us
        on pr.product_id = us.product_id
    where pr.start_date <= us.purchase_date AND pr.end_date >= us.purchase_date)

select 
    pr.product_id,
    COALESCE(ROUND(CAST(SUM(revenue) as decimal) / SUM(units), 2), 0) as average_price
from Prices pr
left join Units_revenue ur
    on pr.product_id = ur.product_id
group by pr.product_id



-- 1327. List the Products Ordered in a Period
-- solved 
with Product_units as 
    (select 
        product_id,
        SUM(unit)
    from Orders
    where order_date BETWEEN '2020-02-01' AND  '2020-02-29'
    group by product_id)

select 
    pr.product_name,
    sum as unit
from Product_units pu 
left join Products pr
    on pr.product_id = pu.product_id
where sum >= 100



-- 1731. The Number of Employees Which Report to Each Employee
-- solved
with Managers as 
    (select 
        reports_to as employee_id,
        count(employee_id) reports_count,
        round(AVG(age)) as average_age
    from Employees
    where reports_to IS NOT NULL
    group by reports_to)


select 
    ma.employee_id, 
    em.name, 
    ma.reports_count, 
    ma.average_age
from Managers ma
join Employees em
    on ma.employee_id = em.employee_id
order by ma.employee_id


-- 619. Biggest Single Number
-- solved 
-- Encapsulate the query in a sub-query to transform "no row" to a null value
-- https://stackoverflow.com/questions/8098795/return-a-value-if-no-record-is-found/8098816#8098816
select 
	(select num FROM  
		(select 
			num,
			count(num)  
		from MyNumbers
	group by num) sub
where count = 1
order by num desc
limit 1) as num 
