with students as (

    select
        annee,
        region,
        gender,
        sum(student_count) as total_students
    from {{ ref('agg_students_demographics') }}
    where region is not null
      and annee between 2022 and 2025
    group by
        annee,
        region,
        gender

),

students_with_pct as (

    select
        annee,
        region,
        gender,
        total_students,
        round(
            100.0 * total_students / nullif(sum(total_students) over (partition by annee), 0),
            2
        ) as pct_students
    from students

),

insee as (

    -- Population INSEE sur la période 2022-2025
    select
        annee,
        region,
        gender,
        sum(population_count) as total_population
    from {{ ref('stg_pop_region_sexe') }}
    where annee between 2022 and 2025
    group by
        annee,
        region,
        gender

),

insee_with_pct as (

    select
        annee,
        region,
        gender,
        total_population,
        round(
            100.0 * total_population / nullif(sum(total_population) over (partition by annee), 0),
            2
        ) as pct_insee_population
    from insee

),

joined as (

    select
        coalesce(s.annee, i.annee) as annee,
        coalesce(s.region, i.region) as region,
        coalesce(s.gender, i.gender) as gender,
        coalesce(s.total_students, 0) as total_students,
        coalesce(s.pct_students, 0.0) as pct_students,
        coalesce(i.total_population, 0) as total_population,
        coalesce(i.pct_insee_population, 0.0) as pct_insee_population,
        
        -- Écart en points de pourcentage
        round(coalesce(s.pct_students, 0.0) - coalesce(i.pct_insee_population, 0.0), 2) as diff_pct_points

    from students_with_pct s
    full outer join insee_with_pct i
        on s.annee = i.annee
        and lower(trim(s.region)) = lower(trim(i.region))
        and lower(trim(s.gender)) = lower(trim(i.gender))

)

select * from joined
order by annee desc, diff_pct_points desc