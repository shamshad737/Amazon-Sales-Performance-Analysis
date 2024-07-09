use amazon_sales ;
select * from amazon ;
show columns from amazon ;

-- changing column name ; 

alter table amazon 
rename column `Invoice ID`  to invoice_id;
alter table amazon 
rename column `Customer type`  to customer_type;
alter table amazon 
rename column `Product line`  to product_line;
alter table amazon 
rename column `Unit price`  to unit_price;
alter table amazon 
rename column `Tax 5%`  to VAT;
alter table amazon 
rename column `Payment`  to payment_method;
alter table amazon 
rename column `gross margin percentage`  to gross_margin_percentage;
alter table amazon 
rename column `gross income`  to gross_income;


-- feature engineering 
-- adding columns named timeofday, dayname, monthname 


alter table amazon 
add column timeofday varchar(10) ;

 SET SQL_SAFE_UPDATES=0;

UPDATE amazon 
SET timeofday = 
CASE
	WHEN HOUR(Time) BETWEEN 6 AND 11 THEN 'Morning'
	WHEN HOUR(Time) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
END ;

alter table amazon 
add column dayname varchar(20);

update amazon 
set dayname = DAYNAME(Date) ;

alter table amazon 
add column monthname varchar(20);

update amazon 
set monthname = MONTHNAME(Date) ;  


-- 1. What is the count of distinct cities in the dataset? 

select count(distinct city) 
from amazon ;

-- 2. For each branch, what is the corresponding city?
select distinct branch, city from amazon ;

-- 3. What is the count of distinct product lines in the dataset?

 select distinct product_line, count(*) as product_count
 from amazon 
 group by product_line
 order by product_count desc;
 
-- 4. Which payment method occurs most frequently? 
select payment_method, count(*) as most_used_payment_method
from amazon 
group by 1
order by 2 desc;

-- 5. Which product line has the highest sales? 
select product_line, count(invoice_id) as sales_count
from amazon 
group by 1 
order by 2 desc 
limit 1;

-- 6. How much revenue is generated each month?
select monthname, round(sum(total),2) as Revenue
from amazon 
group by 1
order by 2 desc ;  

-- 7. In which month did the cost of goods sold reach its peak?
select monthname, round(sum(cogs),2) as total_cogs
from amazon 
group by 1
order by 2 desc
limit 1; 

-- 8. Which product line generated the highest revenue? 
select product_line, round(sum(total),2) as Revenue
from amazon 
group by 1
order by 2 desc
limit 1; 

-- 9. In which city was the highest revenue recorded? 
select city, round(sum(total),2) as Revenue
from amazon 
group by 1
order by 2 desc
limit 1; 

-- 10. Which product line incurred the highest Value Added Tax?
 select product_line, round(sum(VAT),2) as sales 
from amazon 
group by 1
order by 2 desc
limit 1; 

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
alter table amazon 
add column product_remarks varchar(15) 

UPDATE amazon 
Set product_remarks =  
	case 
		when total >= (select avg(t.total) from (select total from amazon) as t) then 'Good' 
		else 'Bad' 
	end;
select * from amazon ;


-- 12. Identify the branch that exceeded the average number of products sold.
WITH branch_wise_qty_sold AS
(SELECT 
    branch, count(quantity) AS total_qty_sold
FROM
    amazon
GROUP BY branch
ORDER BY 2 DESC) 
SELECT 
    branch, total_qty_sold
FROM
    branch_wise_qty_sold
WHERE
    total_qty_sold >= (SELECT 
            AVG(total_qty_sold)
        FROM
            branch_wise_qty_sold);


-- 13. Which product line is most frequently associated with each gender?

SELECT product_line, gender, count(*) as counts 
from amazon 
group by 1, 2 order by 2,3 desc ;

-- 14. Calculate the average rating for each product line.

select product_line, round(avg(rating),2) as avg_ratings
 from amazon group by 1 order by 2 desc ; 
 
 
 -- 15. Count the sales occurrences for each time of day on every weekday.
 select timeofday, count(*) as sales 
 from amazon 
 group by 1 ;
 
 -- 16. Identify the customer type contributing the highest revenue.
 
 select customer_type, round(sum(total),2) as Revenue 
 from amazon 
 group by 1;
 
 
 -- 17. Determine the city with the highest VAT percentage.
 with citybyVAT as 
 (select city, round(sum(VAT),2) as total_VAT 
 from amazon
 group by 1 
 order by total_VAT desc)
 select city,round(total_VAT/(select sum(VAT) from amazon),3)*100 as percent_VAT 
 from citybyVAT
  ; 
-- 18. Identify the customer type with the highest VAT payments.
select customer_type, round(sum(VAT),2) as total_VAT 
from amazon 
group by 1;

-- 19. What is the count of distinct customer types in the dataset?
select count(distinct customer_type) from amazon;

-- 20. What is the count of distinct payment methods in the dataset? 
select count(distinct payment_method) from amazon;

-- 21. Which customer type occurs most frequently? 

select customer_type, count(customer_type) as count 
from amazon 
group by 1 ;

-- 22. Identify the customer type with the highest purchase frequency.

select customer_type, count(invoice_id) as count 
from amazon 
group by 1 ;
-- 23. Determine the predominant gender among customers.
select gender, count(invoice_id) as count 
from amazon 
group by 1 ;
-- 24. Examine the distribution of genders within each branch.
select branch, gender, 
count(gender) as count from amazon
group by 1,2
order by 1;


-- 25. Identify the time of day when customers provide the most ratings. 

SELECT 
    timeofday, COUNT(rating) AS count
FROM
    amazon
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- 26. Determine the time of day with the highest customer ratings for each branch.
select branch, timeofday, rating_count 
from 
(with branch_wise_ratings as 
(SELECT 
    branch, timeofday, COUNT(rating) AS rating_count
FROM
    amazon
GROUP BY 1,2) 
select branch, timeofday, rating_count,
rank() over(partition by branch order by rating_count desc) as ranks
from branch_wise_ratings) as ranking_table
where ranks = 1;

-- 27. Identify the day of the week with the highest average ratings.
SELECT 
    dayname, round(AVG(rating),2) as avg_rating
FROM
    amazon
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 28. Determine the day of the week with the highest average ratings for each branch.
select branch, dayname, avg_rating
 from 
(WITH branchwise_rating_perday as 
(SELECT 
    branch, dayname, round(AVG(rating),2) as avg_rating
FROM
    amazon
GROUP BY 1,2) 
select branch, dayname, avg_rating,
rank() over (partition by branch order by avg_rating desc) as rank_rating
from branchwise_rating_perday) as table_A 
where rank_rating = 1;


show columns from amazon;
select * from amazon ;

                
                    
	




