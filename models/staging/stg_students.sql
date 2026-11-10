/*
  =============================================================================
  MODÈLE STAGING : stg_students
  =============================================================================
  - Rôle : Import et sélection initiale des données brutes des apprenants.
  - Données sources : Table RAW_STUDENTS (identifiants, filières, profils).
  =============================================================================
*/


WITH source AS (
    SELECT * FROM {{ source('raw_data', 'RAW_STUDENTS') }}
)

SELECT
    USER_ID,
    PATH_CATEGORY_NAME,
    AGE_GROUP,
    GENDER,
    REGION,
    YEAR_PATH_STARTED
FROM source
