DROP TABLE IF EXISTS mart.agg_daily_platform_kpis;

CREATE TABLE mart.agg_daily_platform_kpis AS
WITH dau AS(
	SELECT
		dc.calendar_date AS activity_date,
		COUNT(DISTINCT fdua.user_id) AS dau, 
		SUM(CASE 
				WHEN DATE(du.registration_date) = fdua.activity_date THEN 1 
				ELSE 0 
			END) AS new_users
	FROM mart.dim_calendar AS dc 
	LEFT JOIN mart.fact_daily_user_activity AS fdua
		ON dc.calendar_date = fdua.activity_date
	LEFT JOIN mart.dim_users AS du 
		ON fdua.user_id = du.user_id
	GROUP BY dc.calendar_date
),
daily_kpi_enriched AS (
	SELECT 
		d.*,
		(d.dau - d.new_users) AS returning_users,
		AVG(d.dau) OVER(
					ORDER BY d.activity_date 
					ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS dau_7d_avg,
		(SELECT COUNT(DISTINCT user_id)
			FROM mart.fact_daily_user_activity AS fdua 
			WHERE activity_date BETWEEN d.activity_date - 6 AND d.activity_date) AS wau,
		(SELECT COUNT(DISTINCT user_id)
			FROM mart.fact_daily_user_activity AS fdua 
			WHERE activity_date BETWEEN d.activity_date - 29 AND d.activity_date) AS mau
	FROM dau AS d
)
SELECT
	activity_date,
	dau,
	new_users,
	returning_users,
	dau_7d_avg,
	wau,
	mau,
	CASE 
		WHEN mau != 0 THEN (dau * 1.0 / mau * 100) 
	END AS sticky_factor,
	CASE 
		WHEN dau != 0 THEN (new_users::numeric / dau)
	END AS pct_new_users
FROM daily_kpi_enriched