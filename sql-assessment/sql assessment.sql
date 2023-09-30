-- Google BigQuery SQL
-- data stored in dataset jcd
-- 1. Write a query to get the sum of impressions by day.

WITH DateConverted AS (
    SELECT
        DATE(date) AS day,
        impressions
    FROM 
        jcd.marketing_performance
)

SELECT 
    day,
    SUM(impressions) AS total_impressions
FROM 
    DateConverted
GROUP BY 
    day
ORDER BY 
    day;

--2.Write a query to get the top three revenue-generating states in order of best to worst. How much revenue did the third best state generate?

SELECT 
    state,
    SUM(revenue) AS total_revenue
FROM 
    jcd.website_revenue
GROUP BY 
    state
ORDER BY 
    total_revenue DESC
LIMIT 3;

-- 37577

--3.Write a query that shows total cost, impressions, clicks, and revenue of each campaign. Make sure to include the campaign name in the output.

SELECT 
    ci.name AS campaign_name,
    ma.total_cost,
    ma.total_impressions,
    ma.total_clicks,
    ra.total_revenue
FROM 
    jcd.campaign_info ci
LEFT JOIN (
    SELECT 
        campaign_id,
        SUM(cost) AS total_cost,
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks
    FROM 
        jcd.marketing_performance
    GROUP BY 
        campaign_id
) ma ON ci.id = ma.campaign_id
LEFT JOIN (
    SELECT 
        campaign_id,
        SUM(revenue) AS total_revenue
    FROM 
        jcd.website_revenue
    GROUP BY 
        campaign_id
) ra ON ci.id = ra.campaign_id
ORDER BY 
    ci.name;

--4.Write a query to get the number of conversions of Campaign5 by state. Which state generated the most conversions for this campaign?

SELECT 
    mp.geo AS state,
    SUM(mp.conversions) AS total_conversions
FROM 
    jcd.marketing_performance mp
JOIN 
    jcd.campaign_info ci ON mp.campaign_id = ci.id
WHERE 
    ci.name = 'Campaign5'
GROUP BY 
    mp.geo
ORDER BY 
    total_conversions DESC;

--5.In your opinion, which campaign was the most efficient, and why?
-- Query to determine campaign efficiency using ROI

SELECT 
    ci.name AS campaign_name,
    ma.total_cost,
    ma.total_impressions,
    ma.total_clicks,
    ra.total_revenue,
    (ra.total_revenue - ma.total_cost) / ma.total_cost AS ROI
FROM 
    jcd.campaign_info ci
LEFT JOIN (
    SELECT 
        campaign_id,
        SUM(cost) AS total_cost,
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks
    FROM 
        jcd.marketing_performance
    GROUP BY 
        campaign_id
) ma ON ci.id = ma.campaign_id
LEFT JOIN (
    SELECT 
        campaign_id,
        SUM(revenue) AS total_revenue
    FROM 
        jcd.website_revenue
    GROUP BY 
        campaign_id
) ra ON ci.id = ra.campaign_id
ORDER BY 
    ROI DESC;

--Using ROI to measure efficency and Campaign5 is highest.

--6.Write a query that showcases the best day of the week (e.g., Sunday, Monday, Tuesday, etc.) to run ads.
WITH DailyAggregation AS (
    SELECT 
        FORMAT_DATE('%A', mp.date) AS day_of_week,
        SUM(mp.cost) AS total_cost,
        COALESCE(SUM(wr.revenue), 0) AS total_revenue
    FROM 
        jcd.marketing_performance mp
    LEFT JOIN
        jcd.website_revenue wr ON mp.campaign_id = wr.campaign_id AND mp.date = wr.date
    GROUP BY 
        day_of_week
)

SELECT 
    day_of_week,
    total_cost,
    total_revenue,
    (total_revenue - total_cost) / total_cost AS ROI
FROM 
    DailyAggregation
ORDER BY 
    ROI DESC;
