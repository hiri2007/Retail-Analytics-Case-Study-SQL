SET GLOBAL local_infile = 1;
SET autocommit = 0;     -- Step 1


-- Creating the database 
create database customer_profile_data;

-- select the database for EDA task
use customer_profile_data;

-- create an table of customer_profile
create table customer_profile(
	CustomerID int primary key,
    Age         int,
    Gender      varchar(10),
    Location    varchar(20),
    JoinDate    date
);

-- load the dataset in the customer_profile table

LOAD DATA LOCAL INFILE 'C:/Users/hirilal/OneDrive/Desktop/Retail Analytics Case Study SQL/customer_profiles.csv'
INTO TABLE customer_profile
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- create an table of sales_transaction
create table sales_transaction(
	TransactionID 		int primary key,
    CustomerID 			int not null,
    ProductID			int not null ,
    QuantityPurchased   int NOT Null,
    TransactionDate    	date,
    Price    			float
);

-- load the data set in the sales_transaction table 
LOAD DATA LOCAL INFILE 'C:/Users/hirilal/OneDrive/Desktop/Retail Analytics Case Study SQL/sales_transaction.csv'
INTO TABLE sales_transaction
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- create an table of product_inventory

create table product_inventory(
	ProductID 		int primary key,
    ProductName     varchar(50),
    Category    	varchar(50),
    StockLevel    	int,
    Price			float
);

-- load the dataset in the product_inventory table

LOAD DATA LOCAL INFILE 'C:/Users/hirilal/OneDrive/Desktop/Retail Analytics Case Study SQL/product_inventory.csv'
INTO TABLE product_inventory
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- featch the description of all the table

desc customer_profile;
desc sales_transaction;
desc product_inventory;


-- data cleaning (removing null and duplicate value)

select count(*) from customer_profile
where 	Age is null 
    or Gender is null
    or Location is null
    or JoinDate is null;
    
    
    
select count(*) from product_inventory
where 	ProductName is null 
    or Category is null
    or StockLevel is null
    or Price is null;    
    
    
select * from sales_transaction
where TransactionDate is null
    or Price is null;    
    
-- Exploratory Data Analysis (EDA)

-- Basic product performance overview (total sales per product, total revenue, total quantity sold)


SELECT 
    s.ProductID,
    p.ProductName,
    COUNT(s.TransactionDate)        AS Total_Transactions,
    SUM(s.QuantityPurchased)      AS Total_Quantity_Sold,
    SUM(s.QuantityPurchased * s.Price) AS Total_Revenue,
    AVG(s.Price)                  AS Avg_Selling_Price
FROM sales_transaction AS s
JOIN product_inventory AS p 
ON s.ProductID = p.ProductID
GROUP BY s.ProductID, p.ProductName
ORDER BY Total_Revenue DESC;


-- customer purchase frequency analysis (how many orders does each customer have, on average)

SELECT 
	S.CustomerID,
    C.Gender,
    COUNT(S.ProductID) AS purchase_frequency
FROM sales_transaction AS S
JOIN customer_profile AS C
ON S.CustomerID = C.CustomerID
GROUP BY S.CustomerID , C.Gender
ORDER BY purchase_frequency DESC;


-- product categories performance evaluation (which categories generate the most revenue/volume)

SELECT 
	S.ProductID,
    P.ProductName,
	P.Category,
    SUM(S.QuantityPurchased) AS Total_Purchase
FROM sales_transaction AS S
JOIN product_inventory AS P
ON S.ProductID = P.ProductID
GROUP BY S.ProductID, P.Category
ORDER BY Total_Purchase DESC;

-- frequency of purchasing only with the category of item
SELECT 
	P.Category,
    SUM(S.QuantityPurchased) AS Total_Purchase
FROM sales_transaction AS S
JOIN product_inventory AS P
ON S.ProductID = P.ProductID
GROUP BY P.Category
ORDER BY Total_Purchase DESC;

-- Product Performance Variability

SELECT 
	ProductID,
    SUM(QuantityPurchased) AS Total_purchased,
    SUM(QuantityPurchased * Price) AS Total_Revenue,
	DENSE_RANK() OVER (ORDER BY SUM(QuantityPurchased) DESC) AS RANK_OF_PRODUCTS
FROM sales_transaction
GROUP BY ProductID;

-- Calculating Month-over-Month (MoM) growth

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(TransactionDate, '%Y-%m') AS Sales_Month,
        SUM(QuantityPurchased * Price) AS Total_Revenue
    FROM sales_transaction
    GROUP BY DATE_FORMAT(TransactionDate, '%Y-%m')
)
SELECT 
    Sales_Month,
    Total_Revenue,
    LAG(Total_Revenue) OVER (ORDER BY Sales_Month) AS Previous_Month_Revenue,
    ROUND(
        (Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY Sales_Month)) 
        / LAG(Total_Revenue) OVER (ORDER BY Sales_Month) * 100
    , 2) AS MoM_Growth_Percent
FROM monthly_sales
ORDER BY Sales_Month;


-- Customer Segmentation :- Count total orders per customer, then bucket them into segments using the table given

WITH Customer_Orders AS (
    SELECT 
        CustomerID,
        COUNT(TransactionID) AS Total_Orders,
        SUM(QuantityPurchased) AS Total_Quantity,
        SUM(QuantityPurchased * Price) AS Total_Revenue
    FROM sales_transaction
    GROUP BY CustomerID
)
SELECT 
    CO.CustomerID,
    CO.Total_Orders,
    CO.Total_Quantity,
    CO.Total_Revenue,
    CASE 
        WHEN CO.Total_Orders = 0 THEN 'No orders'
        WHEN CO.Total_Orders BETWEEN 1 AND 10 THEN 'Low'
        WHEN CO.Total_Orders BETWEEN 11 AND 30 THEN 'Mid'
        WHEN CO.Total_Orders > 30 THEN 'High Value'
    END AS Customer_Segment
FROM Customer_Orders AS CO
ORDER BY CO.Total_Orders DESC;


-- Customer Behavior Analysis
-- % of Customers Who Bought More Than Once

WITH Customer_Orders AS (
    SELECT 
        CustomerID,
        COUNT(TransactionID) AS Total_Orders
    FROM sales_transaction
    GROUP BY CustomerID
)
SELECT 
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Total_Orders = 1 THEN 1 ELSE 0 END) AS One_Time_Buyers,
    SUM(CASE WHEN Total_Orders > 1 THEN 1 ELSE 0 END) AS Repeat_Buyers,
    ROUND(
        SUM(CASE WHEN Total_Orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
    , 2) AS Repeat_Purchase_Percent
FROM Customer_Orders;