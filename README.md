# MyOfficeCab Data Management Project

## Overview

This project involves the development and implementation of a structured and centralized Database Management System (DBMS) for MyOfficeCab, an eco-transportation company in India. The goal is to enhance the efficiency of data management, streamline ETL processes, and unlock valuable insights for better decision-making.

## Project Goals and Objectives

### Goals
- Efficiently manage data related to customers, transactions, fleet management, and employee details.
- Provide a digitalized and centralized database to replace offline data management methods.

### Objectives
- Develop a structured and centralized DBMS using SQL.
- Enhance information management and streamline ETL processes.
- Generate insights on key metrics like month-on-month trips, top drivers, busiest days of the week, and high-demand areas.
- Identify high-profit segments and channels.

## Database Design

### Tables and Datasets
The project utilizes six main tables:
1. **Employees**: Stores details like employee ID, name, gender, email, contact information, and active status.
2. **Employee_Trips**: Records employee trip details, including pickup date and time.
3. **Employee_Offices**: Maps employees to their corresponding offices.
4. **Trips**: Contains data on all trips, including driver and vehicle details.
5. **Vehicles**: Includes vehicle information such as model, registration number, status, and insurance details.
6. **Drivers**: Stores driver details, including name, license expiry date, and contact information.
7. **Customers**: Contains customer details and office locations.

### Relationships
- Each employee can take multiple trips, and each trip can involve multiple employees.
- Each trip is managed by one driver but can involve multiple vehicles.
- Each employee is assigned to one office, but an office can have multiple employees.
- Each customer is linked to multiple offices.

## Conceptual and Relational Data Models

The database design includes conceptual (ERD) and relational data models to illustrate the relationships between different entities and tables.

## SQL Queries and Insights

### Key Queries
1. **Month-On-Month Number of Trips**: Tracks the total trips taken each month.
    ```sql
    SELECT CONCAT(RIGHT(trip_date, 4), '-', LEFT(trip_date, 2)) AS "Year_Month", COUNT(*) AS Number_of_Trips
    FROM trips
    GROUP BY 1
    ORDER BY 1;
    ```
2. **Month-On-Month Number of Employees**: Counts the number of employees taking trips each month.
    ```sql
    SELECT CONCAT(RIGHT(pickup_date, 4), '-', LEFT(pickup_date, 2)) AS "Year_Month", COUNT(*) AS Number_of_Employees
    FROM employee_trips
    GROUP BY 1
    ORDER BY 1;
    ```
3. **Month-On-Month Top Drivers**: Identifies the top drivers based on the number of trips completed each month.
    ```sql
    SELECT CONCAT(RIGHT(trip_date, 4), '-', LEFT(trip_date, 2)) AS "Year_Month",
           first_name AS Driver_Name, COUNT(*) AS Number_of_Trips
    FROM trips t
    LEFT JOIN drivers d ON t.driver_id = d.id
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC;
    ```
4. **Busiest Days of the Week**: Determines the busiest days for trips.
    ```sql
    SELECT day_of_week,
           CASE 
               WHEN day_of_week = 1 THEN 'Sunday' 
               WHEN day_of_week = 2 THEN 'Monday'
               WHEN day_of_week = 3 THEN 'Tuesday'
               WHEN day_of_week = 4 THEN 'Wednesday'
               WHEN day_of_week = 5 THEN 'Thursday'
               WHEN day_of_week = 6 THEN 'Friday'
               WHEN day_of_week = 7 THEN 'Saturday' 
               ELSE 'Error' 
           END AS "Day", COUNT(*) AS Number_of_Trips
    FROM (
        SELECT *,
               DAYOFWEEK(CONCAT(RIGHT(trip_date, 4), '-', LEFT(trip_date, 2), '-', MID(trip_date, 4, 2))) AS day_of_week
        FROM trips t
        LEFT JOIN (SELECT DISTINCT trip_id, pickup_date, pickup_time FROM employee_trips) et ON t.id = et.trip_id
    ) a
    GROUP BY 1, 2
    ORDER BY 3 DESC;
    ```
5. **Busiest Times of the Day**: Identifies peak times for trips throughout the day.
    ```sql
    SELECT 
           CASE 
               WHEN hour_of_day < 6 THEN '1. Very Early Morning'
               WHEN hour_of_day < 9 THEN '2. Early Morning'
               WHEN hour_of_day < 12 THEN '3. Morning'
               WHEN hour_of_day < 15 THEN '4. Noon'
               WHEN hour_of_day < 18 THEN '5. Late Afternoon'
               WHEN hour_of_day < 21 THEN '6. Night'
               WHEN hour_of_day < 24 THEN '7. Late Night'
           END AS time_slot,
           COUNT(*) AS Number_of_Trips
    FROM (
        SELECT *,
               LEFT(pickup_time, LOCATE(':', pickup_time) - 1) AS hour_of_day
        FROM trips t
        LEFT JOIN (SELECT DISTINCT trip_id, pickup_date, pickup_time FROM employee_trips) et ON t.id = et.trip_id
    ) a
    GROUP BY 1
    ORDER BY 2 DESC;
    ```
6. **Most Frequently Traveling Employees in a Month**: Finds the most frequent travelers each month.
    ```sql
    SELECT CONCAT(RIGHT(pickup_date, 4), '-', LEFT(pickup_date, 2)) AS "Year_Month", first_name,
           COUNT(DISTINCT trip_id) AS Number_of_Trips
    FROM (
        SELECT et.*, e.first_name
        FROM employee_trips et
        LEFT JOIN employees e ON et.employee_id = e.id
    ) a
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC;
    ```
7. **Top Customers in a Month**: Lists the offices using the service the most each month.
    ```sql
    SELECT CONCAT(RIGHT(pickup_date, 4), '-', LEFT(pickup_date, 2)) AS "Year_Month",
           company_name, COUNT(DISTINCT trip_id) AS Number_of_Trips
    FROM (
        SELECT et.*, c.name AS Company_Name, c.area
        FROM employee_trips et
        LEFT JOIN employee_offices eo ON et.employee_id = eo.employee_id
        LEFT JOIN customers c ON eo.office_id = c.id
    ) a
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC;
    ```
8. **Number of Insured and Uninsured Rides**: Counts trips by fully and partially insured vehicles.
    ```sql
    SELECT CASE WHEN insurance_type = 'Bumper to bumper' THEN 'Full Cover'
                ELSE 'Partial Cover' 
           END AS Vehicle_Insurance_Type, COUNT(*) AS Number_of_Trips
    FROM (
        SELECT t.*, v.electric, v.insurance_type
        FROM trips t
        LEFT JOIN vehicles v ON t.vehicle_id = v.id
    ) a
    GROUP BY 1
    ORDER BY 2 DESC;
    ```
9. **Highest Demand Area**: Identifies areas with the highest demand for trips.
    ```sql
    SELECT Area, COUNT(DISTINCT trip_id) AS Number_of_Trips
    FROM (
        SELECT et.*, c.name AS Company_Name, c.area
        FROM employee_trips et
        LEFT JOIN employee_offices eo ON et.employee_id = eo.employee_id
        LEFT JOIN customers c ON eo.office_id = c.id
    ) a
    GROUP BY 1
    ORDER BY 2 DESC;
    ```
10. **Drivers with DL Expiring in 2023**: Lists drivers whose licenses are expiring in 2023.
    ```sql
    SELECT *
    FROM drivers
    WHERE RIGHT(dl_expiry_date, 4) = '2023';
    ```

### Insights
- **Busiest Days**: Wednesday and Thursday are the busiest days.
- **Peak Times**: 12 PM to 3 PM and 9 PM to Midnight are the busiest times.
- **Trip Volume**: August 2022 saw the highest number of trips (1714).
- **Insurance Coverage**: ~28% of rides were in partially insured vehicles, suggesting an opportunity to upgrade to full coverage.

### Future Recommendations
1. **Process Optimization**: Automate billing processes to reduce manual effort.
2. **Expansion**: Scale operations to onboard more clients and manage data more efficiently.
3. **Feedback System**: Introduce a feedback table for driver ratings and punctuality to improve service quality.

## Conclusion

The implementation of a centralized DBMS for MyOfficeCab significantly enhances data management capabilities, providing valuable insights and supporting data-driven decision-making. This project sets a foundation for further improvements and scalability in MyOfficeCab’s operations.

---

## Additional Notes
- Ensure all date fields are formatted as `mm/dd/yyyy` when uploading data to use the queries in their current format.
- Execute schema SQL scripts before running the query scripts to avoid data inconsistencies.
