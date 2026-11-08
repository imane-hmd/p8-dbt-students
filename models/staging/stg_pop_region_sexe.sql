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