CREATE OR REPLACE PROCEDURE load_fact_plan_data(
    p_object_id INTEGER,              
    p_work_type_id INTEGER,             
    p_work_date DATE,                 
    p_sum_plan DECIMAL(15,2),         
    p_sum_fact DECIMAL(15,2),
    p_id INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM ref_object WHERE id = p_object_id) THEN
        RAISE EXCEPTION 'Объект с ID % не существует', p_object_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM ref_type_work WHERE id = p_work_type_id) THEN
        RAISE EXCEPTION 'Вид работ с ID % не существует', p_work_type_id;
    END IF;
    
    IF p_id IS NOT NULL THEN
        UPDATE fact_plan
        SET id_object = p_object_id, 
            id_type_work = p_work_type_id, 
            work_date = p_work_date, 
            sum_plan = p_sum_plan, 
            sum_fact = p_sum_fact
        WHERE id = p_id;

    ELSE
    INSERT INTO fact_plan (
        id_object, 
        id_type_work, 
        work_date, 
        sum_plan, 
        sum_fact
    ) VALUES (
        p_object_id,
        p_work_type_id, 
        p_work_date,
        p_sum_plan,
        p_sum_fact
    );
    
    RAISE NOTICE 'Данные загружены: object_id=%, work_type_id=%, date=%', 
        p_object_id, p_work_type_id, p_work_date;
    END IF;    
    
EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'Ошибка валидации: суммы не могут быть отрицательными';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ошибка загрузки: %', SQLERRM;
END;
$$;

COMMENT ON PROCEDURE load_fact_plan_data IS 'Процедура загрузки данных по идентификаторам объектов и видов работ. Включает валидацию существования записей.';