DROP TABLE IF EXISTS mart.agg_user_learning_behavior;

CREATE TABLE mart.agg_user_learning_behavior AS
WITH activity_union AS(
	SELECT 
		cr.user_id,
		cr.created_at,
		cr.problem_id,
		cr.language_id,
		NULL AS is_false,
		NULL AS rn_attempts,
		'run' AS flag
	FROM raw.coderun AS cr
	UNION ALL
	SELECT 
		cs.user_id,
		cs.created_at,
		cs.problem_id,
		cs.language_id,
		cs.is_false,
		ROW_NUMBER() OVER(PARTITION BY cs.user_id, cs.problem_id
						ORDER BY cs.created_at ) AS rn_attempts, 
		'submit' AS flag
	FROM raw.codesubmit AS cs
),
ranked AS(
	SELECT 
		DENSE_RANK() OVER(PARTITION BY au.user_id 
							ORDER BY DATE(au.created_at) DESC) AS rnk_days,
		*,
		l.name AS language_name
	FROM activity_union AS au
	JOIN raw.language AS l
		ON au.language_id = l.id
),
agg_user_problem AS(
	SELECT
		r.user_id,
		r.problem_id,
		MIN(r.rn_attempts) AS attempts_until_acceptance
	FROM ranked AS r
	WHERE r.is_false = 0
	GROUP BY r.user_id, r.problem_id
),
agg_user AS(
	SELECT 
		COUNT(aup.problem_id) AS cnt_solved_problems,
		SUM(aup.attempts_until_acceptance) AS total_attempts_until_acceptance,
		SUM(aup.attempts_until_acceptance)::numeric / COUNT(aup.problem_id) AS avg_attempts_per_problem,
		r.user_id,
		MAX(DATE(r.created_at)) AS last_activity_date,
		MAX(r.rnk_days) AS total_active_days,
		MODE() WITHIN GROUP(ORDER BY r.language_name) AS favorite_language, 
		COUNT(CASE WHEN r.flag = 'submit' THEN 1 END) AS total_submissions,
		COUNT(CASE WHEN r.flag = 'run' THEN 1 END) AS total_runs
	FROM ranked AS r
	LEFT JOIN agg_user_problem AS aup
	 	ON r.user_id = aup.user_id
	 		AND r.problem_id = aup.problem_id
	 		AND r.rn_attempts = aup.attempts_until_acceptance
	GROUP BY r.user_id
),
user_segmentation AS(
	SELECT 
		PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY total_active_days) AS p90
	FROM agg_user
)
SELECT 
	au.user_id,
	au.total_runs,
	au.total_submissions,
	au.cnt_solved_problems,
	au.total_attempts_until_acceptance,
	au.avg_attempts_per_problem,
	au.favorite_language,
	au.last_activity_date,
	au.total_active_days,	
	CASE 
		WHEN total_active_days > us.p90 THEN 'power'
		WHEN total_active_days > 1 THEN 'casual'
		ELSE 'new'
	END AS user_segment
FROM agg_user AS au
CROSS JOIN user_segmentation AS us 
ORDER BY user_id