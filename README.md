# 📊 Analyse Sociodémographique des Apprenants Data
### Rapprochement OpenClassrooms vs Référentiel National INSEE (2022–2025)

---

## 🛠️ Stack Technique

---

- **Snowflake :** Entrepôt de données Cloud & moteur d'exécution SQL
- **dbt (Data Build Tool) :** Modélisation modulaire, lineage DAG et tests automatiques
- **Python (Pandas, Matplotlib) :** Ingestion amont, analyse exploratoire et restitution graphique
- **Git & GitHub :** Versionnage du projet et documentation

---

## 🏗️ Architecture du Pipeline ELT

---

```text
Sources Brutes (Snowflake)
   │
   ├── stg_students ────────► int_students_cleaned ──┬──► agg_students_demographics
   │                                                 └──► inter_etudiant ────┐
   │                                                                         ├──► mart_student_vs_insee_demographics
   └── stg_pop_region_sexe ─► inter_pop_region_sexe ─────────────────────────┘
```

---

## ⚙️ Modélisation dbt

---

Le projet s'organise en 3 couches de modélisation dans dbt :

### 1. Couche Staging (`models/staging/`)

- **`stg_students` :** Ingestion brute de la table interne (`raw_students`). Écartement des identifiants nuls et filtrage strict sur `path_category_name = 'Data'`.
- **`stg_pop_region_sexe` :** Ingestion du référentiel INSEE. Typage strict de la population (`CAST` en numérique) et normalisation textuelle (`TRIM`).

---

### 2. Couche Intermédiaire (`models/intermediate/`)

- **`int_students_cleaned`** (Nettoyage interne) :
  - **Dédoublonnage :** Résolution d'un foyer critique de 1 205 lignes pour seulement 568 apprenants uniques. Consolidation par `user_id` et sélection de l'état le plus récent via `MAX()`.
  - **Mixité & Genre :** Traitement de 27,1 % de valeurs non renseignées via `ELSE 'Non renseigné'` (conservation de 100 % de la volumétrie sans biais).
  - **Standardisation :** Normalisation des saisies hétérogènes (`M`, `F`, `MALE`) vers la nomenclature unique `Femme` / `Homme`.

- **`inter_pop_region_sexe`** (Filtrage externe) :
  - **Ciblage :** Population active (tranches de 20 à 60 ans et plus).
  - **Période :** Alignement sur l'étude 2022–2025 pour les régions métropolitaines et DROM.

- **`inter_etudiant`** (Préparation relationnelle) :
  - **Harmonisation :** Mise en forme des dimensions démographiques pour la jointure avec l'INSEE.

---

### 3. Couche Marts & Reporting (`models/marts/`)

- **`agg_students_demographics` :** Modèle d'agrégation interne regroupant les effectifs par année, région, genre et tranche d'âge.
- **`mart_student_vs_insee_demographics` :** Modèle analytique final servant au calcul des écarts de représentativité face au référentiel national.

---

## 🧪 Qualité & Fiabilisation des Données (`dbt test`)

---

- **Couche Staging :**
  - **Clé primaire :** `unique` & `not_null` sur `user_id` (`stg_students`).
  - **Champs requis :** `not_null` sur les colonnes géographiques et de population (`stg_pop_region_sexe`).

- **Couche Intermédiaire :**
  - **Valeurs acceptées :** `accepted_values` sur le champ genre : `['Femme', 'Homme', 'Non renseigné']`.
  - **Tranche d'âge :** `not_null` sur `age_group`.

- **Couche Marts :**
  - **Non-régression :** Tests `not_null` sur l'ensemble des volumes et ratios calculés.

---

## 🔒 Conformité RGPD

---

- **Pseudonymisation native :** Aucun contact direct (nom, prénom, e-mail) dans la base ; seul un `user_id` technique est manipulé en amont.
- **Minimisation :** Conservation stricte des 3 seules variables nécessaires à l'analyse (âge, genre, région).
- **Anonymisation irréversible :** Effacement des identifiants individuels dès l'étape des marts agrégés (`COUNT`), garantissant l'anonymat complet.

---

## 📈 Résultats Métier & Diagnostic Démographique

---

- **Territoire & Polarisation :**
  **54,1 %** des apprenants sont situés en Île-de-France (pour un poids INSEE de 17,9 %). Seules **8 régions métropolitaines** comptent des inscrits dans l'échantillon, laissant de vastes zones blanches sans inscrits.

- **Mixité de Genre :**
  Les femmes représentent **31,4 %** des profils renseignés (contre 51,6 % selon l'INSEE). Cet écart de -20,2 points est caractéristique des disparités du secteur Tech.

- **Maturité Professionnelle :**
  **64,1 %** de la cohorte a entre 25 et 39 ans (pic à 25,6 % pour les 30–34 ans). À l'inverse, les primo-étudiants (20–24 ans) ne pèsent que 4,3 %, confirmant une cible d'actifs en reconversion.
