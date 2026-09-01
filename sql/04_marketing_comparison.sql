-- QUERY 4: Marketing Preference (Opt-in vs Opt-out)
USE rideit_analytics;

SELECT 
    CASE WHEN d.receive_marketing = 1 THEN 'Marketing Opt-In (True)' ELSE 'Marketing Opt-Out (False)' END AS marketing_status,
    COUNT(DISTINCT d.id_driver) AS total_drivers,
    SUM(a.rides) AS total_completed_rides,
    ROUND(SUM(a.rides) * 1.0 / COUNT(DISTINCT d.id_driver), 2) AS avg_rides_per_driver,
    ROUND(SUM(a.bookings) * 100.0 / NULLIF(SUM(a.offers), 0), 2) AS acceptance_rate_pct,
    ROUND(SUM(a.rides) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS completion_rate_pct,
    ROUND(AVG(d.driver_rating), 2) AS avg_driver_rating
FROM rideit_drivers d
LEFT JOIN rideit_activity a ON d.id_driver = a.id_driver
GROUP BY d.receive_marketing;
