-- QUERY 8: Highest Cancellation Segments & Friction Analysis
USE rideit_analytics;

SELECT 
    d.service_type,
    d.country_code,
    CASE 
        WHEN d.driver_rating >= 4.85 THEN 'High Rating (4.85+)'
        WHEN d.driver_rating >= 4.70 THEN 'Medium Rating (4.70-4.84)'
        ELSE 'Low Rating (<4.70)'
    END AS rating_segment,
    COUNT(DISTINCT d.id_driver) AS drivers_count,
    SUM(a.bookings) AS total_bookings,
    SUM(a.bookings_cancelled_by_driver) AS driver_cancelled_bookings,
    SUM(a.bookings_cancelled_by_passenger) AS passenger_cancelled_bookings,
    ROUND(SUM(a.bookings_cancelled_by_driver) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS driver_cancellation_rate_pct,
    ROUND(SUM(a.bookings_cancelled_by_passenger) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS passenger_cancellation_rate_pct
FROM rideit_drivers d
JOIN rideit_activity a ON d.id_driver = a.id_driver
GROUP BY d.service_type, d.country_code, rating_segment
HAVING total_bookings > 1000
ORDER BY driver_cancellation_rate_pct DESC;
