/*
  =============================================================================
  MODÈLE STAGING : stg_pop_region_sexe
  =============================================================================
  - Rôle : Nettoyage et typage initial des données démographiques régionales INSEE.
  - Traitements appliqués :
      * Typage des années en entier et population en numérique.
      * Nettoyage des chaînes de caractères (régions, genre, tranches d'âge).
  =============================================================================
*/

with source_insee as (

    select * from {{ source('raw_insee', 'pop_region_sexe') }}

),

renamed_and_cleaned as (

    select
        cast(ANNEE as int) as annee,

        -- Standardisation du nom de région
        trim(REGION) as region,
        
        -- Genre / Sexe
        trim(SEXE) as gender,

        -- Nettoyage de la tranche d'âge
        trim(TRANCHE_AGE) as age_group,
        
        -- Typage numérique de la population
        cast(POPULATION as number(12, 2)) as population_count

    from source_insee

)

select * from renamed_and_cleaned
