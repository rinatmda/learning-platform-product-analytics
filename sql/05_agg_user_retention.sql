DROP TABLE IF EXISTS mart.agg_user_retention;
CREATE TABLE mart.agg_user_retention AS
WITH cohort AS(
	SELECT 
		DATE(du.registration_date) AS cohort_date,
		du.user_id AS cohort_user,
		COUNT(du.user_id) 
			OVER(PARTITION BY DATE(du.registration_date)) AS cohort_size
	FROM mart.dim_users AS du
	--ORDER BY DATE(du.registration_date), du.user_id 
),
retention AS(
	SELECT 
		c.cohort_date,
		--ARRAY_AGG(DISTINCT c.cohort_user ORDER BY c.cohort_user ASC) AS cohort_users_array, --for debugging/checking
		c.cohort_size,
		fdua.activity_date AS retention_date,
		CASE 
			WHEN c.cohort_date + INTERVAL '1 days' = fdua.activity_date THEN 'D1'
			WHEN c.cohort_date + INTERVAL '7 days' = fdua.activity_date THEN 'D7'
			WHEN c.cohort_date + INTERVAL '30 days' = fdua.activity_date THEN 'D30'
		END AS retention_day,
		--ARRAY_AGG(DISTINCT fdua.user_id ORDER BY fdua.user_id ASC) AS users_activity_array, --for debugging/checking
		COUNT(CASE WHEN c.cohort_user = fdua.user_id THEN 1 END) AS retained_users
	FROM cohort AS c
	LEFT JOIN mart.fact_daily_user_activity AS fdua 
		ON c.cohort_date + INTERVAL '1 days' = fdua.activity_date
		OR c.cohort_date + INTERVAL '7 days' = fdua.activity_date
		OR c.cohort_date + INTERVAL '30 days' = fdua.activity_date
	GROUP BY c.cohort_date, c.cohort_size, fdua.activity_date
	--ORDER BY cohort_date
)
SELECT
	DISTINCT(c.cohort_date),
	c.cohort_size,
	r.retention_date,
	r.retention_day,
	r.retained_users,
	(r.retained_users::numeric / c.cohort_size) AS retention_rate
FROM cohort AS c 
JOIN retention AS r
	ON c.cohort_date = r.cohort_date