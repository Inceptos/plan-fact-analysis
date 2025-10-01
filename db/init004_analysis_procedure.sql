CREATE OR REPLACE PROCEDURE get_plan_fact_report(
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '3 years',
    p_end_date DATE DEFAULT CURRENT_DATE + INTERVAL '1 years',
    p_date_type VARCHAR(100) DEFAULT 'YYYY-MM', 
    p_objects INTEGER[] DEFAULT NULL,
    p_work_types INTEGER[] DEFAULT NULL,
    INOUT cumulative_result REFCURSOR DEFAULT 'cumulative_cur',
    INOUT regular_result REFCURSOR DEFAULT 'regular_cur'
)

LANGUAGE plpgsql
AS $$
BEGIN

--обычная группировка
OPEN cumulative_result FOR
SELECT TO_CHAR(work_date, p_date_type) AS period
    ,SUM(sum_plan) AS plan
    ,SUM(sum_fact) AS fact
FROM fact_plan
WHERE work_date BETWEEN p_start_date AND p_end_date
    AND (p_objects IS NULL OR id_object = ANY(p_objects))
    AND (p_work_types IS NULL OR id_type_work = ANY(p_work_types))
GROUP BY to_char(work_date, p_date_type);

--накопительный итог
OPEN regular_result FOR
SELECT TO_CHAR(work_date, p_date_type) AS period,
	SUM(SUM(sum_plan)) OVER (ORDER BY TO_CHAR(work_date, p_date_type)) AS cumulative_plan,
	SUM(SUM(sum_fact)) OVER (ORDER BY TO_CHAR(work_date, p_date_type)) AS cumulative_fact
FROM fact_plan
WHERE work_date BETWEEN p_start_date AND P_end_date
    AND (p_objects IS NULL OR id_object = ANY(p_objects))
    AND (p_work_types IS NULL OR id_type_work = ANY(p_work_types))
GROUP BY TO_CHAR(work_date, p_date_type);

END;
$$;