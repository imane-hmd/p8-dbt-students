with source_insee as (

    select * from {{ source('insee_data', 'RAW_INSEE_POPULATION') }}

),

renamed_and_cleaned as (

    select
        -- Standardisation du nom de région / département
        trim(REGION) as region,
        
        -- Nettoyage de la tranche d'âge
        trim(AGE_GROUP) as age_group,
        
        -- Genre
        trim(GENDER) as gender,
        
        -- Typage numérique de la population
        cast(POPULATION as number) as population_count

    from source_insee

)

select * from renamed_and_cleaned