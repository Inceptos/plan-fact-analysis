-- добавить план-факт
call load_fact_plan_data (
	12, 12, '2025-11-26', 20000, 19000
);

-- изменить план-факт
call load_fact_plan_data (
	12, 12, '2025-11-26', 30000, 25000, 42
);

-- вызов процедуры для отчета
call get_plan_fact_report('2024-01-01', '2026-01-01',
 'YYYY', array[10,11], array[10,11]);
-- можно указать меньше параметров
--call get_plan_fact_report();

fetch all from cumulative_cur;

fetch all from regular_cur;