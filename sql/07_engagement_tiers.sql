-- QUERY 7: Driver Engagement Tiers
USE rideit_analytics;

SELECT 
    m.engagement_tier,
    COUNT(*) AS total_driver_days,
    COUNT(DISTINCT m.id_driver) AS unique_drivers,
    ROUND(AVG(m.engagement_score), 2) AS avg_engagement_score,
    ROUND(AVG(m.acceptance_rate), 2) AS avg_acceptance_rate_pct,
    ROUND(AVG(m.completion_rate), 2) AS avg_completion_rate_pct,
    ROUND(AVG(m.cancellation_rate), 2) AS avg_cancellation_rate_pct,
    SUM(m.rides) AS total_rides
FROM rideit_master m
GROUP BY m.engagement_tier
ORDER BY avg_engagement_score DESC;
