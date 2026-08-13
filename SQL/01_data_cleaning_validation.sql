use order_db;

SHOW TABLES;


/*   Checking the data after import from CSV files to db */


SELECT 'orders_order' AS table_name, COUNT(*) AS row_count
FROM orders_order

UNION ALL

SELECT 'home_subscriptioninfo', COUNT(*)
FROM home_subscriptioninfo

UNION ALL

SELECT 'home_usersubscription', COUNT(*)
FROM home_usersubscription

UNION ALL

SELECT 'orders_complaint', COUNT(*)
FROM orders_complaint

UNION ALL

SELECT 'orders_problem', COUNT(*)
FROM orders_problem

UNION ALL

SELECT 'orders_problemgroup', COUNT(*)
FROM orders_problemgroup

UNION ALL

SELECT 'orders_problemproblemgroup', COUNT(*)
FROM orders_problemproblemgroup;



-- -----------------------------------
-- 1.orders_order table

-- -----------------------------------
 
  
DESCRIBE orders_order;
 
select * from orders_order limit 10;


SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
  SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS missing_user_id
FROM orders_order;

-- checking quality of date columns before converting them  from varchart to date


SELECT
  'created_at' AS column_name,
  SUM(created_at IS NULL OR created_at = '') AS empty_values,
  SUM(created_at REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}') AS dmy_format,
  SUM(created_at REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}') AS iso_format,
  SUM(
    created_at IS NOT NULL
    AND created_at <> ''
    AND STR_TO_DATE(created_at, '%d/%m/%Y %H:%i') IS NULL
  ) AS invalid_values
FROM orders_order

UNION ALL

SELECT
  'status_finished_at',
  SUM(status_finished_at IS NULL OR status_finished_at = ''),
  SUM(status_finished_at REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'),
  SUM(status_finished_at REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}'),
  SUM(
    status_finished_at IS NOT NULL
    AND status_finished_at <> ''
    AND STR_TO_DATE(status_finished_at, '%d/%m/%Y %H:%i') IS NULL
  )
FROM orders_order

UNION ALL

SELECT
  'shipping_date',
  SUM(shipping_date IS NULL OR shipping_date = ''),
  SUM(shipping_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'),
  SUM(shipping_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}'),
  SUM(
    shipping_date IS NOT NULL
    AND shipping_date <> ''
    AND STR_TO_DATE(shipping_date, '%d/%m/%Y') IS NULL
  )
FROM orders_order;

-- Payment column check

SELECT
    'negative_eur_with_positive_original' AS issue_type,
    COUNT(*) AS total
FROM orders_order
WHERE last_payment_total_price_eur <= 0
  AND last_payment_total_price > 0

UNION ALL

SELECT
    'eur_null',
    SUM(last_payment_total_price_eur IS NULL)
FROM orders_order

UNION ALL

SELECT
    'eur_zero',
    SUM(last_payment_total_price_eur = 0)
FROM orders_order

UNION ALL

SELECT
    'eur_negative',
    COUNT(*)
FROM orders_order
WHERE last_payment_total_price_eur < 0;


-- ====================

CREATE TABLE clean_orders_order AS
SELECT
    id,
    STR_TO_DATE(
        created_at,
        '%d/%m/%Y %H:%i'
    ) AS created_at,

    is_by_new_user,
    last_payment_total_price,
    last_payment_total_price_eur,
    total_pharmacy,
    total_pharmacy_eur,
    user_id,
    STR_TO_DATE(
        status_finished_at,
        '%d/%m/%Y %H:%i'
    ) AS status_finished_at,

    STR_TO_DATE(
        shipping_date,
        '%d/%m/%Y'
    ) AS shipping_date,

    time_slot_start,
    time_slot_end

FROM orders_order;


ALTER TABLE clean_orders_order
MODIFY total_pharmacy DOUBLE;

ALTER TABLE clean_orders_order
MODIFY total_pharmacy_eur DOUBLE;

Describe clean_orders_order;

SELECT 'orders_order',COUNT(*) FROM orders_order
UNION ALL
SELECT 'clean_orders_order',COUNT(*) FROM clean_orders_order;

-- ----------------------------------

-- 2.home_subscriptioninfo
-- -----------------------------------
DESCRIBE home_subscriptioninfo;

SELECT * FROM home_subscriptioninfo;


CREATE TABLE clean_home_subscriptioninfo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  duration_days INT NOT NULL,
  UNIQUE(product_id)
);

INSERT INTO clean_home_subscriptioninfo (product_id, duration_days)
SELECT product_id, duration_days
FROM home_subscriptioninfo
WHERE product_id IS NOT NULL
  AND duration_days IS NOT NULL;
 
 
SELECT * FROM clean_home_subscriptioninfo;

describe clean_home_subscriptioninfo;
describe home_subscriptioninfo;


SELECT 'clean_home_subscriptioninfo',COUNT(*) FROM clean_home_subscriptioninfo
UNION ALL
SELECT 'home_subscriptioninfo',COUNT(*) FROM home_subscriptioninfo;



-- ----------------------------------

-- 3. home_usersubscription
-- -----------------------------------

 DESCRIBE home_usersubscription;

  
SELECT
 'subscription_start',
  COUNT(*) AS total,
  SUM(subscription_start IS NULL OR subscription_start = '') AS empty_values,
  SUM(subscription_start REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}') AS dmy_format,
  SUM(subscription_start REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}') AS iso_format,
  SUM(
    subscription_start IS NOT NULL
    AND subscription_start <> ''
    AND STR_TO_DATE(subscription_start, '%d/%m/%Y %H:%i') IS NULL
  ) AS invalid_values
FROM home_usersubscription

UNION ALL

SELECT
 'subscription_end',
  COUNT(*) AS total,
  SUM(subscription_end IS NULL OR subscription_end = '') AS empty_values,
  SUM(subscription_end REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}') AS dmy_format,
  SUM(subscription_end REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}') AS iso_format,
  SUM(
    subscription_end IS NOT NULL
    AND subscription_end <> ''
    AND STR_TO_DATE(subscription_end, '%d/%m/%Y %H:%i') IS NULL
  ) AS invalid_values
FROM home_usersubscription

UNION ALL

SELECT
 'deactivated_at',
  COUNT(*) AS total,
  SUM(deactivated_at IS NULL OR deactivated_at = '') AS empty_values,
  SUM(deactivated_at REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}') AS dmy_format,
  SUM(deactivated_at REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}') AS iso_format,
  SUM(
    deactivated_at IS NOT NULL
    AND deactivated_at <> ''
    AND STR_TO_DATE(deactivated_at, '%d/%m/%Y %H:%i') IS NULL
  ) AS invalid_values
FROM home_usersubscription;



CREATE TABLE clean_home_usersubscription (
  id INT AUTO_INCREMENT PRIMARY KEY,

  subscription_info_id INT NOT NULL,
  user_id INT NOT NULL,

  subscription_start DATETIME NOT NULL,
  subscription_end DATETIME DEFAULT NULL,

  deactivated_at DATETIME DEFAULT NULL,
  deactivated_by_id INT DEFAULT NULL,

  UNIQUE (user_id, subscription_info_id, subscription_start)
);

INSERT INTO clean_home_usersubscription (
  subscription_info_id,
  user_id,
  subscription_start,
  subscription_end,
  deactivated_at,
  deactivated_by_id
)
SELECT
  subscription_info_id,
  user_id,

  STR_TO_DATE(NULLIF(subscription_start, ''), '%d/%m/%Y %H:%i'),
  STR_TO_DATE(NULLIF(subscription_end, ''), '%d/%m/%Y %H:%i'),
  STR_TO_DATE(NULLIF(deactivated_at, ''), '%d/%m/%Y %H:%i'),

  NULLIF(deactivated_by_id, '')
FROM home_usersubscription;
 

describe clean_home_usersubscription;


SELECT
  COUNT(*) AS total,
  SUM(subscription_start IS NULL) AS start_nulls,
  SUM(subscription_end IS NULL) AS end_nulls,
  SUM(deactivated_at IS NULL) AS deactivated_nulls,
  SUM(subscription_start > subscription_end) AS invalid_range,
  SUM(deactivated_at < subscription_start) AS invalid_deactivation
FROM clean_home_usersubscription;

SELECT *
FROM clean_home_usersubscription
WHERE deactivated_at IS NOT NULL
  AND deactivated_at < subscription_start;

SELECT 'clean_home_usersubscription',COUNT(*) FROM clean_home_usersubscription
UNION ALL
SELECT 'home_usersubscription',COUNT(*) FROM home_usersubscription;



-- ----------------------------------------
-- 4.orders_problemgroup
-- ----------------------------------------

DESCRIBE orders_problemgroup;

SELECT name, COUNT(*)
FROM orders_problemgroup
GROUP BY name
HAVING COUNT(*) > 1;


CREATE TABLE clean_order_problemgroup (
  id INT AUTO_INCREMENT PRIMARY KEY,
  created_at DATETIME NOT NULL,
  name VARCHAR(50) NOT NULL UNIQUE
);


INSERT INTO clean_order_problemgroup (id, created_at, name)
SELECT
  id,
  STR_TO_DATE(created_at, '%d/%m/%Y %H:%i'),
  name
FROM orders_problemgroup;

DESCRIBE clean_order_problemgroup;


SELECT  'clean_order_problemgroup',COUNT(*) FROM clean_order_problemgroup
UNION ALL
SELECT  'orders_problemgroup',COUNT(*) FROM orders_problemgroup;


-- ----------------------------------------
-- 5.orders_problemproblemgroup
-- ----------------------------------------

DESCRIBE orders_problemproblemgroup;

SELECT group_id, problem_id, COUNT(*)
FROM orders_problemproblemgroup
GROUP BY group_id, problem_id
HAVING COUNT(*) > 1;
 
SELECT *
FROM orders_problemproblemgroup
WHERE STR_TO_DATE(created_at, '%d/%m/%Y %H:%i') IS NULL;


 CREATE TABLE clean_orders_problemproblemgroup (
  id INT AUTO_INCREMENT PRIMARY KEY,
  created_at DATETIME NOT NULL,
  group_id INT NOT NULL,
  problem_id INT NOT NULL,
  UNIQUE (group_id, problem_id)
);
 

DESCRIBE clean_orders_problemproblemgroup;

INSERT INTO clean_orders_problemproblemgroup (id, created_at, group_id,problem_id )
SELECT
  id,
  STR_TO_DATE(created_at, '%d/%m/%Y %H:%i'),
  group_id,
  problem_id
FROM orders_problemproblemgroup;


SELECT 'clean_orders_problemproblemgroup',COUNT(*) FROM clean_orders_problemproblemgroup
UNION ALL
SELECT 'orders_problemproblemgroup',COUNT(*) FROM orders_problemproblemgroup;


-- ----------------------------------------
-- 6.orders_complaint
-- ----------------------------------------

   
 DESCRIBE orders_complaint;

SELECT *
FROM orders_complaint
WHERE STR_TO_DATE(created_at, '%d/%m/%Y %H:%i') IS NULL;


SELECT
    'invalid_created_at' AS issue_type, COUNT(*) AS total
FROM orders_complaint
WHERE STR_TO_DATE(created_at, '%d/%m/%Y %H:%i') IS NULL

UNION ALL

SELECT
    'missing_product_code', COUNT(*)
FROM orders_complaint
WHERE product_code IS NULL OR product_code = ''

UNION ALL

SELECT
    'invalid_quantity', COUNT(*)
FROM orders_complaint
WHERE quantity IS NULL OR quantity < 0

UNION ALL

SELECT
    'duplicate_records', COUNT(*)
FROM (
    SELECT order_id, problem_id, product_code, user_id
    FROM orders_complaint
    GROUP BY order_id, problem_id, product_code, user_id
    HAVING COUNT(*) > 1
) t;


SELECT order_id, problem_id, product_code, user_id, COUNT(*)
FROM orders_complaint
GROUP BY order_id, problem_id, product_code, user_id
HAVING COUNT(*) > 1;


-- ----


CREATE TABLE clean_orders_complaint (
  id INT  PRIMARY KEY,
  created_at DATETIME NOT NULL,
  is_active TINYINT ,
  marked_as_signal_by_id INT NULL,
  order_id INT NOT NULL,
  problem_id INT NOT NULL,
  product_code VARCHAR(50) NULL,
  quantity INT NULL,
  user_id INT NOT NULL
);


INSERT INTO clean_orders_complaint (
  id,
  created_at,
  is_active,
  marked_as_signal_by_id,
  order_id,
  problem_id,
  product_code,
  quantity,
  user_id
)
SELECT
  id,
  STR_TO_DATE(NULLIF(created_at, ''), '%d/%m/%Y %H:%i'),
  is_active,
  marked_as_signal_by_id,
  order_id,
  problem_id,
  product_code,
  quantity,
  user_id
FROM orders_complaint;

SELECT order_id, problem_id, product_code, user_id, COUNT(*)
FROM orders_complaint
GROUP BY order_id, problem_id, product_code, user_id
HAVING COUNT(*) > 1;

SELECT order_id, problem_id, product_code, user_id, COUNT(*)
FROM clean_orders_complaint
GROUP BY order_id, problem_id, product_code, user_id
HAVING COUNT(*) > 1;

DELETE t1
FROM clean_orders_complaint t1
JOIN clean_orders_complaint t2
  ON t1.order_id = t2.order_id
 AND t1.problem_id = t2.problem_id
 AND COALESCE(t1.product_code,'') = COALESCE(t2.product_code,'')
 AND t1.user_id = t2.user_id
 AND t1.quantity = t2.quantity
 AND t1.id > t2.id;


SELECT *
FROM clean_orders_complaint
WHERE order_id IN (2553225, 2688501, 2749469);


SELECT  'clean_orders_complaint',COUNT(*) FROM clean_orders_complaint
UNION ALL
SELECT  'orders_complaint',COUNT(*) FROM orders_complaint;

DESCRIBE clean_orders_complaint;

SELECT DISTINCT is_active
FROM clean_orders_complaint;

-- ----------------------------------------
-- 7.orders_problem
-- ----------------------------------------


 DESCRIBE orders_problem;

SELECT *
FROM orders_problem
WHERE name IN ('-', '--', 'test')
   OR name REGEXP '^[0-9]+$';
  
  
SELECT *
FROM orders_problem
WHERE STR_TO_DATE(created_at, '%d/%m/%Y %H:%i') IS NULL;


SELECT LOWER(name), COUNT(*)
FROM orders_problem
GROUP BY LOWER(name)
HAVING COUNT(*) > 1;


--  NEW table with clean data
  
CREATE TABLE clean_orders_problem (
  id INT AUTO_INCREMENT PRIMARY KEY,

  created_at DATETIME NOT NULL,
   is_active BOOLEAN NOT NULL DEFAULT 1,
   name VARCHAR(64) NOT NULL UNIQUE,
  user_id INT NOT NULL
);

 
 INSERT INTO clean_orders_problem (
  id,
  created_at,
  is_active,
  name,
  user_id
)
SELECT
  id,
  created_at,
  is_active,
  name,
  user_id
FROM (
  SELECT
    id,
    STR_TO_DATE(NULLIF(created_at, ''), '%d/%m/%Y %H:%i') AS created_at,
    is_active,
    TRIM(REGEXP_REPLACE(name, '\\s+', ' ')) AS name,
    user_id,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(TRIM(REGEXP_REPLACE(name, '\\s+', ' ')))
      ORDER BY id DESC
    ) AS rn

  FROM orders_problem
   WHERE
	  name IS NOT NULL
	  AND TRIM(name) <> ''
	  AND name NOT IN ('-', '--', 'test')
	  AND name NOT REGEXP '^[0-9]+$'  
) t
WHERE t.rn = 1;
 
SELECT
  'orders_problem',
  COUNT(*) AS total,
  SUM(created_at IS NULL) AS bad_dates,
  SUM(name = '' OR name IS NULL) AS empty_names,
  SUM(name REGEXP '^[0-9]+$') AS numeric_names
FROM orders_problem

UNION ALL

SELECT
 'clean_orders_problem',
  COUNT(*) AS total,
  SUM(created_at IS NULL) AS bad_dates,
  SUM(name = '' OR name IS NULL) AS empty_names,
  SUM(name REGEXP '^[0-9]+$') AS numeric_names
FROM clean_orders_problem;



DESCRIBE clean_orders_problem;

SELECT DISTINCT is_active
FROM clean_orders_problem;


-- ----------------------------------------
-- END 
-- ----------------------------------------
  
  

-- --------------------
/* 	Validation check */

-- -------------------

SELECT
    'orders_order' AS table_name,
    (SELECT COUNT(*) FROM orders_order) AS raw_rows,
    (SELECT COUNT(*) FROM clean_orders_order) AS clean_rows,
    (SELECT COUNT(*) FROM orders_order)
      - (SELECT COUNT(*) FROM clean_orders_order) AS removed_rows

UNION ALL

SELECT
    'orders_problem',
    (SELECT COUNT(*) FROM orders_problem),
    (SELECT COUNT(*) FROM clean_orders_problem),
    (SELECT COUNT(*) FROM orders_problem)
      - (SELECT COUNT(*) FROM clean_orders_problem)

UNION ALL

SELECT
    'orders_complaint',
    (SELECT COUNT(*) FROM orders_complaint),
    (SELECT COUNT(*) FROM clean_orders_complaint),
    (SELECT COUNT(*) FROM orders_complaint)
      - (SELECT COUNT(*) FROM clean_orders_complaint)

UNION ALL  

SELECT
    'home_subscriptioninfo',
    (SELECT COUNT(*) FROM home_subscriptioninfo),
    (SELECT COUNT(*) FROM clean_home_subscriptioninfo),
    (SELECT COUNT(*) FROM home_subscriptioninfo)
      - (SELECT COUNT(*) FROM clean_home_subscriptioninfo)
      
UNION ALL  

SELECT
    'home_usersubscription',
    (SELECT COUNT(*) FROM home_usersubscription),
    (SELECT COUNT(*) FROM clean_home_usersubscription),
    (SELECT COUNT(*) FROM home_usersubscription)
      - (SELECT COUNT(*) FROM clean_home_usersubscription)


UNION ALL  

SELECT
    'order_problemgroup',
    (SELECT COUNT(*) FROM orders_problemgroup),
    (SELECT COUNT(*) FROM clean_order_problemgroup),
    (SELECT COUNT(*) FROM orders_problemgroup)
      - (SELECT COUNT(*) FROM clean_order_problemgroup)
 
  UNION ALL  

SELECT
    'orders_problemproblemgroup',
    (SELECT COUNT(*) FROM orders_problemproblemgroup),
    (SELECT COUNT(*) FROM clean_orders_problemproblemgroup),
    (SELECT COUNT(*) FROM orders_problemproblemgroup)
      - (SELECT COUNT(*) FROM clean_orders_problemproblemgroup);

     


-- ----------------------------------------
-- END 
-- ----------------------------------------

