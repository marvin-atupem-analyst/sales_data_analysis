# Power BI Sales Data Analysis

## Project Review

This project analyzes a Power BI Sales dataset to understand sales performance, product performance and customer performance. 
The project uses SQL for data preparation and analysis, followed by Power BI for interactive data visualization and dashboard development.
The objective of the project is to transform raw sales data into meaningful business insights that can support better understanding of sales and profitability.

## Objectives

- Analyze overall Sales Performance
- Examine Product Performance
- Analyze Customer Performance
- Compare Payment methods
- Present the findings yhrough an interactive Power BI dashboard.

## Dataset

- The main file used for this project is "PowerBI_Sales_Dataset_10000.csv".
- This contains detailed transactions records from 2024 to 2025.
- There are 10000 rows of data
- There are 20 columns in total

### Columns
The key information inside the columns include:

| Column | Description |
|---|---|
| Order_ID | Unique identifier for the transaction |
| Order_Date | Date of the transaction |
| Customer | Customer name |
| Gender | Customer gender |
| Age | Customer age |
| Product | Product purchased |
| Category | Product category |
| Quantity | Quantity purchased |
| Unit_Price| Price per item |
| Sales | Revenue generated from the transaction |
| Cost | Cost associated with the transaction |
| Discount | Product Discount |
| Profit | Profit generated |
| City | Customer city |
| State | Customer state |
| Region | Customer region |
| Payment_Mode | Payment method used |
| Sales_Person | Sales_Person |
| Customer_Type | Type of Customer |
| Rating | Customer Rating |

## Tools Used

- **MySQL** – Data exploration, cleaning, transformation and analysis
- **Power BI** – Data visualization and dashboard development
- **DAX** – Creation of calculated measures

## Data Cleaning and Preparation

Before performing the analysis, the dataset was inspected and prepared
using SQL.

The following steps were performed:

- Examined the structure of the dataset.
- Checked the number of records.
- Checked for missing values.
- Checked for duplicate records.
- Examined the data types of relevant columns.
- Validated numerical fields.
- Checked categorical fields for consistency.
- Removed duplicate records where necessary.
- Prepared the cleaned data for analysis.

The SQL queries used for the cleaning process are available in:

`sql/ecommerce_analysis.sql`

## Exploratory Data Analysis

After preparing the dataset, SQL was used to explore the data and
answer the main business questions.

The analysis covered:

### Sales Analysis

- Total sales
- Total cost
- Total profit
- Monthly sales
- Monthly profit
- Profit margin

### Product Analysis

- Sales by product
- Profit by product
- Quantity sold by product
- Product profitability

### Geographic Analysis

- Sales by region
- Sales by state
- Sales by city

### Customer Analysis

- Total customers
- Top customers
- Bottom customers
- Customer sales and profit


## Business Questions

The analysis was designed around the following questions:

1. How many transactions were recorded?
2. How many unique customers do they have?
3. Does each product belong to one category?
4. What are the ratio of males and females?
5. What City has the most orders, sales and profit?
6. What state has the most orders, sales and profit?
7. What region has the most orders, sales and profit?
8. What age-group has the most orders, sales and profit?
9. What product has the most sales and profit?
10. Which salesperson had the most sales? 


The SQL queries used for the cleaning and exploratory process are available in:
`sql/ecommerce_analysis.sql`

## Data Modeling

I imported the cleaned tables into Power BI and built a **Star Schema** data model
* **Tables Used:** I used 3 main tables : `Fact_Sales`, `Dim_Customer`, and `Dim_Product`.
* **Tables Layout:** The `Fact_Sales` table sits in the middle, with the `Dim_Customer` table on one side and the `Dim_Product` table on the other side.
* **Relationships:** I connected the tables using **One-to-Many (1:*)** relationships:
	* `Dim_Customer` connects to `Fact_Sales`
	* `Dim_Product` connects to `Fact_Sales`
* **Calender Table:** I created a new calender table to handle dates and linked it to the main sales data.

## DAX Measures & Table Formulas
I used DAX to calculate business metrics and build a custom calendar table. 

### Calendar Table Creation
To track sales trends over time, I created a custom calendar table using this formula:
```dax
Calendar = 
VAR MinDate = MIN('Fact_Sales'[Order_Date])
VAR MaxDate = MAX('Fact_Sales'[Order_Date])
RETURN CALENDAR(MinDate, MaxDate)
```
*I also added custom columns to this table for Month Name, Month Number, MonthYear, Year, and Year Month ID.*

### Core Sales Measures
*   **Total Sales:** Calculates total combined revenue for 2024 and 2025.
```dax
Total Sales = SUM('Fact_Sales'[Sales])
```
*   **True Cost:** The raw dataset had incorrect cost values that matched sales numbers. I fixed this by subtracting profit from total sales to find the true cost.
```dax
True Cost = SUM('Fact_Sales'[Sales]) - SUM('Fact_Sales'[Profit])
```
*   **Total Profit:** Calculates the total money gained at the end of the two years.
```dax
Total Profit = SUM('Fact_Sales'[Profit])
```
*   **Total Quantity:** Measures the total amount of goods sold.
```dax
Total Quantity = SUM('Fact_Sales'[Quantity])
```
*   **Profit Margin:** Calculates the percentage of sales revenue that was pure profit.
```dax
Profit Margin = DIVIDE([Total Profit], [Total Sales])
```

### Customer Measures
*   **Average Profit Per Customer:** Measures the average profit value driven by each unique buyer.
```dax
Average Profit per Customer = DIVIDE([Total Profit], DISTINCTCOUNT('Fact_Sales'[Customer_ID]))
```
*   **Age Groups:** I grouped customers into specific age bins using a nested `SWITCH(TRUE(), ...)` function to handle the logic.

---

## Power BI Dashboard Design
The final report is an interactive, **three-page dashboard** divided into specific analytical themes:

### Page 1: Sales Overview
*   **KPI Cards:** Shows Total Sales, True Cost, Total Profit, and Total Quantity.
*   **Monthly Sales Trend:** Tracks sales and profit patterns across each month.
*   **Geographic Visuals:** Displays total sales broken down by City and by State.
*   **Regional Performance:** Uses a clustered column chart to view sales and profit by Region.
*   **Payment & Feedback:** Tracks transaction volumes by Payment Type, and uses a Gauge visual to show our customer service rating out of 5 stars.

### Page 2: Product Analysis
*   **Product Performance Matrix:** A detailed matrix table showing Total Sales, Total Profit, and Profit Margin for all products. *This revealed that some low-sales items actually produce high profit margins.*
*   **What Sells vs. What Makes Money:** A scatter chart tracking Quantity (X-axis) and Profit (Y-axis), with bubble size showing the Total Sales volume.
*   **Category Splits:** A Pie chart displaying Sales and Profit share by Product Category.
*   **Top Items:** A clustered bar chart breaking down specific items and their categories sold.
*   **Filters:** Includes slicers for Year, Category, and Product to filter the page.

### Page 3: Customer Page
*   **KPI Cards:** Displays Total Unique Customers and Average Profit per Customer.
*   **Top & Bottom Tiers:** Table visuals isolating our Top 10 Best Customers and Bottom 10 Worst Customers based on sales, profit, and margin.
*   **Demographics:** A stacked bar chart showing customer counts by Age Group, and a Pie chart breaking down the count of Male vs. Female buyers.


## 8. Key Findings & Core Insights

### Key Performance Metrics
*   **Total Revenue Generated:** ₹594.62 Million
*   **True Cost Incurred:** ₹460.59 Million
*   **Net Total Profit:** ₹134.03 Million
*   **Total Quantity Sold:** 45K items
*   **Total Unique Customers:** 6,703 customers
*   **Total Order Count:** 10,000 orders

###  Core Insights From Analysis
1.  **Biggest Revenue Driver:** Laptops are the store's highest-performing product. They generated **₹211.26 Million** in sales with a solid **22% profit margin**.
2.  **Similar Product Profit Margins:** Product profit margins are relatively close to one another, generally falling within the 22%–24% range. Electronics recorded a 22.57% margin, while Furniture recorded 22.33%. This limited variation suggests that product-level profitability is relatively consistent across the dataset and may warrant further investigation into pricing, costs, and discounting.
3.  **Sales vs. Profit/Volume:** Several lower-priced products contribute substantial sales volume by quantity, while revenue and profit are more concentrated among higher-value electronics products. This highlights the difference between products that sell frequently and products that generate greater financial value..
4.  **Highest-Value Customer by Sales:** John Reddy generated approximately ₹7.01 million in sales with a 23% profit margin, making him the highest-sales customer among the customers shown in the Top 10 analysis. 
5.  **Average Profit per Customer:** The business generated approximately ₹20.00K in profit per customer on average, based on 6,703 customers.


## 11. Limitations
* **Visual Scope Boundaries:** The dashboard reporting interface is limited strictly to a **three-page layout**. Because of this, it leaves out deeper operational breakdowns, such as individual salesperson performance tracking.
* **Limited Explanatory Variables:** The available dataset allows analysis of sales, profit, products, customers, geography, payment methods, and related measures, but does not include variables such as marketing expenditure, discounts, salesperson performance, or operating costs. Therefore, some potential reasons behind observed differences cannot be established from the dataset alone.


## 12. Conclusion & Strategic Recommendations

Based on the analysis, the following areas could be investigated further:

1. **Investigate Product-Level Pricing and Margins:** Product margins are relatively similar across the dataset. Further analysis of pricing, costs, and discounts could determine what is driving this consistency before making pricing changes.
2. **Develop Customer Retention Strategies:** A relatively small group of high-value customers contributes substantial sales. The business could identify these customers for targeted retention initiatives and monitor whether these efforts improve repeat purchases and customer value.
3. **Investigate Regional Performance:** Sales vary across states and regions, with the South recording the highest regional sales. Lower-performing states could be investigated further to identify differences in demand, product mix, availability, or other factors that may explain their performance.
