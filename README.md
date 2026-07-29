# Swiggy Sales Analysis

## Overview
This repository contains the end-to-end data architecture, quality validation, and analytical documentation for the **Swiggy Sales Analysis** project. The primary objective is to transform raw food delivery records into a performance-optimized Star Schema to uncover actionable business insights regarding revenue growth, customer spending patterns, regional demand, and cuisine performance.

---

## Data Cleaning & Validation Pipeline
The raw dataset (`swiggy_data`) contains food delivery records spanning multiple states, cities, restaurants, categories, and dishes. To ensure absolute data integrity and accuracy before analysis, the data undergoes a rigorous cleaning process:

* **Null Value Check:** Identify and handle missing values across all critical fields, including `State`, `City`, `Order_Date`, `Restaurant_Name`, `Location`, `Category`, `Dish_Name`, `Price_INR`, `Rating`, and `Rating_Count`.
* **Blank & Empty String Detection:** Scan for and resolve fields containing blank values or empty strings that could otherwise distort reporting accuracy.
* **Duplicate Detection:** Identify duplicate records by grouping across all business-critical columns.
* **Deduplication Strategy:** Apply the `ROW_NUMBER()` window function to systematically eliminate surplus duplicate rows while retaining exactly one clean, validated copy for each unique order.

---

## Dimensional Modelling (Star Schema)
To optimize analytics, reporting speed, and dashboard performance, the cleaned data is structured into a **Star Schema**. Instead of querying a single bulky dataset, this dimensional approach separates descriptive context into focused dimension tables and consolidates measurable metrics into a central fact table. This minimizes data duplication, ensures consistency, and provides a scalable foundation for Business Intelligence (BI) tools.

### Schema Architecture

| Table Name | Schema Type | Key Attributes & Measures |
| :--- | :--- | :--- |
| `fact_swiggy_orders` | Fact Table | Consists of core business measures (`Price_INR`, `Rating`, `Rating_Count`) and foreign keys mapping to all dimension tables. |
| `dim_date` | Dimension Table | Temporal attributes: `Year`, `Month`, `Quarter`, and `Week`. |
| `dim_location` | Dimension Table | Geographical attributes: `State`, `City`, and `Location`. |
| `dim_restaurant` | Dimension Table | Restaurant details: `Restaurant_Name`. |
| `dim_category` | Dimension Table | Food classification: `Cuisine` and `Category`. |
| `dim_dish` | Dimension Table | Item specifics: `Dish_Name`. |

---

## Key Performance Indicators (KPIs)
Once the data is populated into the Star Schema, the analytical engine computes the following foundational performance metrics:

* **Total Orders:** The total volume of completed food delivery transactions.
* **Total Revenue:** Gross earnings generated across all orders, reported in INR Millions.
* **Average Dish Price:** The mean pricing of food items listed and ordered.
* **Average Rating:** The aggregated customer satisfaction score across all deliveries.

---

## Deep-Dive Business Analysis Modules
The project explores five core analytical dimensions to answer critical business questions and evaluate operational growth:

### 1. Temporal & Date-Based Analysis
* Monitor monthly order trends to identify seasonal surges and dips in delivery demand.
* Evaluate quarterly order trends to track broader business performance over time.
* Calculate year-wise growth rates to measure long-term market expansion.
* Analyze day-of-week ordering patterns to pinpoint peak volume days.

### 2. Regional & Location Insights
* Identify and rank the top 10 cities by total order volume.
* Compare revenue contribution across different states to highlight high-value geographic regions.

### 3. Food & Restaurant Performance
* Rank the top 10 restaurants based on total orders received.
* Identify the most popular food categories and cuisines (e.g., Indian, Chinese).
* Determine the most frequently ordered individual dishes across the platform.
* Evaluate holistic cuisine performance by analyzing the intersection of total order volume and average customer rating.

### 4. Customer Spending Behavior
* Segment customer transactions into distinct spending buckets: **Under 100**, **100–199**, **200–299**, **300–499**, and **500+ INR**.
* Map the total order distribution across these price ranges to understand average customer purchasing power and order size.

### 5. Customer Satisfaction & Ratings
* Track the distribution of dish ratings across a 1–5 scale to monitor overall food quality and customer satisfaction trends.
