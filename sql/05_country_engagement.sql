-- QUERY 5: Country Breakdown (Germany DE vs Spain ES)
USE rideit_analytics;

SELECT 
    d.country_code,
    CASE 
        WHEN d.country_code = 'DE' THEN 'Germany'
        WHEN d.country_code = 'ES' THEN 'Spain'
        ELSE d.country_code 
    END AS country_name,
    COUNT(DISTINCT d.id_driver) AS total_drivers,
    SUM(a.offers) AS total_offers,
    SUM(a.bookings) AS total_bookings,
    SUM(a.rides) AS total_completed_rides,
    ROUND(SUM(a.bookings) * 100.0 / NULLIF(SUM(a.offers), 0), 2) AS acceptance_rate_pct,
    ROUND(SUM(a.rides) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS completion_rate_pct,
    ROUND(SUM(a.bookings_cancelled_by_driver) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS driver_cancellation_rate_pct,
    ROUND(AVG(d.driver_rating), 2) AS avg_rating
FROM rideit_drivers d
LEFT JOIN rideit_activity a ON d.id_driver = a.id_driver
GROUP BY d.country_code
ORDER BY total_completed_rides DESC;
