create database BikeStore
go 
use BikeStore

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    phone       VARCHAR(25),
    email       VARCHAR(100),
    street      VARCHAR(100),
    city        VARCHAR(50),
    state       VARCHAR(50),
    zip_code    VARCHAR(10)
);

CREATE TABLE stores (
    store_id   INTEGER PRIMARY KEY,
    store_name VARCHAR(100),
    phone      VARCHAR(25),
    email      VARCHAR(100),
    street     VARCHAR(100),
    city       VARCHAR(50),
    state      VARCHAR(50),
    zip_code   VARCHAR(10)
);

CREATE TABLE staffs (
    staff_id   INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    email      VARCHAR(100),
    phone      VARCHAR(25),
    active     INTEGER,
    store_id   INTEGER,
    manager_id INTEGER,

    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (manager_id) REFERENCES staffs(staff_id)
);

create TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER,
    order_status  INTEGER,
    order_date    DATE,
    required_date DATE,
    shipped_date  Date,
    store_id      INTEGER,
    staff_id      INTEGER,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (staff_id) REFERENCES staffs(staff_id)
);

CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE brands (
    brand_id   INTEGER PRIMARY KEY,
    brand_name VARCHAR(50)
);

CREATE TABLE products (
    product_id  INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    brand_id     INTEGER,
    category_id  INTEGER,
    model_year   INTEGER,
    list_price   DECIMAL(10,2),

    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE stocks (
    store_id   INTEGER,
    product_id INTEGER,
    quantity   INTEGER,

    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE order_items (
    order_id   INTEGER,
    item_id    INTEGER,
    product_id INTEGER,
    quantity   INTEGER,
    list_price DECIMAL(10,2),
    discount   DECIMAL(4,2),

    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

--1 table
BULK INSERT customers
FROM 'C:\Users\user\Desktop\project\customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 2 table
BULK INSERT stores
FROM 'C:\Users\user\Desktop\project\stores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--3 table
BULK INSERT categories
FROM 'C:\Users\user\Desktop\project\categories.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 4 table
BULK INSERT brands
FROM 'C:\Users\user\Desktop\project\brands.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--5 table
BULK INSERT staffs
FROM 'C:\Users\user\Desktop\project\staffs.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 6 table
BULK INSERT orders
FROM 'C:\Users\user\Desktop\project\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--alter table orders 
--alter column shipped_date varchar(30)


-- 7 table
BULK INSERT products
FROM 'C:\Users\user\Desktop\project\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 8 table
BULK INSERT stocks
FROM 'C:\Users\user\Desktop\project\stocks.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 9 table
BULK INSERT order_items
FROM 'C:\Users\user\Desktop\project\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);



--1 - view
CREATE VIEW vw_StoreSalesSummary AS
SELECT
    s.store_id,
    s.store_name,
    COUNT(DISTINCT o.order_id) AS num_orders,
    SUM(oi.quantity * oi.list_price) AS revenue,
    CASE 
        WHEN COUNT(DISTINCT o.order_id) > 0 
        THEN SUM(oi.quantity * oi.list_price) / COUNT(DISTINCT o.order_id)
        ELSE 0
    END AS aov  -- Average Order Value
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.store_id, s.store_name;

-- 2-view
CREATE VIEW vw_TopSellingProducts AS
select p.product_id,  p.product_name,  sum(quantity * p.list_price) as total_revenue, sum(quantity) as total_quantity  from orders as o1
join order_items as o2
on o1.order_id = o2.order_id
join products as p
on p.product_id = o2.product_id
group by p.product_id, p.product_name

-- 3-view
CREATE VIEW vw_InventoryStatus AS
SELECT
    p.product_id,
    p.product_name,
    s.store_id,
    s.store_name,
    st.quantity AS stock_quantity
FROM products p
JOIN stocks st ON p.product_id = st.product_id
JOIN stores s ON st.store_id = s.store_id
WHERE st.quantity < 10;  

-- 4-vew
CREATE  VIEW vw_StaffPerformance AS
SELECT
    st.staff_id,
    st.first_name,
    COUNT(DISTINCT o.order_id) AS num_orders,
    SUM(oi.quantity * oi.list_price) AS total_revenue
FROM staffs st
JOIN orders o ON st.staff_id = o.staff_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY st.staff_id, st.first_name;

-- 5-view
CREATE  VIEW vw_RegionalTrends AS
SELECT
    s.city,
    s.state,
    SUM(oi.quantity * oi.list_price) AS revenue
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.city, s.state;

-- 6-view
CREATE OR REPLACE VIEW vw_SalesByCategory AS
SELECT
    c.category_id,
    c.category_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.list_price) AS total_sales,
    SUM((oi.list_price - p.list_price) * oi.quantity) AS total_margin
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name;


-- 1-PROCEDURE
create PROCEDURE sp_CalculateStoreKPI @StoreID INT
AS
BEGIN
    

    SELECT
        o.store_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.list_price) AS total_revenue,
        SUM(oi.quantity * oi.list_price) 
            / COUNT(DISTINCT o.order_id) AS avg_order_value,
        SUM(oi.quantity) 
            / COUNT(DISTINCT o.order_id) AS avg_items_per_order
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.store_id = @StoreID
    GROUP BY o.store_id;
END


EXEC sp_CalculateStoreKPI @StoreID = 1

-- 2-PROCEDURE 
create PROCEDURE sp_GenerateRestockList @Quantity INT
AS
BEGIN
	
	select s1.store_id, product_id, quantity  from stocks as s1
	join stores as s2
	on s1.store_id = s2.store_id
	where quantity < @Quantity

end

EXEC sp_GenerateRestockList @Quantity =5

-- 3-PROCEDURE 
CREATE  PROCEDURE sp_CompareSalesYearOverYear
    @Year1 INT,
    @Year2 INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        YEAR(o.order_date) AS sales_year,
        SUM(oi.quantity * oi.list_price) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_date) IN (@Year1, @Year2)
    GROUP BY YEAR(o.order_date)
    ORDER BY sales_year;
END


-- 4-PROCEDURE 
alter  PROCEDURE sp_GetCustomerProfile @customer_id int
as
begin 

	
	select c.customer_id, first_name, count(distinct o1.order_id) as count_orders, sum(quantity * list_price) as total_revenue, sum(quantity) as quantity_products_buy from orders as o1 
	join order_items as o2
	on o1.order_id = o2.order_id
	join customers as c
	on c.customer_id = o1.customer_id
	where c.customer_id = @customer_id
	group by c.customer_id, first_name
end

exec sp_GetCustomerProfile @customer_id = 10

-- 1-KPI - Total Revenue
SELECT 
    SUM(oi.quantity * oi.list_price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- 2-KPI - Average Order Value (AOV)
SELECT 
    SUM(oi.quantity * oi.list_price) 
        / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id

-- 3-KPI - Inventory Turnover

WITH COGS AS (
    SELECT SUM(oi.quantity * p.list_price) AS total_cogs
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
),
Inventory AS (
    SELECT AVG(st.quantity * p.list_price) AS avg_inventory_value
    FROM stocks st
    JOIN products p ON st.product_id = p.product_id
)
SELECT 
    total_cogs / avg_inventory_value AS inventory_turnover
FROM COGS, Inventory;

--4- KPI- Revenue by Store
SELECT
    s.store_name,
    SUM(oi.quantity * oi.list_price) AS revenue
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.store_name
ORDER BY revenue DESC

-- 5- KPI- Gross Profit by Category
SELECT
    c.category_name,
    SUM(oi.quantity * oi.list_price) AS revenue,
    SUM(oi.quantity * p.list_price) AS cogs,
    SUM(oi.quantity * (oi.list_price - p.list_price)) AS gross_profit
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY gross_profit DESC

-- 6- KPI - Sales by Brand
SELECT
    b.brand_name,
    SUM(oi.quantity * oi.list_price) AS total_sales
FROM brands b
JOIN products p ON b.brand_id = p.brand_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY b.brand_name
ORDER BY total_sales DESC

-- 7- KPI - Staff Revenue Contribution
SELECT
    st.first_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price) AS revenue_generated
FROM staffs st
JOIN orders o ON st.staff_id = o.staff_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY st.first_name
ORDER BY revenue_generated DESC

