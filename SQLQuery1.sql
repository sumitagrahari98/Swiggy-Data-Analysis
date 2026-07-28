select * from swiggy_data
--Data Valdation & cleaning 
-- Null Check
SELECT 
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
    SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
    SUM(CASE WHEN price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;

--- Blank or Empty Stings 
SELECT *
FROM swiggy_data
WHERE state = ''OR city = ''OR restaurant_name = ''OR location = ''
   OR category = ''
   OR dish_name = '';

--Duplicates 
SELECT state,city, order_date, restaurant_name, location, category,
    dish_name, price_INR, rating, rating_count,
    COUNT(*) AS count
FROM swiggy_data
GROUP BY  state, city, order_date, restaurant_name, location, category,
  dish_name,price_INR, rating, rating_count
HAVING COUNT(*) > 1;


--- Delete Duplicates
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY state, city, order_date, restaurant_name, location, category, 
                            dish_name, price_INR, rating, rating_count
               ORDER BY (SELECT NULL)
           ) AS Rn
    FROM swiggy_data
)
DELETE FROM CTE
WHERE Rn > 1;

select * from Swiggy_Data;
-- Creating schema 
-- Dimension Table 
-- Data Table 
CREATE TABLE dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    day INT,
    week_number INT
);
select * from dim_date ;
--dim_location 
CREATE TABLE dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    state VARCHAR(100),
    city VARCHAR(100),
    location VARCHAR(200)
);
select * from dim_location ;
--dim_restaurant
CREATE TABLE dim_restaurant (
    restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
    restaurant_name VARCHAR(200)
);
select * from dim_restaurant ;
-- dim-category 
CREATE TABLE dim_category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category VARCHAR(150)
);
--select * from dim_restaurant ;

-- dim_dish
CREATE TABLE dim_dish (
    dish_id INT IDENTITY(1,1) PRIMARY KEY,
    dish_name VARCHAR(200)
);
select * from dim_dish;


--Creating the Central Fact Table
CREATE TABLE fact_swiggy_orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    date_id INT FOREIGN KEY REFERENCES dim_date(date_id),
    location_id INT FOREIGN KEY REFERENCES dim_location(location_id),
    restaurant_id INT FOREIGN KEY REFERENCES dim_restaurant(restaurant_id),
    category_id INT FOREIGN KEY REFERENCES dim_category(category_id),
    dish_id INT FOREIGN KEY REFERENCES dim_dish(dish_id),
    price_inr DECIMAL(10,2),
    rating DECIMAL(4,2),
    rating_count INT);

    select * from fact_swiggy_orders;

    -- insert Date Dimension Table (dim_date)
    INSERT INTO dim_date (
    full_date, 
    year, 
    month, 
    month_name, 
    quarter, 
    day, 
    week_number
)
SELECT DISTINCT 
    order_date,
    YEAR(order_date),
    MONTH(order_date),
    DATENAME(MONTH, order_date),
    DATEPART(QUARTER, order_date),
    DAY(order_date),
    DATEPART(WEEK, order_date)
FROM swiggy_data
WHERE order_date IS NOT NULL;


Select * from dim_date ;

-- Isnert  Location Dimension Table (dim_location)
INSERT INTO dim_location (state, city, location)
SELECT DISTINCT state, city, location
FROM swiggy_data;

Select * from dim_location;

--Restaurant Dimension Table (dim_restaurant)
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT restaurant_name
FROM swiggy_data;
Select * from dim_restaurant;
-- Insert Category Dimension Table (dim_category) 
INSERT INTO dim_category (category)
SELECT DISTINCT category
FROM swiggy_data;

Select * from dim_category;

--Dish Dimension Table (dim_dish)
INSERT INTO dim_dish (dish_name)
SELECT DISTINCT dish_name
FROM swiggy_data;

Select * from dim_dish;

-- Insert Fact Table
INSERT INTO fact_swiggy_orders (
    date_id, 
    price_inr, 
    rating, 
    rating_count, 
    location_id, 
    restaurant_id, 
    category_id, 
    dish_id
)
SELECT 
    dd.date_id,
    s.price_inr,
    s.rating,
    s.rating_count,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    ds.dish_id
FROM swiggy_data s
JOIN dim_date dd 
    ON s.order_date = dd.full_date
JOIN dim_location dl 
    ON s.state = dl.state 
   AND s.city = dl.city 
   AND s.location = dl.location
JOIN dim_restaurant dr 
    ON s.restaurant_name = dr.restaurant_name
JOIN dim_category dc 
    ON s.category = dc.category
JOIN dim_dish ds 
    ON s.dish_name = ds.dish_name;

  SELECT * from fact_swiggy_orders;
    --Complete Star Schema Join Query
    SELECT *
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
JOIN dim_location l 
    ON f.location_id = l.location_id
JOIN dim_restaurant r 
    ON f.restaurant_id = r.restaurant_id
JOIN dim_category c 
    ON f.category_id = c.category_id
JOIN dim_dish ds 
    ON f.dish_id = ds.dish_id;


    --KPI 's Calculation Queries

    --Total Orders 
  SELECT COUNT(order_id) AS total_orders 
FROM fact_swiggy_orders;

--Total Revenue in INR Millions
SELECT FORMAT(SUM(CONVERT(FLOAT, price_inr)) / 1000000.0, 'N2') + ' INR Million' AS total_revenue 
FROM fact_swiggy_orders;


--Average Order / Dish Price
SELECT FORMAT(AVG(CONVERT(FLOAT, price_inr)), 'N2') + ' INR' AS avg_dish_price 
FROM fact_swiggy_orders;
--Deep-Dive Trend & Performance Queries
SELECT 
    d.year, 
    d.month, 
    d.month_name, 
    COUNT(f.order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY total_orders DESC;

--Deep-Dive Trend & Performance Queries
SELECT 
    d.year, 
    d.month, 
    d.month_name, 
    COUNT(f.order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY total_orders DESC;

--Top 10 Cities by Order Volume
SELECT TOP 10 
    l.city, 
    COUNT(f.order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.city
ORDER BY total_orders DESC;

--Top 10 Restaurants by Order Volume
SELECT TOP 10 
    r.restaurant_name, 
    COUNT(f.order_id) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC;

--Customer Spend Brackets (CASE WHEN)
SELECT 
    CASE 
        WHEN price_inr < 100 THEN 'Under 100'
        WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+' 
    END AS spend_bucket,
    COUNT(order_id) AS total_orders
FROM fact_swiggy_orders
GROUP BY 
    CASE 
        WHEN price_inr < 100 THEN 'Under 100'
        WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+' 
    END
ORDER BY total_orders DESC;
