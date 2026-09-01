-- QUERY 2: Monthly Total Rides & Fulfillment Metrics
USE rideit_analytics;

SELECT 
    DATE_FORMAT(active_date, '%Y-%m') AS activity_month,
    SUM(offers) AS total_offers,
    SUM(bookings) AS total_bookings,
    SUM(rides) AS total_completed_rides,
    SUM(bookings_cancelled_by_passenger + bookings_cancelled_by_driver) AS total_cancellations,
    ROUND(SUM(bookings) * 100.0 / NULLIF(SUM(offers), 0), 2) AS monthly_acceptance_rate_pct,
    ROUND(SUM(rides) * 100.0 / NULLIF(SUM(bookings), 0), 2) AS monthly_completion_rate_pct,
    ROUND(SUM(bookings_cancelled_by_passenger + bookings_cancelled_by_driver) * 100.0 / NULLIF(SUM(bookings), 0), 2) AS monthly_cancellation_rate_pct
FROM rideit_activity
GROUP BY DATE_FORMAT(active_date, '%Y-%m')
ORDER BY activity_month ASC;
