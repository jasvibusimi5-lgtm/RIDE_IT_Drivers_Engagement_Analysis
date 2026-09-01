-- QUERY 3: Service Type Comparison (TAXI vs PHV)
USE rideit_analytics;

SELECT 
    d.service_type,
    COUNT(DISTINCT d.id_driver) AS total_registered_drivers,
    COUNT(DISTINCT a.id_driver) AS active_drivers,
    SUM(a.offers) AS total_offers,
    SUM(a.bookings) AS total_bookings,
    SUM(a.rides) AS total_completed_rides,
    ROUND(AVG(d.driver_rating), 2) AS avg_driver_rating,
    ROUND(SUM(a.bookings) * 100.0 / NULLIF(SUM(a.offers), 0), 2) AS acceptance_rate_pct,
    ROUND(SUM(a.rides) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS completion_rate_pct,
    ROUND(SUM(a.bookings_cancelled_by_driver) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS driver_cancellation_rate_pct,
    ROUND(SUM(a.bookings_cancelled_by_passenger) * 100.0 / NULLIF(SUM(a.bookings), 0), 2) AS passenger_cancellation_rate_pct
FROM rideit_drivers d
LEFT JOIN rideit_activity a ON d.id_driver = a.id_driver
GROUP BY d.service_type
ORDER BY total_completed_rides DESC;
