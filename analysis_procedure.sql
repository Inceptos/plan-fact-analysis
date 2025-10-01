CREATE OR REPLACE PROCEDURE get_plan_fact_report(
    p_start_date DATE,
    p_end_date DATE,
    INOUT cumulative_result REFCURSOR DEFAULT 'cumulative_cur',
    INOUT regular_result REFCURSOR DEFAULT 'regular_cur'
)

LANGUAGE plpgsql
AS $$
BEGIN

--обычная группировка
OPEN cumulative_result FOR
SELECT TO_CHAR(work_date, 'YYYY-MM') AS period
    ,SUM(sum_plan) AS plan
    ,SUM(sum_fact) AS fact
FROM fact_plan
WHERE work_date BETWEEN p_start_date AND p_end_date
GROUP BY to_char(work_date, 'YYYY-MM');

--накопительный итог
OPEN regular_result FOR
SELECT TO_CHAR(work_date, 'YYYY-MM') AS period,
	SUM(SUM(sum_plan)) OVER (ORDER BY TO_CHAR(work_date, 'YYYY-MM')) AS cumulative_plan,
	SUM(SUM(sum_fact)) OVER (ORDER BY TO_CHAR(work_date, 'YYYY-MM')) AS cumulative_fact
FROM fact_plan
WHERE work_date BETWEEN p_start_date AND P_end_date
GROUP BY TO_CHAR(work_date, 'YYYY-MM');

END;
$$;