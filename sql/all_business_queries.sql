-- ====================================================================
-- RIDE IT DRIVERS ENGAGEMENT ANALYSIS - MASTER SQL REPOSITORY
-- ====================================================================

-- >>>>> 00_schema_and_import.sql <<<<<
-- ====================================================================
-- RIDE IT DRIVERS ENGAGEMENT ANALYSIS - SCHEMA DEFINITION & DATA IMPORT
-- Database: MySQL 8.0+ / MySQL Workbench
-- ====================================================================
CREATE DATABASE IF NOT EXISTS rideit_analytics;
USE rideit_analytics;

DROP TABLE IF EXISTS rideit_activity;
DROP TABLE IF EXISTS rideit_drivers;
DROP TABLE IF EXISTS rideit_master;

CREATE TABLE rideit_drivers (
    id_driver INT PRIMARY KEY,
    date_registration DATE NOT NULL,
    driver_rating DECIMAL(3,2),
    gold_level_count INT DEFAULT 0,
    receive_marketing BOOLEAN DEFAULT FALSE,
    country_code VARCHAR(10) NOT NULL,
    service_type VARCHAR(20) NOT NULL
);

CREATE TABLE rideit_activity (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    id_driver INT NOT NULL,
    active_date DATE NOT NULL,
    offers INT DEFAULT 0,
    bookings INT DEFAULT 0,
    bookings_cancelled_by_passenger INT DEFAULT 0,
    bookings_cancelled_by_driver INT DEFAULT 0,
    rides INT DEFAULT 0,
    FOREIGN KEY (id_driver) REFERENCES rideit_drivers(id_driver),
    INDEX idx_driver_date (id_driver, active_date),
    INDEX idx_active_date (active_date)
);

CREATE TABLE rideit_master (
    id_driver INT NOT NULL,
    active_date DATE NOT NULL,
    offers INT,
    bookings INT,
    bookings_cancelled_by_passenger INT,
    bookings_cancelled_by_driver INT,
    rides INT,
    total_cancellations INT,
    acceptance_rate DECIMAL(5,2),
    completion_rate DECIMAL(5,2),
    cancellation_rate DECIMAL(5,2),
    date_registration DATE,
    driver_rating DECIMAL(3,2),
    gold_level_count INT,
    receive_marketing BOOLEAN,
    country_code VARCHAR(10),
    service_type VARCHAR(20),
    driver_tenure_days INT,
    tenure_group VARCHAR(30),
    rating_group VARCHAR(30),
    gold_group VARCHAR(30),
    engagement_score DECIMAL(5,2),
    engagement_tier VARCHAR(30),
    PRIMARY KEY (id_driver, active_date)
);


-- >>>>> 01_monthly_active_drivers.sql <<<<<
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


-- >>>>> 02_monthly_total_rides.sql <<<<<
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


-- >>>>> 03_service_type_comparison.sql <<<<<
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


-- >>>>> 04_marketing_comparison.sql <<<<<
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


-- >>>>> 05_country_engagement.sql <<<<<
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


-- >>>>> 06_gold_performance.sql <<<<<
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


-- >>>>> 07_engagement_tiers.sql <<<<<
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


-- >>>>> 08_cancellation_segments.sql <<<<<
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


