DROP TABLE IF EXISTS mart.dim_users;
CREATE TABLE mart.dim_users AS
SELECT
	u.id AS user_id,
	u.date_joined AS registration_date,
	c.name AS company_name,
	u.tier AS tier,
	u.score AS score,
	u.is_active AS is_active,
	u.referal_user AS referral_user_id,
	DATE_TRUNC('MONTH', u.date_joined) AS cohort_month
FROM raw.users AS u
LEFT JOIN raw.company AS c
	ON u.company_id = c.id