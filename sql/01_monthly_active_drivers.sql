-- QUERY 1: Monthly Active Drivers
USE rideit_analytics;

SELECT 
    DATE_FORMAT(active_date, '%Y-%m') AS activity_month,
    COUNT(DISTINCT id_driver) AS monthly_active_drivers,
    COUNT(active_date) AS total_active_days,
    ROUND(COUNT(active_date) * 1.0 / COUNT(DISTINCT id_driver), 2) AS avg_active_days_per_driver
FROM rideit_activity
GROUP BY DATE_FORMAT(active_date, '%Y-%m')
ORDER BY activity_month ASC;
