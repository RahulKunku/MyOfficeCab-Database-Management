-- Query 1 - Month-On-Month Num trips
select concat(right(trip_date,4),'-',left(trip_date,2)) as "Year_Month",count(*) as Number_of_Trips
from trips
group by 1
order by 1;

-- Query 2 - Month-On-Month Num employees (multiple employees can be in the same trip)
select concat(right(pickup_date,4),'-',left(pickup_date,2)) as "Year_Month",count(*) as Number_of_Employees
from employee_trips
group by 1 
order by 1 ;

-- Query 3 - Month-On-Month top drivers
select concat(right(trip_date,4),'-',left(trip_date,2)) as "Year_Month",
first_name as Driver_Name,count(*) as Number_of_Trips
from trips t
left join drivers d
on t.driver_id = d.id
group by 1,2
order by 1,3 desc;

-- Query 4 - -- Identifying busiest day of the week
select day_of_week,
case when day_of_week =1 then 'Sunday' when day_of_week =2 then 'Monday' when day_of_week =3 then 'Tuesday'
when day_of_week =4 then 'Wesnesday' when day_of_week =5 then 'Thursday' when day_of_week =6 then 'Friday'
when day_of_week =7 then 'Saturday' else 'Error' end as "Day",count(*) as Number_of_Trips
from(
select *,
dayofweek(concat(right(trip_date,4),'-',left(trip_date,2),'-',mid(trip_date,4,2))) as day_of_week
from trips t
left join (select distinct trip_id,pickup_date,pickup_time from employee_trips) et
on t.id = et.trip_id) a
group by 1,2
order by 3 desc;

-- Query 5 - -- Identifying busiest time of the day
select 
case when hour_of_day < 6 then '1. Very Early Morning'
when hour_of_day < 9 then '2. Early Morning'
when hour_of_day < 12 then '3. Morning'
when hour_of_day < 15 then '4. Noon'
when hour_of_day < 18 then '5. Late AfterNoon'
when hour_of_day < 21 then '6. Night'
when hour_of_day < 24 then '7. Late Night'
end as time_slot,
count(*) as Number_of_Trips
from(
select *,
left(pickup_time,locate(':',pickup_time)-1) as hour_of_day
from trips t
left join (select distinct trip_id,pickup_date,pickup_time from employee_trips) et
on t.id = et.trip_id) a
group by 1
order by 2 desc;

-- Q6 - Top employees traveling in a month
select concat(right(pickup_date,4),'-',left(pickup_date,2)) as "Year_Month",first_name,
count(distinct trip_id) as Number_of_Trips
from(
select et.*,e.first_name
from employee_trips et
left join employees e
on et.employee_id = e.id) a
group by 1,2
order by 1, 3 desc;

-- Q7 - Top customers (office) in a month
select concat(right(pickup_date,4),'-',left(pickup_date,2)) as "Year_Month",
company_name,count(distinct trip_id) as Number_of_Trips
from(
select et.*,c.name as Company_Name,c.area
from employee_trips et
left join employee_offices eo
on et.employee_id = eo.employee_id
left join customers c
on eo.office_id = c.id) a
group by 1,2
order by 1,3 desc;

-- Q8 - Number of insured and uninsured rides given out
select case when insurance_type = 'Bumper to bumper' then 'Full Cover'
else 'Partial Cover' end  as Vehicle_Insurance_Type,count(*) as Number_of_Trips
from(
select t.*,v.electric,v.insurance_type
from trips t
left join vehicles v
on t.vehicle_id = v.id) a
group by 1
order by 2 desc;

-- Q9 - Highest demand area
select Area,count(distinct trip_id) as Number_of_Trips
from(
select et.*,c.name as Company_Name,c.area
from employee_trips et
left join employee_offices eo
on et.employee_id = eo.employee_id
left join customers c
on eo.office_id = c.id) a
group by 1
order by 2 desc;

-- Q10 - Drivers with DL expiring in 2023
select *
from drivers
where right(dl_expiry_date,4) = '2023';

