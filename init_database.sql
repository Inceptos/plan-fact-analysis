CREATE TABLE ref_object (
    id SERIAL PRIMARY KEY,
    name VARCHAR(300) NOT NULL,
    description TEXT
);

CREATE TABLE ref_type_work (
    id SERIAL PRIMARY KEY,
    name VARCHAR(300)
);

CREATE TABLE fact_plan (
    id BIGSERIAL PRIMARY KEY,
    id_object INTEGER NOT NULL REFERENCES ref_object(id),
    id_type_work INTEGER NOT NULL REFERENCES ref_type_work(id),
    work_date DATE NOT NULL,
    sum_plan DECIMAL(15,2) NOT NULL DEFAULT 0,
    sum_fact DECIMAL(15,2) NOT NULL DEFAULT 0,

    CONSTRAINT check_sum_plan_positive CHECK (sum_plan >= 0),
    CONSTRAINT check_sum_fact_positive CHECK (sum_fact >= 0)
);

CREATE INDEX index_fact_plan_object ON fact_plan(id_object);
CREATE INDEX index_fact_plan_type_work ON fact_plan(id_type_work);
CREATE INDEX index_fact_plan_date ON fact_plan(work_date);
CREATE INDEX index_fact_plan_object_date ON fact_plan(id_object, work_date);

COMMENT ON TABLE ref_object IS 'Справочник строительных объектов';
COMMENT ON COLUMN ref_object.id IS 'Уникальный идентификатор объекта';
COMMENT ON COLUMN ref_object.name IS 'Наименование объекта';
COMMENT ON COLUMN ref_object.desctiption IS 'Подробное описание объекта';

COMMENT ON TABLE ref_type_work IS 'Справочник видов работ';
COMMENT ON COLUMN ref_type_work.id IS 'Уникальный идентификатор вида работ';
COMMENT ON COLUMN ref_type_work.name IS 'Название вида работы';

COMMENT ON TABLE fact_plan IS 'Плановые и фактические показатели выполнения работ';
COMMENT ON COLUMN fact_plan.id IS 'Уникальный идентификатор записи';
COMMENT ON COLUMN fact_plan.id_object IS 'Ссылка на обьект строительства (внешний ключ)';
COMMENT ON COLUMN fact_plan.id_type_work IS 'Ссылка на вид работ (внешний ключ)'
COMMENT ON COLUMN fact_plan.work_date IS 'Срок выполнения работ';
COMMENT ON COLUMN fact_plan.sum_plan IS 'Плановая стоимость выполнения работ';
COMMENT ON COLUMN fact_plan.sum_fact IS 'Фактическая стоимость выполнения работ'


