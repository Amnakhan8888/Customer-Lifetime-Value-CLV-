SELECT * FROM classicmodels.customers;
SELECT 
    c.customerNumber,
    c.customerName,
    ROUND(SUM(p.amount) / COUNT(DISTINCT o.orderNumber), 2) AS avg_purchase_value,
    COUNT(DISTINCT o.orderNumber) AS total_orders,
    ROUND(COUNT(DISTINCT o.orderNumber) / COUNT(DISTINCT o.customerNumber), 2) AS avg_purchase_frequency,
    DATEDIFF(MAX(o.orderDate), MIN(o.orderDate)) / 365.0 AS customer_lifespan_years,
    ROUND(
        (SUM(p.amount) / COUNT(DISTINCT o.orderNumber)) *
        (COUNT(DISTINCT o.orderNumber) / COUNT(DISTINCT o.customerNumber)) *
        (DATEDIFF(MAX(o.orderDate), MIN(o.orderDate)) / 365.0) *
        0.6, 2
    ) AS CLV
FROM 
    classicmodels.customers c
JOIN 
   classicmodels.payments p ON c.customerNumber = p.customerNumber
JOIN 
    classicmodels.orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.customerNumber, c.customerName;
SELECT 
    *,
    CASE
        WHEN CLV >= 300000 THEN 'High Value'
        WHEN CLV >= 100000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS clv_segment
FROM (
    SELECT 
        c.customerNumber,
        c.customerName,
        ROUND(SUM(p.amount) / COUNT(DISTINCT o.orderNumber), 2) AS avg_purchase_value,
        COUNT(DISTINCT o.orderNumber) AS total_orders,
        ROUND(COUNT(DISTINCT o.orderNumber) / COUNT(DISTINCT o.customerNumber), 2) AS avg_purchase_frequency,
        ROUND(DATEDIFF(MAX(o.orderDate), MIN(o.orderDate)) / 365.0, 2) AS customer_lifespan_years,
        ROUND(
            (SUM(p.amount) / COUNT(DISTINCT o.orderNumber)) *
            (COUNT(DISTINCT o.orderNumber) / COUNT(DISTINCT o.customerNumber)) *
            (DATEDIFF(MAX(o.orderDate), MIN(o.orderDate)) / 365.0) *
            0.6, 2
        ) AS CLV
    FROM 
         classicmodels.customers c
    JOIN 
       classicmodels.payments p ON c.customerNumber = p.customerNumber
    JOIN 
        classicmodels.orders o ON c.customerNumber = o.customerNumber
    GROUP BY 
        c.customerNumber, c.customerName
) AS clv_data;
