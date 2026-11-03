with students as (

    -- Agréger la population étudiante par région et genre
    select
        region,
        gender,
        sum(student_count) as total_students
    from {{ ref('agg_students_demographics') }}
    where region is not null
    group by
        region,
        gender

),

students_with_pct as (

    select
        region,
        gender,
        total_students,
        round(
            100.0 * total_students / nullif(sum(total_students) over (), 0),
            2
        ) as pct_students
    from students

),

insee as (

    -- Agréger la population nationale INSEE sur les mêmes dimensions
    select
        region,
        gender,
        sum(population_count) as total_population
    from {{ ref('stg_pop_region_sex') }}
    group by
        region,
        gender

),

insee_with_pct as (

    select
        region,
        gender,
        total_population,
        round(
            100.0 * total_population / nullif(sum(total_population) over (), 0),
            2
        ) as pct_insee_population
    from insee

),

joined as (

    select
        coalesce(s.region, i.region) as region,
        coalesce(s.gender, i.gender) as gender,
        coalesce(s.total_students, 0) as total_students,
        coalesce(s.pct_students, 0.0) as pct_students,
        coalesce(i.total_population, 0) as total_population,
        coalesce(i.pct_insee_population, 0.0) as pct_insee_population,
        
        -- Indicateur clé : Écart de représentativité (sur-représentation ou sous-représentation)
        round(coalesce(s.pct_students, 0.0) - coalesce(i.pct_insee_population, 0.0), 2) as diff_pct_points

    from students_with_pct s
    full outer join insee_with_pct i
        on lower(trim(s.region)) = lower(trim(i.region))
        and lower(trim(s.gender)) = lower(trim(i.gender))

)

select * from joined
order by diff_pct_points desc