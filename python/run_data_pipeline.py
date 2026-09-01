import os
import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import json

# Set paths
base_dir = r"c:\Users\jasvi\Desktop\RIDE_IT_Drivers_Engagement_Analysis"
data_dir = os.path.join(base_dir, "data")
output_dir = os.path.join(base_dir, "output")
python_dir = os.path.join(base_dir, "python")
sql_dir = os.path.join(base_dir, "sql")
powerbi_dir = os.path.join(base_dir, "powerbi")
presentation_dir = os.path.join(base_dir, "presentation")

print("--- PHASE 3: Loading Data ---")
drivers_path = os.path.join(data_dir, "Rideit_drivers.csv")
activity_path = os.path.join(data_dir, "Rideit_drivers_activity.csv")

drivers = pd.read_csv(drivers_path)
print(f"Drivers shape: {drivers.shape}")
print(drivers.head())
print("\nDrivers Info:")
drivers.info()

activity = pd.read_csv(activity_path)
print(f"\nActivity shape: {activity.shape}")
print(activity.head())
print("\nActivity Info:")
activity.info()

print("\n--- PHASE 4: Data Quality Checks & Cleaning ---")
print("Missing values in Drivers:")
print(drivers.isnull().sum())
print("\nMissing values in Activity:")
print(activity.isnull().sum())

print(f"\nDuplicate rows in Drivers: {drivers.duplicated().sum()}")
print(f"Duplicate rows in Activity: {activity.duplicated().sum()}")

# Convert dates
drivers['date_registration'] = pd.to_datetime(drivers['date_registration'])
activity['active_date'] = pd.to_datetime(activity['active_date'])

# Handle missing driver_rating if any (fill with median/mean or flag)
if drivers['driver_rating'].isnull().sum() > 0:
    drivers['driver_rating'] = drivers['driver_rating'].fillna(drivers['driver_rating'].median())

# Handle marketing flag
drivers['receive_marketing'] = drivers['receive_marketing'].fillna(False).astype(bool)

# Quality Checks on Activity
# 1. Negative values
cols_to_check = ['offers', 'bookings', 'bookings_cancelled_by_passenger', 'bookings_cancelled_by_driver', 'rides']
for col in cols_to_check:
    neg_count = (activity[col] < 0).sum()
    print(f"Negative values in {col}: {neg_count}")

# 2. Logic check: Bookings > Offers
# In ride-hailing datasets, sometimes street hails or batch dispatches cause bookings > offers if offers count is missed.
# Let's inspect:
anomalous_bookings = (activity['bookings'] > activity['offers']).sum()
print(f"Activity rows where bookings > offers: {anomalous_bookings} ({anomalous_bookings/len(activity)*100:.2f}%)")

# We cap offers to max(offers, bookings) for logical consistency:
activity['offers_adjusted'] = np.maximum(activity['offers'], activity['bookings'])

# 3. Logic check: Rides > Bookings
anomalous_rides = (activity['rides'] > activity['bookings']).sum()
print(f"Activity rows where rides > bookings: {anomalous_rides} ({anomalous_rides/len(activity)*100:.2f}%)")
# Cap rides to bookings if any anomaly
activity['rides_adjusted'] = np.minimum(activity['rides'], activity['bookings'])

# 4. Total cancellations
activity['total_cancellations'] = activity['bookings_cancelled_by_passenger'] + activity['bookings_cancelled_by_driver']

# Export cleaned datasets
drivers.to_csv(os.path.join(output_dir, "drivers_cleaned.csv"), index=False)
activity.to_csv(os.path.join(output_dir, "activity_cleaned.csv"), index=False)
print("Saved drivers_cleaned.csv and activity_cleaned.csv to output/")

print("\n--- PHASE 5: Feature Engineering ---")
# Acceptance Rate: Bookings / Offers * 100
activity['acceptance_rate'] = np.where(activity['offers_adjusted'] > 0, 
                                       (activity['bookings'] / activity['offers_adjusted']) * 100.0, 0.0)
activity['acceptance_rate'] = np.clip(activity['acceptance_rate'], 0.0, 100.0)

# Completion Rate: Rides / Bookings * 100
activity['completion_rate'] = np.where(activity['bookings'] > 0, 
                                       (activity['rides_adjusted'] / activity['bookings']) * 100.0, 0.0)
activity['completion_rate'] = np.clip(activity['completion_rate'], 0.0, 100.0)

# Cancellation Rate: Total Cancellations / Bookings * 100
activity['cancellation_rate'] = np.where(activity['bookings'] > 0, 
                                         (activity['total_cancellations'] / activity['bookings']) * 100.0, 0.0)
activity['cancellation_rate'] = np.clip(activity['cancellation_rate'], 0.0, 100.0)

print("\nActivity metrics summary:")
print(activity[['acceptance_rate', 'completion_rate', 'cancellation_rate']].describe())

print("\n--- PHASE 6: Merging Datasets ---")
merged = pd.merge(activity, drivers, on='id_driver', how='inner')
print(f"Merged dataset shape: {merged.shape}")

# Driver Tenure (in days from registration to active_date)
merged['driver_tenure_days'] = (merged['active_date'] - merged['date_registration']).dt.days
merged['driver_tenure_days'] = np.maximum(merged['driver_tenure_days'], 0)

# Driver Tenure Cohorts
def categorize_tenure(days):
    if days <= 30:
        return 'New (0-1 Month)'
    elif days <= 90:
        return 'Early-Stage (1-3 Months)'
    elif days <= 365:
        return 'Established (3-12 Months)'
    else:
        return 'Veteran (1+ Years)'

merged['tenure_group'] = merged['driver_tenure_days'].apply(categorize_tenure)

# Rating group
def categorize_rating(r):
    if r >= 4.85:
        return 'High (4.85-5.0)'
    elif r >= 4.70:
        return 'Medium (4.70-4.84)'
    else:
        return 'Low (<4.70)'

merged['rating_group'] = merged['driver_rating'].apply(categorize_rating)

# Gold Tier group
def categorize_gold(g):
    if g == 0:
        return '0 (No Gold)'
    elif g <= 10:
        return '1-10 (Bronze/Silver Gold)'
    elif g <= 30:
        return '11-30 (Solid Gold)'
    else:
        return '31+ (Elite Gold)'

merged['gold_group'] = merged['gold_level_count'].apply(categorize_gold)

# Engagement Score (0-100)
# A balanced formula reflecting:
# 1. Completion Rate (35%)
# 2. Acceptance Rate (25%)
# 3. Ride Volume scaled (25%): 10+ rides/day = 100 points, linearly scaled
# 4. Low Cancellation Reliability (15%): (100 - Cancellation Rate) * 0.15
ride_volume_score = np.clip(merged['rides_adjusted'] / 10.0, 0.0, 1.0) * 100.0
reliability_score = np.clip(100.0 - merged['cancellation_rate'], 0.0, 100.0)

merged['engagement_score'] = (
    0.35 * merged['completion_rate'] +
    0.25 * merged['acceptance_rate'] +
    0.25 * ride_volume_score +
    0.15 * reliability_score
)
merged['engagement_score'] = np.clip(merged['engagement_score'].round(2), 0.0, 100.0)

# Engagement Tiers
def categorize_engagement(score):
    if score >= 70:
        return 'High Engagement'
    elif score >= 40:
        return 'Medium Engagement'
    else:
        return 'Low Engagement'

merged['engagement_tier'] = merged['engagement_score'].apply(categorize_engagement)

# Save merged cleaned dataset
merged.to_csv(os.path.join(output_dir, "rideit_merged_cleaned.csv"), index=False)
print("Saved rideit_merged_cleaned.csv to output/")

print("\nEngagement Score Summary:")
print(merged['engagement_score'].describe())
print("\nEngagement Tier Breakdown:")
print(merged['engagement_tier'].value_counts(normalize=True) * 100)

print("\n--- Pipeline Execution Completed Successfully ---")
