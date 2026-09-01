import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

base_dir = r'c:/Users/jasvi/Desktop/RIDE_IT_Drivers_Engagement_Analysis'
output_dir = os.path.join(base_dir, 'output')

print('Loading merged dataset...')
merged = pd.read_csv(os.path.join(output_dir, 'rideit_merged_cleaned.csv'))
merged['active_date'] = pd.to_datetime(merged['active_date'])
merged['year_month'] = merged['active_date'].dt.to_period('M').astype(str)

print('Aggregating Monthly KPIs...')
monthly_summary = merged.groupby('year_month').agg(
    active_drivers=('id_driver', 'nunique'),
    total_offers=('offers_adjusted', 'sum'),
    total_bookings=('bookings', 'sum'),
    total_rides=('rides_adjusted', 'sum'),
    passenger_cancellations=('bookings_cancelled_by_passenger', 'sum'),
    driver_cancellations=('bookings_cancelled_by_driver', 'sum'),
    total_cancellations=('total_cancellations', 'sum'),
    avg_engagement_score=('engagement_score', 'mean'),
    avg_acceptance_rate=('acceptance_rate', 'mean'),
    avg_completion_rate=('completion_rate', 'mean'),
    avg_cancellation_rate=('cancellation_rate', 'mean')
).reset_index()

monthly_summary.to_csv(os.path.join(output_dir, 'monthly_kpi_summary.csv'), index=False)
print('Saved monthly_kpi_summary.csv')

service_summary = merged.groupby('service_type').agg(
    total_drivers=('id_driver', 'nunique'),
    total_rides=('rides_adjusted', 'sum'),
    avg_engagement_score=('engagement_score', 'mean'),
    avg_acceptance_rate=('acceptance_rate', 'mean'),
    avg_completion_rate=('completion_rate', 'mean'),
    avg_cancellation_rate=('cancellation_rate', 'mean')
).reset_index()
service_summary.to_csv(os.path.join(output_dir, 'service_type_kpi_summary.csv'), index=False)

print('Generating high-res charts...')
sns.set_theme(style='whitegrid', palette='muted')

# Chart 1
fig, ax1 = plt.subplots(figsize=(10, 5))
ax2 = ax1.twinx()
sns.lineplot(data=monthly_summary, x='year_month', y='active_drivers', ax=ax1, color='#1f77b4', marker='o', linewidth=2.5, label='Active Drivers')
sns.lineplot(data=monthly_summary, x='year_month', y='total_rides', ax=ax2, color='#2ca02c', marker='s', linewidth=2.5, label='Total Rides')
ax1.set_title('RIDE IT - Monthly Active Drivers vs Total Completed Rides (2020)', fontsize=13, fontweight='bold', pad=12)
ax1.set_xlabel('Month', fontsize=11)
ax1.set_ylabel('Monthly Active Drivers', fontsize=11, color='#1f77b4')
ax2.set_ylabel('Total Completed Rides', fontsize=11, color='#2ca02c')
ax1.tick_params(axis='x', rotation=45)
fig.tight_layout()
fig.savefig(os.path.join(output_dir, '01_monthly_drivers_rides_trend.png'), dpi=300)
plt.close(fig)

# Chart 2
fig, ax = plt.subplots(figsize=(10, 5))
sns.lineplot(data=monthly_summary, x='year_month', y='avg_engagement_score', color='#9467bd', marker='o', linewidth=2.5, label='Avg Engagement Score')
sns.lineplot(data=monthly_summary, x='year_month', y='avg_completion_rate', color='#2ca02c', marker='^', linewidth=2, linestyle='--', label='Completion Rate %')
sns.lineplot(data=monthly_summary, x='year_month', y='avg_acceptance_rate', color='#ff7f0e', marker='v', linewidth=2, linestyle='--', label='Acceptance Rate %')
sns.lineplot(data=monthly_summary, x='year_month', y='avg_cancellation_rate', color='#d62728', marker='x', linewidth=2, linestyle=':', label='Cancellation Rate %')
ax.set_title('Monthly Engagement Score and Operational Rates Progression', fontsize=13, fontweight='bold', pad=12)
ax.set_xlabel('Month', fontsize=11)
ax.set_ylabel('Percentage / Score Points', fontsize=11)
ax.set_ylim(0, 100)
ax.tick_params(axis='x', rotation=45)
ax.legend(loc='lower right', frameon=True)
fig.tight_layout()
fig.savefig(os.path.join(output_dir, '02_monthly_engagement_rates_trend.png'), dpi=300)
plt.close(fig)

# Chart 3
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
sns.barplot(data=service_summary, x='service_type', y='avg_engagement_score', palette=['#1f77b4', '#ff7f0e'], ax=ax1)
ax1.set_title('Avg Engagement Score by Service Type', fontsize=11, fontweight='bold')
ax1.set_ylim(0, 100)
for p in ax1.patches:
    ax1.annotate(f'{p.get_height():.1f}', (p.get_x() + p.get_width() / 2., p.get_height() - 8),
                 ha='center', va='center', color='white', fontweight='bold')

sns.barplot(data=service_summary, x='service_type', y='total_rides', palette=['#1f77b4', '#ff7f0e'], ax=ax2)
ax2.set_title('Total Completed Rides by Service Type', fontsize=11, fontweight='bold')
for p in ax2.patches:
    ax2.annotate(f'{int(p.get_height()):,}', (p.get_x() + p.get_width() / 2., p.get_height() / 2),
                 ha='center', va='center', color='white', fontweight='bold')
fig.tight_layout()
fig.savefig(os.path.join(output_dir, '03_service_type_comparison.png'), dpi=300)
plt.close(fig)

# Chart 4
tenure_order = ['New (0-1 Month)', 'Early-Stage (1-3 Months)', 'Established (3-12 Months)', 'Veteran (1+ Years)']
tenure_summary = merged.groupby('tenure_group').agg(
    avg_engagement_score=('engagement_score', 'mean'),
    avg_completion_rate=('completion_rate', 'mean'),
    avg_cancellation_rate=('cancellation_rate', 'mean'),
    avg_rides_per_day=('rides_adjusted', 'mean')
).reindex(tenure_order).reset_index()

fig, ax = plt.subplots(figsize=(9, 4.5))
sns.barplot(data=tenure_summary, x='tenure_group', y='avg_engagement_score', palette='Blues_d', ax=ax)
ax.set_title('Driver Engagement Score Across Lifecycle Journey', fontsize=12, fontweight='bold', pad=10)
ax.set_ylim(0, 100)
for p in ax.patches:
    ax.annotate(f'{p.get_height():.1f}', (p.get_x() + p.get_width() / 2., p.get_height() - 8),
                 ha='center', va='center', color='white', fontweight='bold')
fig.tight_layout()
fig.savefig(os.path.join(output_dir, '04_driver_tenure_journey.png'), dpi=300)
plt.close(fig)

# Chart 5
gold_order = ['0 (No Gold)', '1-10 (Bronze/Silver Gold)', '11-30 (Solid Gold)', '31+ (Elite Gold)']
gold_summary = merged.groupby('gold_group').agg(
    avg_engagement=('engagement_score', 'mean'),
    avg_rides=('rides_adjusted', 'mean')
).reindex(gold_order).reset_index()

fig, ax = plt.subplots(figsize=(9, 4.5))
sns.barplot(data=gold_summary, x='gold_group', y='avg_engagement', palette='YlOrBr', ax=ax)
ax.set_title('Engagement Score by Gold Partner Tier', fontsize=12, fontweight='bold', pad=10)
ax.set_ylim(0, 100)
for p in ax.patches:
    ax.annotate(f'{p.get_height():.1f}', (p.get_x() + p.get_width() / 2., p.get_height() - 8),
                 ha='center', va='center', color='black', fontweight='bold')
fig.tight_layout()
fig.savefig(os.path.join(output_dir, '05_gold_level_impact.png'), dpi=300)
plt.close(fig)

# Chart 6
fig, ax = plt.subplots(figsize=(8, 4.5))
tot_p = merged['bookings_cancelled_by_passenger'].sum()
tot_d = merged['bookings_cancelled_by_driver'].sum()
tot_all = tot_p + tot_d
cancel_df = pd.DataFrame({'Source': ['Passenger Cancellations', 'Driver Cancellations'], 'Total': [tot_p, tot_d]})
sns.barplot(data=cancel_df, x='Source', y='Total', palette=['#3498db', '#e74c3c'], ax=ax)
ax.set_title('Total Cancellations: Passenger vs Driver Friction', fontsize=12, fontweight='bold', pad=10)
for p in ax.patches:
    pct = (p.get_height() / tot_all) * 100
    ax.annotate(f'{int(p.get_height()):,} ({pct:.1f}%)', 
                (p.get_x() + p.get_width() / 2., p.get_height() / 2),
                ha='center', va='center', color='white', fontweight='bold')
fig.tight_layout()
fig.savefig(os.path.join(output_dir, '06_cancellation_sources.png'), dpi=300)
plt.close(fig)

print('All 6 analytical charts generated successfully!')
