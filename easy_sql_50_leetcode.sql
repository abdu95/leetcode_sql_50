-- 1757. Recyclable and Low Fat Products
select product_id 
from Products 
where low_fats = 'Y' and recyclable = 'Y'


-- 584. Find Customer Referee
select name 
from Customer
where referee_id <> 2 or referee_id IS NULL


-- 595. Big Countries
select name, population, area
from World
where area >= 3000000 or population >= 25000000


-- 1148. Article Views I
select distinct author_id as id
from Views
where author_id = viewer_id


-- 1683. Invalid Tweets
select tweet_id 
from Tweets 
where length(content) > 15 



-- 1378. Replace Employee ID With The Unique Identifier
select emp_uni.unique_id, emp.name
FROM Employees emp
left join EmployeeUNI emp_uni
    on emp.id = emp_uni.id 



-- 1068. Product Sales Analysis I
select pr.product_name, sa.year, sa.price 
from Sales sa
left join Product pr
    on pr.product_id = sa.product_id


-- 1581. Customer Who Visited but Did Not Make Any Transactions
select 
    customer_id,
    count(visit_id) as count_no_trans
from Visits
where visit_id not in
    (select 
    distinct visit_id 
    from Transactions)
group by customer_id

	
--  577. Employee Bonus
with Emp_bonus as 
    (select emp.name, bon.bonus
    from Employee emp
    left join Bonus bon 
        on bon.empId = emp.empId)
select * from Emp_bonus 
where bonus is NULL or bonus < 1000


-- 620. Not Boring Movies
select * from Cinema 
where description NOT LIKE '%boring%'
    AND mod(id, 2) <> 0
order by rating DESC



-- 1251. Average Selling Price
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


-- 1075. Project Employees I
select 
    pr.project_id,
    round(AVG(experience_years), 2) as average_years
from Project pr
left join Employee em
    on pr.employee_id = em.employee_id
group by pr.project_id

-- 1633. Percentage of Users Attended a Contest
select 
    contest_id,
    ROUND(CAST(count(user_id) as decimal) / (select count(user_id) from Users) * 100, 2) as percentage
from Register
group by contest_id
order by percentage desc, contest_id asc




-- 2356. Number of Unique Subjects Taught by Each Teacher
select 
    teacher_id,
    count(distinct subject_id) as cnt
from Teacher
group by teacher_id


-- 596. Classes With at Least 5 Students
with Class_count as 
    (select 
        class,
        count(student) 
    from Courses
    group by class
    having count(student) >= 5)

select class from Class_count	

	
-- 1729. Find Followers Count
select 
    user_id,
    count(follower_id) as followers_count
from Followers
group by user_id
order by user_id

-- 619. Biggest Single Number
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


-- 1731. The Number of Employees Which Report to Each Employee
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


-- 1789. Primary Department for Each Employee
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

	
-- 610. Triangle Judgement
SELECT 
    x,
    y,
    z,
    CASE WHEN (x + y> z) AND (x + z > y) AND (y + z > x)
         THEN 'Yes' ELSE 'No' END AS triangle
from Triangle	



-- 1978. Employees Whose Manager Left the Company
select employee_id
from Employees 
where salary < 30000 AND manager_id IS NOT NULL 
    AND manager_id NOT IN (select employee_id from Employees)
order by employee_id


-- 1667. Fix Names in a Table
select 
    user_id,
    concat(upper(left(name, 1)), lower(substring(name, 2, length(name)))) as name
from Users
order by user_id


-- 1527. Patients With a Condition
select * from Patients 
where conditions LIKE 'DIAB1%' or conditions LIKE '% DIAB1%'



-- 196. Delete Duplicate Emails
DELETE FROM Person
where id IN

 (SELECT id
    FROM
        (SELECT id,
         ROW_NUMBER() OVER( PARTITION BY email   ORDER BY  id ) AS row_num
        FROM Person ) t
        WHERE t.row_num > 1 );


-- 1484. Group Sold Products By The Date
with Distinct_products as 
    (select distinct sell_date, product
    from Activities)

select 
    sell_date,
    count(product) as num_sold,
    string_agg(product, ',' order by product) as products                        
from Distinct_products
group by sell_date


-- 1327. List the Products Ordered in a Period
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
