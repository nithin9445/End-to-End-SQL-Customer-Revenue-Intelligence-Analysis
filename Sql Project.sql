# 1) In our e-commerce platform, we want to analyze payment transactions to 
# gain insights into our customers' payment preferences. Based on the total order amount for all calculations, 
# we need to answer the following questions:

# What is the total sum of transactions for each payment type used by our customers?
# What is the average transaction value for each payment type?
# What is the highest transaction value for each payment type?
# What is the lowest transaction value for each payment type?
# How many times was each payment type used for transactions? 


SELECT 
    p.paymenttype,
    p.allowed,
    SUM(o.total_order_amount) AS total_tansaction_value,
    AVG(o.total_order_amount) AS avg_tansaction_value,
    MAX(o.total_order_amount) AS highest_tansaction_value,
    MIN(o.total_order_amount) AS lowest_tansaction_value,
    COUNT(orderid) AS Number_of_Transaction
FROM
    Payments p
        LEFT JOIN
    orders o USING (paymentid)
GROUP BY 1
ORDER BY 1;


# 2)Categorize our customers based on the decade in which they were born. 
# For instance, a decade '50s should encompass birth years from 1950 to 1959, while '60s should include 
# birth years from 1960 to 1969, and so on. Ensure that the alias for each decade range is in lowercase 's'.
# Display the decade followed by the corresponding count of customers from that decade.

SELECT 
    CONCAT(RIGHT(FLOOR(YEAR(date_of_birth) / 10) * 10,
                2),
            's') AS decade,
    COUNT(*) AS count_of_customers
FROM
    customers
GROUP BY decade
ORDER BY decade;


# 3) Print CustomerID, Customer Full Name (with a single space in between first name and last name), 
# number of orders ordered, total amount spent across all orders (consider Total Order Amount), 
# Total product quantity (irrespective of the product ID). Identify top 10 customers according 
# to decreasing order of Total spend.

SELECT 
    c.customerid,
    CONCAT(c.firstname, ' ', c.lastname) AS FullName,
    COUNT(DISTINCT o.orderid) AS Num_of_orders,
    SUM(DISTINCT o.total_order_amount) AS Total_spend,
    SUM(od.quantity) AS Total_Quantity
FROM
    customers c
        JOIN
    orders o USING (Customerid)
        JOIN
    orderdetails od USING (orderid)
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10;


# 4) Print the details of different payment methods along with the total amount of money transacted 
# through them in the years 2020 and 2021.
# Print Payment Type, Allowed, Transaction value in 2020, Transaction value in 2021.
# Order your output in alphabetical order of Payment Type. 
# Include all payment types that exist in the database.

SELECT 
    paymenttype,
    allowed,
    SUM(CASE
        WHEN YEAR(orderdate) = 2020 THEN total_order_amount
    END) AS 2020_transaction,
    SUM(CASE
        WHEN YEAR(orderdate) = 2021 THEN total_order_amount
    END) AS 2021_transaction
FROM
    payments p
        LEFT JOIN
    orders o USING (paymentid)
GROUP BY 1
ORDER BY 1;


# 5) The company plans to open an offline store in the country where it generates the highest revenue. 
# Currently, the sales team requires the CustomerID, FirstName, LastName, and Phone Number of all 
# customers who belong to that country. 
# Provide the data to the sales team in ascending order of CustomerID.

WITH cte AS (
    SELECT 
        country, SUM(total_order_amount)
    FROM
        customers c
    JOIN
        orders o USING (customerid)
    GROUP BY country
    ORDER BY 2 DESC
    LIMIT 1
) 
SELECT 
    customerid, firstname, lastname, phone, country
FROM
    customers c
JOIN
    cte USING (country);


# 6) Find the order frequency of the customers in year 2021.
# Like total 1 order is done by how many customers and likewise for all the number of orders from 1 to N.
# Print the Order frequency and the number of customers who made that much orders in the 
# ascending order of order frequency.


WITH cte AS (
    SELECT
        customerid, COUNT(orderid) AS order_frequency
    FROM
        orders
    GROUP BY
        customerid
)
SELECT
    order_frequency, COUNT(customerid)
FROM
    cte
GROUP BY
    order_frequency
ORDER BY
    order_frequency;


# 7) Write a query to find the top 1 customer with highest order amount for each PaymentId.
# Print PaymentId, CustomerId, First Name, Country, Total Order Amount and Rank.
# Sort the result in ascending order of PaymentId.

WITH cte AS (
    SELECT
        o.paymentid,
        o.customerid,
        c.firstname,
        c.country,
        o.total_order_amount,
        DENSE_RANK() OVER (PARTITION BY o.paymentid ORDER BY o.total_order_amount DESC) AS rank_
    FROM
        customers c
    JOIN
        orders o ON c.customerid = o.customerid
)
SELECT
    *
FROM
    cte
WHERE
    rank_ = 1
ORDER BY
    paymentid;


# 8) Write a query to rank the products with on the basis of highest selling price within each category.
# Prevent skipping of ranks.
# Print ProductID, Product Name, CategoryID, Brand, Sale Price and Rank.

SELECT
    productid,
    product,
    category_id,
    brand,
    sale_price,
    DENSE_RANK() OVER (PARTITION BY category_id ORDER BY sale_price DESC) AS rank_
FROM
    products;
    

# 9) Identify which was the highest transaction value for each payment method.
# Print Payment ID, Payment Type and Highest transaction value for that particular payment type.
# Include all payment methods irrespective of their active status.
# Sort the result set in ascending order of Payment ID.

SELECT 
    paymentid, paymenttype, MAX(total_order_amount)
FROM
    payments p
        LEFT JOIN
    orders o USING (paymentid)
GROUP BY 1 , 2
ORDER BY 1;


# 10) After how many days customer placed their second order.
# Print Customer ID and number of days.
# Sort the table on Customer Id in ascending order.

WITH cte AS (
    SELECT
        customerid,
        orderdate,
        ROW_NUMBER() OVER (PARTITION BY customerid ORDER BY orderdate) AS rnk
    FROM
        orders
)
SELECT
    a.customerid,
    DATEDIFF(a.orderdate, b.orderdate) AS days_between_orders
FROM
    cte a
JOIN
    cte b ON a.customerid = b.customerid AND a.rnk = 2 AND b.rnk = 1
ORDER BY
    a.customerid;


# 11) Print all details of the Customer with Maximum and Minimum total spent.
# Customer details with maximum total spent should be in the first line and Customer details with minimum 
# total spent should be in the second line.

WITH CTE AS (
    SELECT
        c.CustomerID,
        SUM(od.Quantity * p.Sale_Price) AS TotalSpent
    FROM
        Customers c
    JOIN
        Orders o ON c.CustomerID = o.CustomerID
    JOIN
        OrderDetails od ON o.OrderID = od.OrderID
    JOIN
        Products p USING (ProductID)
    GROUP BY
        c.CustomerID
),
CTE_2 AS (
    SELECT
        MAX(TotalSpent) AS MaxSpent,
        MIN(TotalSpent) AS MinSpent
    FROM
        CTE
)
SELECT
    c.*
FROM
    CTE
JOIN
    CTE_2 ON CTE.TotalSpent = CTE_2.MaxSpent OR CTE.TotalSpent = CTE_2.MinSpent
JOIN
    Customers c USING(CustomerID)
ORDER BY
    CTE.TotalSpent DESC;


# 12) Print the following Pivot Table
# The values in the matrix represent total sum of revenue generated out of orders ordered from the 
# different cities in the database through the different years and quarters. (Consider OrderDate)
# Sort the result in ascending order of Year, for records with same year, sort them in ascending order of Quarter.


SELECT
    YEAR(orderdate) AS Year,
    QUARTER(orderdate) AS Quarter,
    SUM(CASE WHEN city = 'Geneva' THEN total_order_amount END) AS Geneva,
    SUM(CASE WHEN city = 'Brisbane' THEN total_order_amount END) AS Brisbane,
    SUM(CASE WHEN city = 'Chennai' THEN total_order_amount END) AS Chennai,
    SUM(CASE WHEN city = 'San Francisco' THEN total_order_amount END) AS SanFrancisco
FROM
    customers c
LEFT JOIN
    orders o USING (customerid)
GROUP BY
    1, 2
ORDER BY
    1, 2;


# 13) Our company wants to know about those products which is not sold by any Supplier.
# Print the Product ID and product name of those products.
# Sort the output in ascending order of Product ID

SELECT 
    ProductID, Product
FROM
    products
WHERE
    ProductID NOT IN (SELECT DISTINCT
            ProductID
        FROM
            orderdetails)
ORDER BY 1;


# 14)Get the number of orders placed for each year in every week.
# Print Week number ,Orders placed in 2020 and Orders placed in 2021
# Sort the result in ascending order of week number.

SELECT 
    WEEK(orderdate) AS week_,
    SUM(CASE
        WHEN YEAR(orderdate) = 2020 THEN 1
        ELSE 0
    END) AS y_2020,
    SUM(CASE
        WHEN YEAR(orderdate) = 2021 THEN 1
        ELSE 0
    END) AS y_2021
FROM
    orders
GROUP BY 1
ORDER BY 1








