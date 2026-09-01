# Power BI 3-Page Dashboard Blueprint & Implementation Guide

## 1. Data Model Architecture (Star Schema)
```
  +------------------+         +-------------------------+
  |  rideit_drivers  | 1     * |     rideit_activity     |
  |  (Dimension)     |--------<|      (Fact Table)       |
  +------------------+         +-------------------------+
                                            | *
                                            | 1
                               +-------------------------+
                               |        Calendar         |
                               |    (Date Dimension)     |
                               +-------------------------+
```
- **Fact Table**: `rideit_activity` (1.82M rows)
- **Dimension Tables**: `rideit_drivers` (36,972 rows), `Calendar` (2020 Dates)
- **Master Enriched Table**: `rideit_master` (for accelerated slicing)

---

## 2. 3-Page Dashboard Layout Specifications

### Page 1: Executive Overview (RIDE IT | Driver Engagement Overview)
- **Top 6 KPI Summary Cards**:
  1. `Total Registered Drivers`: 36,972
  2. `Avg Monthly Active Drivers`: 18,540 (50.1% Active Fleet Ratio)
  3. `Total Completed Rides`: 13.8M
  4. `Avg Engagement Score`: 62.3 / 100 (Overall Fleet Average)
  5. `Acceptance Rate %`: 51.0% (Bookings / Dispatched Offers)
  6. `Cancellation Rate %`: 16.4% (Total Cancellations / Bookings)
- **Methodology Card**:
  - `Score = (0.35 * Completion Rate) + (0.25 * Acceptance Rate) + (0.25 * Daily Volume Scale) + (0.15 * Reliability Index)`
  - Tiers: High Engagement (70–100: 37.8%), Medium Engagement (40–69: 51.8%), Low Engagement (<40: 10.4%).
- **Visuals**:
  - `Monthly Active Drivers & Completed Rides Trend (2020)` (Dual Y-Axis).
  - `Engagement Tiers Breakdown` (Donut Chart).
  - `Total Completed Rides by Service Type` (TAXI: 11.85M vs PHV: 1.95M).
  - `Average Engagement Score by Country` (Germany: 63.2 vs Spain: 61.4).

---

### Page 2: Driver Segments & Key Drivers (What Drives Better Engagement?)
- **Top Performing Segment Banner**:
  - TAXI drivers in Germany with an average rating of 4.85+ show the highest average engagement score of 64.8 with 87.2% completion.
- **Visuals**:
  - `Service Type Comparison: Score & Rates` (Clustered Bar).
  - `Marketing Preference & Engagement` (Drivers who opted in showed higher average engagement: 63.2 vs 59.8).
  - `Engagement by Driver Rating Tier` (High 4.85+: 64.1, Medium: 60.5, Low: 52.8).
  - `Engagement by Gold Level Count` (0: 57.2, 1-10: 62.4, 11-30: 69.1, 31+: 76.4).

---

### Page 3: Driver Journey & Cancellation Insights (Driver Lifecycle & Cancellation Friction)
- **Visuals**:
  - `Driver Lifecycle Journey (Tenure Stages)` (New 0-30d: 66.5, Early 31-90d: 58.9, Established 91-365d: 61.8, Veteran 365+d: 63.4).
  - `Cancellation Source Breakdown` (Passenger: 61.2% vs Driver: 38.8%).
  - `Key Insights & Opportunities` (Early onboarding retention focus, cancellation reduction, Gold status progression).
