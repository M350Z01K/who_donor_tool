# import packages
library(DBI)
library(RSQLite)
library(dplyr)

# linking activity to transaction data ----

con <- dbConnect(RSQLite::SQLite(), dbname = "data/iati.sqlite/home/iatitables/working_data/iati.sqlite")


# query the amount transferred for each year since 2018 ----
query = "WITH filtered_sectors AS (
    -- Step 1: Filter to health rows and get unique Donor-to-Sector combinations
    SELECT DISTINCT
        a.reportingorg_ref AS donor_id,
        a.reportingorg_narrative AS donor_name,
        s.narrative AS sector_name
    FROM 
        activity a
    JOIN 
        sector s ON a._link_activity = s._link_activity
    WHERE 
        a.reportingorg_ref IS NOT NULL
        AND (
            s.code LIKE '121%' 
            OR s.code LIKE '122%' 
            OR s.code LIKE '123%' 
            OR s.code LIKE '130%' 
            OR s.code IN ('120', '130') 
        )
        AND (s.vocabulary IS NULL OR s.vocabulary = '1')
),
project_counts AS (
    -- Step 2: Calculate total unique health projects per donor
    SELECT 
        a.reportingorg_ref AS donor_id,
        COUNT(DISTINCT a.iatiidentifier) AS total_health_projects
    FROM 
        activity a
    JOIN 
        sector s ON a._link_activity = s._link_activity
    WHERE 
        (
            s.code LIKE '121%' 
            OR s.code LIKE '122%' 
            OR s.code LIKE '123%' 
            OR s.code LIKE '130%' 
            OR s.code IN ('120', '130') 
        )
        AND (s.vocabulary IS NULL OR s.vocabulary = '1')
    GROUP BY 
        a.reportingorg_ref
),
yearly_financials AS (
    -- Step 3: Calculate total health funding per donor pivoted by year
    SELECT 
        a.reportingorg_ref AS donor_id,
        -- Pivot transaction values into columns based on transaction_date
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2018%' THEN t.value_usd ELSE 0 END) AS health_funding_2018,
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2019%' THEN t.value_usd ELSE 0 END) AS health_funding_2019,
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2020%' THEN t.value_usd ELSE 0 END) AS health_funding_2020,
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2021%' THEN t.value_usd ELSE 0 END) AS health_funding_2021,
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2022%' THEN t.value_usd ELSE 0 END) AS health_funding_2022,
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2023%' THEN t.value_usd ELSE 0 END) AS health_funding_2023,
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2024%' THEN t.value_usd ELSE 0 END) AS health_funding_2024,
        SUM(CASE WHEN t.transactiondate_isodate LIKE '2025%' THEN t.value_usd ELSE 0 END) AS health_funding_2025
    FROM 
        activity a
    JOIN 
        sector s ON a._link_activity = s._link_activity
    JOIN 
        trans t ON a._link_activity = t._link_activity
    WHERE 
        -- Focus only on health activities
        (
            s.code LIKE '121%' 
            OR s.code LIKE '122%' 
            OR s.code LIKE '123%' 
            OR s.code LIKE '130%' 
            OR s.code IN ('120', '130') 
        )
        AND (s.vocabulary IS NULL OR s.vocabulary = '1')
        -- Target actual spending (Disbursements = 3, Expenditures = 4)
        AND t.transactiontype_code IN ('3', '4') 
    GROUP BY 
        a.reportingorg_ref
)
-- Step 4: Final combination
SELECT 
    f.donor_id,
    f.donor_name,
    p.total_health_projects,
    COALESCE(ROUND(y.health_funding_2018, 2), 0) AS health_funding_2018,
    COALESCE(ROUND(y.health_funding_2019, 2), 0) AS health_funding_2019,
    COALESCE(ROUND(y.health_funding_2020, 2), 0) AS health_funding_2020,
    COALESCE(ROUND(y.health_funding_2021, 2), 0) AS health_funding_2021,
    COALESCE(ROUND(y.health_funding_2022, 2), 0) AS health_funding_2022,
    COALESCE(ROUND(y.health_funding_2023, 2), 0) AS health_funding_2023,
    COALESCE(ROUND(y.health_funding_2024, 2), 0) AS health_funding_2024,
    COALESCE(ROUND(y.health_funding_2025, 2), 0) AS health_funding_2025,
    group_concat(f.sector_name, ' | ') AS specific_health_sectors
FROM 
    filtered_sectors f
JOIN 
    project_counts p ON f.donor_id = p.donor_id
LEFT JOIN 
    yearly_financials y ON f.donor_id = y.donor_id
GROUP BY 
    f.donor_id, 
    f.donor_name,
    p.total_health_projects,
    y.health_funding_2018,
    y.health_funding_2019,
    y.health_funding_2020,
    y.health_funding_2021,
    y.health_funding_2022,
    y.health_funding_2023,
    y.health_funding_2024,
    y.health_funding_2025
ORDER BY 
    total_health_projects DESC;"
donations = dbGetQuery(con, query)

saveRDS(donations, "data/donors_and_yearly_disbursements.rds")