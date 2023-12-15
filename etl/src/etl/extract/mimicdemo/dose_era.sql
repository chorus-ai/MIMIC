INSERT INTO
    dose_era (
        dose_era_id,
        person_id,
        drug_concept_id,
        unit_concept_id,
        dose_value,
        dose_era_start_date,
        dose_era_end_date
    )
SELECT
    dose_era_id,
    person_id,
    drug_concept_id,
    unit_concept_id,
    dose_value,
    dose_era_start_date,
    dose_era_end_date
FROM
    dose_era_53;