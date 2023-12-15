INSERT INTO
    drug_era (
        drug_era_id,
        person_id,
        drug_concept_id,
        drug_era_start_date,
        drug_era_end_date,
        drug_exposure_count,
        gap_days
    )
SELECT
    drug_era_id,
    person_id,
    drug_concept_id,
    drug_era_start_date,
    drug_era_end_date,
    drug_exposure_count,
    gap_days
FROM
    drug_era_53;