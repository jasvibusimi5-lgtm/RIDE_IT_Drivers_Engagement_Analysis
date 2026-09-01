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
