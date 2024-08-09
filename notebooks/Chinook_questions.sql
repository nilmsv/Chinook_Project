
-- 1.	ده آهنگ برتر که بیشترین درامد رو داشتن به همراه درامد ایجاد شده
with Invoice_j_Invoiceline as (
select inv.TrackId, inn.Total from
invoice inn join invoiceline inv on inn.InvoiceId = inv.InvoiceId
)

select * from Invoice_j_Invoiceline
order by Total desc
limit 10




-- 2.	محبوب ترین ژانر، به ترتیب از نظر تعداد آهنگ های فروخته شده و کل درامد
with Track_j_Invoiceline as (
select t.TrackId, t.GenreId, inv.InvoiceId from
track t join invoiceline inv on t.TrackId = inv.TrackId
),
Track_j_Invoiceline_j_Invoice as (
select j1.TrackId, j1.GenreId, j1.InvoiceId, inn.Total from
Track_j_Invoiceline j1 join invoice inn on j1.InvoiceId = inn.InvoiceId
)

select j2.GenreId , max(j2.Total) as max_income, count(j2.TrackId) as number_track from Track_j_Invoiceline_j_Invoice j2 
group by j2.GenreId
order by number_track desc, max_income 
limit 1





-- 3.	کاربرانی که تا حاال خرید نداشتند
select c.CustomerId from
customer c join Invoice inn on c.CustomerId = inn.CustomerId
where inn.InvoiceId = null





-- 4.	میانگین زمان آهنگ ها در در هر آلبوم
select t.AlbumId, avg(t.Milliseconds) as average_time from track t
group by t.AlbumId








-- 5.	کارمندی که بیشترین تعداد فروش را داشته
with employee_j_customer as ( 
select e.EmployeeId, e.FirstName, e.LastName, c.CustomerId from
employee e join customer c on e.EmployeeId = c.SupportRepId
),

employee_j_customer_j_invoice as (
select j1.EmployeeId, j1.FirstName, j1.LastName, inn.InvoiceId 
from employee_j_customer j1 join invoice inn on j1.CustomerId = inn.CustomerId
)

select j2.EmployeeId, j2.FirstName, j2.LastName, sum(inv.Quantity) as sum_quantity
from employee_j_customer_j_invoice j2 join invoiceline inv on j2.InvoiceId = inv.InvoiceId
group by j2.EmployeeId
order by sum_quantity desc
limit 1






-- 6.	کاربرانی که از بیش از یک ژانر خرید کردند
with invoice_j_invoiceline as ( 
select inn.CustomerId, inv.TrackId from
invoice inn join invoiceline inv on inn.InvoiceId = inv.InvoiceId
)

select j1.CustomerId, count(distinct(t.GenreId)) as nember_of_genre 
from invoice_j_invoiceline j1 join track t on j1.TrackId = t.TrackId
group by j1.CustomerId
HAVING nember_of_genre > 1









-- 7.	سه آهنگ برتر از نظر درامد فروش برای هر ژانر
with track_j_invoiceline as ( 
select t.GenreId, t.TrackId, t.Name, inv.InvoiceId from
track t join invoiceline inv on t.TrackId = inv.TrackId
),

track_j_invoiceline_invoice as (
select j1.GenreId, j1.TrackId, j1.Name, inn.Total from
track_j_invoiceline j1 join invoice inn on j1.InvoiceId = inn.InvoiceId
),

ranked_data AS (
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY track_j_invoiceline_invoice.GenreId ORDER BY track_j_invoiceline_invoice.Total DESC) AS row_num
FROM
    track_j_invoiceline_invoice
    )
	
select * from ranked_data
WHERE row_num <= 3;









-- 8.	تعداد آهنگ های فروخته شده به صورت تجمعی در هر سال به صورت جداگانه
with invoice_j_invoiceline as ( 
select YEAR(inn.InvoiceDate) as years, count(inv.TrackId) as num_of_tracks from
invoice inn join invoiceline inv on inn.InvoiceId = inv.InvoiceId
group by YEAR(inn.InvoiceDate)
)

SELECT j1.years, j1.num_of_tracks, sum(j1.num_of_tracks) over (order by j1.years) as cumulative_sum
FROM invoice_j_invoiceline j1








-- 9.	کاربرانی که مجموع خریدشان باالتر از میانگین مجموع خرید تمام کاربران است
with totall as(
select CustomerId, sum(Total) as total from invoice
group by CustomerId
)

select CustomerId, total from totall
where total > (select AVG(total) from totall)
