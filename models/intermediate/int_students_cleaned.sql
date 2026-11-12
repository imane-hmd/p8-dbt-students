/*
  =============================================================================
  MODÈLE INTERMEDIATE : int_students_cleaned
  =============================================================================
  - Rôle : Nettoyage, standardisation et fiabilisation des profils apprenants.
  - Règles appliquées :
      * Déduplication technique pour retenir les 4 010 apprenants uniques.
      * Typage et harmonisation des données démographiques (âge, genre, localisation).
      * Préparation des données pour les jointures et l'exposition finale.
  =============================================================================
*/

WITH source AS (
    SELECT * FROM {{ ref('stg_students') }}
),

cleaned AS (
    SELECT
        user_id,
        MAX(path_category_name) AS path_category_name,
        COALESCE(MAX(age_group), 'Non renseigné') AS age_group,
        CASE 
            WHEN UPPER(TRIM(MAX(gender))) IN ('F', 'FEMALE', 'FEMME') THEN 'Femme'
            WHEN UPPER(TRIM(MAX(gender))) IN ('M', 'MALE', 'HOMME') THEN 'Homme'
            ELSE 'Non renseigné'
        END AS gender,
        COALESCE(TRIM(MAX(region)), 'Inconnue') AS region,
        MAX(year_path_started) AS year_path_started
    FROM source
    WHERE path_category_name = 'Data'
      AND user_id IS NOT NULL
    GROUP BY user_id
)

SELECT * FROM cleaned
