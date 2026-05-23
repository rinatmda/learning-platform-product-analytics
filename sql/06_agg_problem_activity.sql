DROP TABLE IF EXISTS mart.agg_problem_activity;

CREATE TABLE mart.agg_problem_activity AS
WITH runs AS(
	SELECT 
		DATE(cr.created_at) AS activity_date,
		cr.language_id AS language_id,
		COUNT(*) AS total_runs
	FROM raw.coderun AS cr
	GROUP BY DATE(cr.created_at), cr.language_id
),
submits AS(
	SELECT
		DATE(cs.created_at) AS activity_date, 
		cs.language_id AS language_id,
		COUNT(*) AS total_submits,
		COUNT(*) - SUM(cs.is_false) AS successful_submits, 
		(COUNT(*) - SUM(cs.is_false))::numeric / COUNT(*) AS success_rate
	FROM raw.codesubmit AS cs
	GROUP BY DATE(cs.created_at), cs.language_id 
),
coding_activity AS(
	WITH activity_union AS(
		SELECT 
			DATE(cr.created_at) AS activity_date,
			cr.language_id AS language_id,
			cr.user_id,
			NULL AS solved_problem_id
		FROM raw.coderun AS cr 
		UNION ALL
		SELECT 
			DATE(cs.created_at) AS activity_date,
			cs.language_id AS language_id,
			cs.user_id,
			(CASE WHEN cs.is_false = 0 THEN cs.problem_id END) AS solved_problem_id
		FROM raw.codesubmit AS cs
	)
	SELECT 
		activity_date,
		language_id,
		COUNT(DISTINCT user_id) AS unique_users,
		COUNT(DISTINCT solved_problem_id) AS unique_solved_problems
	FROM activity_union
	GROUP BY activity_date, language_id
)
SELECT 
	ca.activity_date,
	l.name AS language_name,
	COALESCE(r.total_runs, 0 ) AS total_runs,
	COALESCE(s.total_submits, 0 ) AS total_submits,
	COALESCE(s.successful_submits, 0) AS successful_submits,
	s.success_rate,
	ca.unique_users,
	ca.unique_solved_problems
FROM coding_activity AS ca
LEFT JOIN runs AS r
	ON ca.activity_date = r.activity_date 
		AND ca.language_id = r.language_id
LEFT JOIN submits AS s 
	ON ca.activity_date = s.activity_date 
		AND ca.language_id = s.language_id
JOIN raw.language AS l 
	ON ca.language_id = l.id