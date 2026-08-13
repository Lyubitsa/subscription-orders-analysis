
/* TASK:
Objective:
To analyze orders with a free delivery subscription and customer complaints.

Main question:
👉 How many of the subscription orders experienced delays or had a complaint filed? */


--  How many of the subscription orders  had a complaint filed?
SELECT
    s.duration_days AS abonament_lasts,
    s.id as abonament_id,
    COUNT(DISTINCT o.id) AS total_subscription_orders,
    COUNT(DISTINCT CASE 
        WHEN oc.id IS NOT NULL THEN o.id 
    END) AS orders_with_complaints,
    COUNT(DISTINCT CASE 
        WHEN oc.id IS NULL THEN o.id 
    END) AS orders_without_complaints
FROM clean_orders_order o
JOIN clean_home_usersubscription u
    ON u.user_id = o.user_id
JOIN clean_home_subscriptioninfo s
    ON s.id = u.subscription_info_id
LEFT JOIN clean_orders_complaint oc
    ON oc.order_id = o.id
WHERE o.created_at >= u.subscription_start
  AND (u.subscription_end IS NULL OR o.created_at <= u.subscription_end)
GROUP BY s.duration_days,s.id 
ORDER BY s.duration_days, s.id ;


-- Optimized  version

WITH base_orders AS (
    SELECT
        o.id,
        o.user_id,
        o.created_at,
        s.id AS subscription_id,
        s.duration_days,
        u.subscription_start,
        u.subscription_end,
        CASE 
            WHEN EXISTS (
                SELECT 1
                FROM clean_orders_complaint oc
                WHERE oc.order_id = o.id
            ) THEN 1 ELSE 0
        END AS has_complaint
    FROM clean_orders_order o
    JOIN clean_home_usersubscription u
        ON u.user_id = o.user_id
    JOIN clean_home_subscriptioninfo s
        ON s.id = u.subscription_info_id
    WHERE o.created_at >= u.subscription_start
      AND (u.subscription_end IS NULL OR o.created_at <= u.subscription_end)
)

SELECT
    duration_days AS abonament_lasts,
    subscription_id AS abonament_id,
    COUNT(*) AS total_orders,
    SUM(has_complaint) AS orders_with_complaints,
    COUNT(*) - SUM(has_complaint) AS orders_without_complaints
FROM base_orders
GROUP BY duration_days, subscription_id
ORDER BY duration_days, subscription_id;



-- ===================================================================================================
-- ================== How many subscription orders were delayed or had a complaint filed?
-- ===================================================================================================


   WITH base_orders AS (
    SELECT
        o.id,
        o.user_id,
        o.created_at,
        o.delay_minutes,
        s.id AS subscription_id,
        s.duration_days,
        u.subscription_start,
        u.subscription_end,

        CASE 
            WHEN EXISTS (
                SELECT 1
                FROM clean_orders_complaint oc
                WHERE oc.order_id = o.id
            ) THEN 1 ELSE 0
        END AS has_complaint

    FROM clean_orders_order o
    JOIN clean_home_usersubscription u
        ON u.user_id = o.user_id
        AND o.created_at >= u.subscription_start
        AND (u.subscription_end IS NULL OR o.created_at <= u.subscription_end)
    JOIN clean_home_subscriptioninfo s
        ON s.id = u.subscription_info_id
)
SELECT
    duration_days AS abonament_lasts,
    subscription_id AS abonament_id,
   COUNT(DISTINCT id) AS total_subscription_orders,
    SUM(has_complaint) AS complaint_orders,
    SUM(CASE WHEN delay_minutes > 0 THEN 1 ELSE 0 END) AS delayed_orders,
    SUM(
        CASE
            WHEN has_complaint = 1
              OR delay_minutes > 0
            THEN 1 ELSE 0
        END
    ) AS delayed_or_complaint_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN has_complaint = 1
                  OR delay_minutes > 0
                THEN 1 ELSE 0
            END
        ) / COUNT(DISTINCT id),
        2
    ) AS pct_delayed_or_complaint
FROM base_orders
GROUP BY duration_days, subscription_id
ORDER BY duration_days, subscription_id;