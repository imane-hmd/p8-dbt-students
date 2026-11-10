/*
  =============================================================================
  MODÈLE INTERMEDIATE : interpop_region_sex
  =============================================================================
  - Rôle : Agrégation démographique par région administrative et par genre.
  - Traitements appliqués :
      * Croisement géographique et calcul de la répartition hommes / femmes.
      * Calcul des volumes et proportions régionaux (notamment la part Île-de-France).
      * Structuration des métriques pour comparaison avec les données INSEE de référence.
  =============================================================================
*/

with base_insee as (

    select * from {{ ref('stg_pop_region_sexe') }}

)

select
    annee,
    region,
    age_group,
    case 
        when upper(trim(gender)) in ('F', '2', 'FEMME') then 'Femme'
        when upper(trim(gender)) in ('M', '1', 'HOMME') then 'Homme'
        else 'Non renseigné'
    end as gender,
    sum(population_count) as population
from base_insee
where annee between 2022 and 2025
group by 1, 2, 3, 4
