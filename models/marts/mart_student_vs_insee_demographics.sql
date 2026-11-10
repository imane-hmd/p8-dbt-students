/*
  =============================================================================
  DATA MART : students_vs_insee_demographic
  =============================================================================
  - Rôle : Table finale de comparaison benchmark entre la population apprenante et les données INSEE.
  - Usages analytiques :
      * Confrontation directe de la répartition sociodémographique (apprenants vs population nationale/régionale).
      * Mesure des écarts de représentativité sur les critères de genre, de tranches d'âge et de localisation.
      * Mise en évidence de la surreprésentation francilienne par rapport à la moyenne nationale INSEE.
      * Support chiffré des recommandations stratégiques présentées en soutenance.
  =============================================================================
*/

with analyse as (

    select
        i.annee,
        i.region,
        i.age_group,
        i.gender,
        i.population,
        coalesce(o.nb_etudiants, 0) as nb_etudiants,

        sum(coalesce(o.nb_etudiants, 0)) over (
            partition by o.region, o.age_group, o.annee
        ) as total_students,

        sum(coalesce(i.population, 0)) over (
            partition by i.region, i.age_group, i.annee
        ) as total_population,

        round((coalesce(i.population / nullif(total_population, 0) * 100.0, 0)), 2) as pct_hf_fr,
        round((coalesce(nb_etudiants / nullif(total_students, 0) * 100.0, 0)), 2) as pct_hf_oc

    from {{ ref('inter_pop_region_sexe') }} as i
    left join {{ ref('inter_etudiant') }} as o
        on i.annee = o.annee
        and lower(trim(i.region)) = lower(trim(o.region))
        and lower(trim(i.age_group)) = lower(trim(o.age_group))
        and lower(trim(i.gender)) = lower(trim(o.gender))

)

select
    *,
    round(pct_hf_oc - pct_hf_fr, 2) as pt_diff
from analyse
order by annee desc, region, age_group, gender
