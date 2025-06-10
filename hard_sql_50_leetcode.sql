-- 6 Jun 2025
-- 185. Department Top Three Salaries

with Salary_ranks as 
    (Select
        id,
        name,
        salary,
        departmentId, 
        DENSE_RANK() over(partition by departmentId order by salary desc) as salary_rank
    FROM Employee)

select 
    dp.name as Department,
    sr.name as Employee,
    sr.salary as Salary
from Salary_ranks sr 
join Department dp on sr.departmentId = dp.id 
where sr.salary_rank <= 3
order by sr.salary
