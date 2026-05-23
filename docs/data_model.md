# Data Model

## Dimensions

### dim_calendar

Source:
generated calendar

Grain:
1 row = 1 calendar day

Purpose:
- time analysis
- rolling metrics
- retention calculations
- dashboard filtering

Columns:
- calendar_date
- year
- month_start
- month_number
- month_name
- week_start
- week_number

---

### dim_users

Source:
users + company

Grain:
1 row = 1 user

Purpose:
- user profiling
- cohort analysis
- segmentation
- company attribution

Columns:
- user_id
- registration_date
- company_name
- tier
- score
- is_active
- referral_user_id
- cohort_month

---

## Fact Table

### fact_daily_user_activity

Source:
userentry + users + page

Grain:
1 row = 1 user activity day

Purpose:
core behavioral table used for engagement and retention analysis

Columns:
- activity_date
- user_id
- landing_page
- days_since_registration
- is_first_activity

---

## Analytical Marts

### agg_daily_platform_kpis

Source:
fact_daily_user_activity

Grain:
1 row = 1 day

Purpose:
platform engagement monitoring

Metrics:
- DAU
- WAU
- MAU
- returning_users
- new_users
- sticky_factor
- DAU 7d rolling average

---

### agg_user_retention

Source:
dim_users + fact_daily_user_activity

Grain:
1 row = cohort date + retention date

Purpose:
cohort retention analysis

Metrics:
- D1 retention
- D7 retention
- D30 retention
- retained users
- cohort size
- retention_rate

---

### agg_problem_activity

Source:
coderun + codesubmit + language

Grain:
1 row = date + language

Purpose:
coding activity monitoring

Metrics:
- total_runs
- total_submits
- successful_submits
- success_rate
- unique_users
- unique_solved_problems

---

### agg_user_learning_behavior

Source:
coderun + codesubmit

Grain:
1 row = 1 user

Purpose:
behavioral profiling and user segmentation

Metrics:
- total_runs
- total_submissions
- solved_problems
- attempts_until_acceptance
- favorite_language
- last_activity_date
- total_active_days
- user_segment
