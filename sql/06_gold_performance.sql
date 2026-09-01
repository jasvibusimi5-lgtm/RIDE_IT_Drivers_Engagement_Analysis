-- QUERY 6: Gold Level Performance
USE rideit_analytics;

SELECT 
    CASE 
        WHEN d.gold_level_count = 0 THEN '0 (No Gold Tier)'
        WHEN d.gold_level_count BETWEEN 1 AND 10 THEN '1-10 (Bronze/Silver)'
        WHEN d.gold_level_count BETWEEN 11 AND 30 THEN '11-30 (Solid Gold)'
        ELSE '31+ (Elite Gold Legend)'
    END AS gold_tier,
    COUNT(DISTINCT d.id_driver) AS total_drivers,
    SUM(a.rides) AS total_rides,
    ROUND(SUM(a.rides) * 1.0 / COUNT(DISTINCT d.id_driver), 2) AS avg_rides_per_driver,
    ROUND(SUM(a.bookings) * 100.0 / NULLIF(SUM(a.offers), 0), 2) AS acceptance_rate_pct,
    ROUND(SUM(a.rides) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS completion_rate_pct,
    ROUND(AVG(d.driver_rating), 2) AS avg_rating
FROM rideit_drivers d
LEFT JOIN rideit_activity a ON d.id_driver = a.id_driver
GROUP BY 
    CASE 
        WHEN d.gold_level_count = 0 THEN '0 (No Gold Tier)'
        WHEN d.gold_level_count BETWEEN 1 AND 10 THEN '1-10 (Bronze/Silver)'
        WHEN d.gold_level_count BETWEEN 11 AND 30 THEN '11-30 (Solid Gold)'
        ELSE '31+ (Elite Gold Legend)'
    END
ORDER BY avg_rides_per_driver DESC;
