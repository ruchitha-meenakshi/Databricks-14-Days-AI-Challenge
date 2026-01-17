-------------------------------------------------------------
--- SYNC THE TABLES ---
-------------------------------------------------------------
-- Switch to the correct Catalog --
USE CATALOG ecommerce;

-- Switch to the correct Schema --
USE SCHEMA silver;

-- Re-create the tables to pull in the new COMBINED data from the files
CREATE OR REPLACE TABLE cleaned_traffic 
AS SELECT * FROM delta.`/Volumes/workspace/ecommerce/ecommerce_data/medallion/silver`;

-- Verify we have data from BOTH months (Oct & Nov)
SELECT MIN(event_time), MAX(event_time) FROM cleaned_traffic;

--------------------------------------------------------------
-- BUILD DASHBOARD: revenue trends, funnels, top products --
--------------------------------------------------------------
--- 1. Revenue Trends (The Line Chart) -----
--------------------------------------------------------------
-- Query Name: "Daily Revenue Trends"--
WITH daily_stats AS (
    SELECT 
        DATE(event_time) as event_date, 
        SUM(price) as daily_revenue
    FROM silver.cleaned_traffic
    WHERE event_type = 'purchase'
    GROUP BY 1
)
SELECT 
    event_date, 
    daily_revenue,
    -- Calculate 7-Day Moving Average for smoothing
    AVG(daily_revenue) OVER (
        ORDER BY event_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as ma7_revenue
FROM daily_stats
ORDER BY event_date;

--------------------------------------------------------------
--- 2. Conversion Funnel (The Bar Chart) -----
--------------------------------------------------------------
-- Query Name: "Category Conversion Funnel"--
SELECT 
    category_code, 
    COUNT(CASE WHEN event_type = 'view' THEN 1 END) as total_views,
    COUNT(CASE WHEN event_type = 'cart' THEN 1 END) as total_carts,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) as total_purchases,
    -- Calculate View-to-Purchase Conversion Rate
    ROUND(COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN event_type = 'view' THEN 1 END), 0), 2) as conversion_rate_pct
FROM silver.cleaned_traffic
WHERE category_code IS NOT NULL
GROUP BY 1
HAVING total_views > 1000  -- Filter for major categories only
ORDER BY conversion_rate_pct DESC
LIMIT 15;
--------------------------------------------------------------
--- 3. Customer Tiers (The Pie Chart) -----
--------------------------------------------------------------
-- Query Name: "Customer Loyalty Tiers" --
WITH user_spending AS (
    SELECT 
        user_id, 
        COUNT(*) as purchase_count
    FROM silver.cleaned_traffic 
    WHERE event_type = 'purchase' 
    GROUP BY user_id
)
SELECT
    CASE 
        WHEN purchase_count >= 10 THEN 'VIP 💎'
        WHEN purchase_count >= 5 THEN 'Loyal 🥇'
        ELSE 'Regular 👤' 
    END as tier,
    COUNT(user_id) as customer_count
FROM user_spending
GROUP BY 1;
