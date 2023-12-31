CREATE
OR REPLACE TABLE lk_death_adm_mapped AS
SELECT DISTINCT src.subject_id,
    nth_value(src.deathtime, 1)   over(
        partition BY src.subject_id
        ORDER BY src.admittime ASC
    )                                   AS deathtime,
    nth_value(src.dischtime, 1) over(
        partition BY src.subject_id
        ORDER BY src.admittime ASC
    )                                   AS dischtime,
    32817 AS type_concept_id, -- OMOP4976890 EHR
                --
                'admissions'      AS         unit_id,
                src.load_table_id AS         load_table_id,
    nth_value(src.load_row_id, 1) over(
        partition BY src.subject_id
        ORDER BY src.admittime ASC
    )                                   AS load_row_id,
    nth_value(src.trace_id, 1) over(
        partition BY src.subject_id
        ORDER BY src.admittime ASC
    )                                   AS trace_id
FROM src_admissions src -- adm
WHERE src.deathtime IS NOT NULL
;

-- -------------------------------------------------------------------
-- cdm_death
-- -------------------------------------------------------------------

--HINT DISTRIBUTE_ON_KEY(person_id)
CREATE
OR REPLACE TABLE cdm_death
(
    person_id               INTEGER     NOT NULL ,
    death_date              DATE      NOT NULL ,
    death_datetime          TIMESTAMP           ,
    death_type_concept_id   INTEGER     NOT NULL ,
    cause_concept_id        INTEGER              ,
    cause_source_value      STRING             ,
    cause_source_concept_id INTEGER              ,
    -- 
    unit_id                       STRING,
    load_table_id                 STRING,
    load_row_id                   INTEGER,
    trace_id                      STRING
)
;

INSERT INTO cdm_death
SELECT per.person_id                 AS person_id,
       CAST(if(
                   src.deathtime <= src.dischtime,
                   src.deathtime, src.dischtime
           ) AS DATE)                AS death_date,
       if(
                   src.deathtime <= src.dischtime,
                   src.deathtime, src.dischtime
           )                         AS death_datetime,
       src.type_concept_id           AS death_type_concept_id,
       NULL                          AS cause_concept_id,
       CAST(NULL AS STRING)          AS cause_source_value,
       NULL                          AS cause_source_concept_id,
       --
       concat('death.', src.unit_id) AS unit_id,
       src.load_table_id             AS load_table_id,
       src.load_row_id               AS load_row_id,
       src.trace_id                  AS trace_id
FROM lk_death_adm_mapped src
         INNER JOIN
     cdm_person per
     ON CAST(src.subject_id AS STRING) = per.person_source_value
;