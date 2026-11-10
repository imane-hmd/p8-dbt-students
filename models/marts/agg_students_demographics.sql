/*
  =============================================================================
  DATA MART : agg_students_demographic
  =============================================================================
  - Rôle : Table finale d'exposition des indicateurs démographiques des apprenants.
  - Usages analytiques :
      * Synthèse globale des 4 010 profils apprenants uniques.
      * Distribution par tranches d'âge (pic 30-34 ans) et par genre (31,4 % femmes).
      * Analyse de la concentration géographique (poids prédominant de l'Île-de-France).
      * Alimentation directe des tableaux de bord et visualisations de la soutenance.
  =============================================================================
*/

WITH base AS (
    SELECT * FROM {{ ref('int_students_cleaned') }}
),

aggregated AS (
    SELECT
        year_path_started,
        path_category_name,
        age_group,
        gender,
        region,
        COUNT(DISTINCT user_id) AS student_count
    FROM base
    GROUP BY
        year_path_started,
        path_category_name,
        age_group,
        gender,
        region
)

SELECT
    *,
    ROUND(
        100.0 * student_count / SUM(student_count) OVER (PARTITION BY year_path_started),
        2
    ) AS pct_of_year_cohort
FROM aggregated
