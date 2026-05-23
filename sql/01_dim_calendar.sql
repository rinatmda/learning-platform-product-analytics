DROP TABLE IF EXISTS mart.dim_calendar;

CREATE TABLE mart.dim_calendar AS
WITH dates AS (
	SELECT 
		MIN(date_joined) AS min_date,
		MAX(date_joined) AS max_date
	FROM
		raw.users
	UNION ALL
	SELECT 
		MIN(entry_at) AS min_date,
		MAX(entry_at) AS max_date
	FROM
		raw.userentry
	UNION ALL
	SELECT 
		MIN(created_at) AS min_date,
		MAX(created_at) AS max_date
	FROM
		raw.transaction
	UNION ALL
	SELECT 
		MIN(created_at) AS min_date,
		MAX(created_at) AS max_date
	FROM
		raw.codesubmit
	UNION ALL
	SELECT 
		MIN(created_at) AS min_date,
		MAX(created_at) AS max_date
	FROM
		raw.coderun
), 
boundaries AS (
	SELECT  
		MIN(min_date) AS first_date,
		MAX(max_date) AS last_date
	FROM dates
),
calendar AS (
	SELECT
		DATE(GENERATE_SERIES(first_date, last_date, '1 day')) AS calendar_date
	FROM boundaries
)
SELECT 
	calendar_date,
	TO_CHAR(calendar_date, 'YYYY') AS year,
	DATE(DATE_TRUNC('MONTH', calendar_date)) AS month_start,
	EXTRACT(MONTH FROM calendar_date) AS month_number,
	TO_CHAR(calendar_date, 'Month') AS month_name,
	DATE(DATE_TRUNC('WEEK', calendar_date)) AS week_start,
	EXTRACT(WEEK FROM calendar_date) AS week_number
FROM calendar