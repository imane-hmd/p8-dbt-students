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