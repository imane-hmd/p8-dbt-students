"""
Script de préparation des données démographiques INSEE avant chargement dans Snowflake.

Règles de filtrage et de transformation :

- Période temporelle :
  * Extraction des années 2022 à 2025 (onglets annuels).

- Périmètre géographique :
  * Conservation des 18 régions administratives : les 13 régions de France métropolitaine 
    et les 5 DROM (Guadeloupe, Martinique, Guyane, La Réunion, Mayotte).
  * Exclusion des totaux agrégés (France métropolitaine, DOM, France métropolitaine et DOM) 
    et des lignes de métadonnées (Source).

- Tranches d'âge :
  * Exclusion des mineurs (< 20 ans).
  * Maintien des tranches quinquennales actives de 20 à 59 ans (20 à 24 ans à 55 à 59 ans).
  * Regroupement des tranches de 60 ans et plus sous la catégorie unique '60 ans ou plus' 
    avec agrégation des volumes de population.

- Normalisation :
  * Encodage du sexe en M / F.
  * Format de sortie : table tabulaire à 5 colonnes (ANNEE, REGION, SEXE, TRANCHE_AGE, POPULATION).
  * Fichier cible généré : pop_region_sexe.csv (1 296 lignes).
"""


import pandas as pd

# Chemin source direct
excel_path = "/Users/imanehamidouche/Desktop/Projet_8_Analysez_ l'évolution_ du_profil_ sociodémographique_des_ étudiants_Data_ d'OpenClassrooms_hamidouche_imane/Données/donnees_externe/estim-pop-nreg-sexe-aq-1975-2026.xlsx"

annees = ["2022", "2023", "2024", "2025"]

tranches = [
    "20 à 24 ans",
    "25 à 29 ans",
    "30 à 34 ans",
    "35 à 39 ans",
    "40 à 44 ans",
    "45 à 49 ans",
    "50 à 54 ans",
    "55 à 59 ans",
    "60 à 64 ans",
    "65 à 69 ans",
    "70 à 74 ans",
    "75 à 79 ans",
    "80 à 84 ans",
    "85 à 89 ans",
    "90 à 94 ans",
    "95 ans et plus",
]

# Exclusion stricte des agrégats pour conserver les 18 régions (13 métropole + 5 DROM)
totaux_a_exclure = [
    "France métropolitaine",
    "DOM",
    "France métropolitaine et DOM",
]

dfs = []

for annee in annees:
    df = pd.read_excel(excel_path, sheet_name=annee, header=[3, 4])
    col_region = df.columns[0]

    rows = []
    for _, row in df.iterrows():
        region = (
            str(row[col_region]).strip() if pd.notna(row[col_region]) else ""
        )

        if (
            not region
            or region in totaux_a_exclure
            or region.startswith("Source")
        ):
            continue

        for sexe in ["Hommes", "Femmes"]:
            for tranche in tranches:
                val = row[(sexe, tranche)]

                # Regroupement des tranches 60 ans et plus
                if any(
                    x in tranche
                    for x in [
                        "60",
                        "65",
                        "70",
                        "75",
                        "80",
                        "85",
                        "90",
                        "95",
                        "et plus",
                    ]
                ):
                    tranche_label = "60 ans ou plus"
                else:
                    tranche_label = tranche

                rows.append(
                    {
                        "ANNEE": int(annee),
                        "REGION": region,
                        "SEXE": "M" if sexe == "Hommes" else "F",
                        "TRANCHE_AGE": tranche_label,
                        "POPULATION": val if pd.notna(val) else 0,
                    }
                )

    dfs.append(pd.DataFrame(rows))

result = pd.concat(dfs, ignore_index=True)

# Somme de la population pour fusionner les lignes '60 ans ou plus'
result_grouped = result.groupby(
    ["ANNEE", "REGION", "SEXE", "TRANCHE_AGE"], as_index=False
)["POPULATION"].sum()

# Export dans le dossier prévu
result_grouped.to_csv("pop_region_sexe.csv", index=False, encoding="utf-8")

print(f"Fichier pop_region_sexe.csv généré avec succès !")
print(f"Nombre total de lignes : {len(result_grouped)}")
result_grouped.head(10)