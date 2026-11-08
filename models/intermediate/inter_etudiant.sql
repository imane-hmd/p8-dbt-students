with base_students as (

    select * from {{ ref('int_students_cleaned') }}

),

aggregated as (

    select
        year_path_started as annee,
        region,
        age_group,
        gender,
        count(distinct user_id) as nb_etudiants
    from base_students
    where region is not null
      and year_path_started between 2022 and 2025
    group by 1, 2, 3, 4

)

select * from aggregated