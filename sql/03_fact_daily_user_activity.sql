DROP TABLE IF EXISTS mart.fact_daily_user_activity;

CREATE TABLE mart.fact_daily_user_activity AS
WITH user_activity AS(
	SELECT 
		DATE(ue.entry_at) AS activity_date,
		u.id AS user_id,
		p.path AS landing_page,
		EXTRACT(DAYS FROM (ue.entry_at - u.date_joined)) AS days_since_registration,
		MIN(EXTRACT(DAYS FROM (ue.entry_at - u.date_joined))) OVER(PARTITION BY u.id) AS first_entrance
	FROM raw.userentry AS ue
	JOIN raw.users AS u 
		ON ue.user_id = u.id
	JOIN raw.page AS p 
		ON ue.page_id = p.id 
	WHERE EXTRACT(DAYS FROM (ue.entry_at - u.date_joined)) >= 0
)
SELECT 
	activity_date,
	user_id,
	landing_page,
	days_since_registration,
	CASE
		WHEN days_since_registration = first_entrance THEN 1
		ELSE 0
	END AS is_first_activity
FROM user_activity