 -- =====================================================================================================
 -- Data Analysis – Customer Subscriptions & Complaints
 
 -- =====================================================================================================
 
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

use order_db;


-- =============================================================================================================================
-- DATA MODELING DASHBOARD
-- =============================================================================================================================


-- LINK TABLEAU PUBLIC:  https://public.tableau.com/views/subs_order_issues/DACHBOARD3?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link


-- DATASET 1 

use order_db;

SELECT
    o.id AS order_id,
    o.user_id,
    o.created_at,
    o.delay_minutes,
	o.delay_bucket,
	o.delivery_status,
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
    END AS has_complaint,

    CASE
        WHEN o.delay_minutes > 0 THEN 1 ELSE 0
    END AS is_delayed,

    CASE
        WHEN EXISTS (
            SELECT 1
            FROM clean_orders_complaint oc
            WHERE oc.order_id = o.id
        )
        OR o.delay_minutes > 0
        THEN 1 ELSE 0
    END AS is_issue

FROM clean_orders_order o

JOIN clean_home_usersubscription u
    ON u.user_id = o.user_id
    AND o.created_at >= u.subscription_start
    AND (u.subscription_end IS NULL OR o.created_at <= u.subscription_end)

JOIN clean_home_subscriptioninfo s
    ON s.id = u.subscription_info_id;


   
 --  DATASET 2
   
  
   
   SELECT
    oc.order_id,
    oc.created_at,
    oc.is_active,
    oc.problem_id,
    oc.product_code,
    op.name AS problem_name
FROM clean_orders_complaint oc
LEFT JOIN clean_orders_problem op
    ON op.id = oc.problem_id;
   
   