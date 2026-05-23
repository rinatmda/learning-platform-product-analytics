# Metrics Definition

This document describes business metrics and analytical calculations used across the project.

---

# Engagement Metrics

## Daily Active Users (DAU)

Definition:
Number of unique users active on a given day.

Business meaning:
Measures short-term platform engagement and daily activity level.

---

## Weekly Active Users (WAU)

Definition:
Number of unique users active during the last 7 days.

Business meaning:
Measures medium-term user engagement.

---

## Monthly Active Users (MAU)

Definition:
Number of unique users active during the last 30 days.

Business meaning:
Measures long-term active audience size.

---

## New Users 

Definition:
Users whose registration date equals activity date.

Business meaning:
Measures daily user acquisition.

---

## Returning Users

Definition:
Active users excluding newly registered users.

Business meaning:
Measures returning audience and user loyalty.

---

## DAU 7-Day Rolling Average

Definition:
Moving average of DAU during previous 7 days.

Business meaning:
Reduces daily volatility and reveals trends.

---

## Sticky Factor

Definition:
Share of monthly users active on a given day.

Formula:
DAU / MAU * 100

Business meaning:
Measures user engagement intensity.

---

# Retention Metrics

## Cohort Size

Definition:
Number of users registered on the same date.

Business meaning:
Defines cohort population used in retention analysis.
---

## D1 Retention

Definition:
Share of users active 1 day after registration.

Business meaning:
Measures initial user activation.

---

## D7 Retention

Definition:
Share of users active 7 days after registration.

Business meaning:
Measures early retention.

---


## D30 Retention

Definition:
Share of users active 30 days after registration.

Business meaning:
Measures long-term retention.

---

## Retention Rate

Definition:
Share of retained users within a cohort.

Formula:
retained_users / cohort_size

Business meaning:
Measures ability to retain users over time.

---

# Learning Activity Metrics

## Total Runs

Definition:
Number of code execution events.

Business meaning:
Measures coding activity and experimentation.

---

## Total Submissions

Definition:
Number of submitted solutions.

Business meaning:
Measures completed attempts. 

---

## Successful Submissions

Definition:
Number of accepted submissions.

Business meaning:
Measures successful problem completion.

---

## Success Rate

Definition:
Share of successful submissions.

Business meaning:
Measures learning effectiveness.

---

## Unique Active Users

Definition:
Distinct users participating in coding activity.

Business meaning:
Measures learning activity volume.

---

## Unique Solved Problems

Definition:
Distinct problems successfully completed by a user.

Business meaning:
Measures learning coverage.

---

# User Behavior Metrics

## Total Active Days

Definition:
Number of distinct active days per user.

Business meaning:
Measures engagement duration.

---

## Favorite Language

Definition:
Most frequently used programming language by the user.

Calculation logic:
MODE() WITHIN GROUP()

Tie handling: 
PostgreSQL MODE() behavior is applied.

Business meaning:
Represents user preference.

---

## Attempts Until Acceptance

Definition:
Number of submission attempts before first accepted solution.

Business meaning:
Measures persistence and learning effort.

---

## Average Attempts per Problem

Definition:
Average number of attempts required to solve a problem (considering attempts up to first successful submission only).

Formula:
SUM(attempts_until_acceptance)/cnt_solved_problems

Business meaning:
Measures task-solving efficiency.

---

## User Segment

Definition:
Behavioral user classification. Users active only once are classified as new; highly engaged users are defined using the 90th percentile threshold

Logic:

New:
```text
1 active day
```

Casual:
```text
2 active days up to P90 threshold
```

Power:
```text
Above P90 active days
```

Business meaning:
Separates users by engagement level.

