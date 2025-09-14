--Code in MSSQL (T-SQL); 
--Creating a new view in db
CREATE VIEW AssetAnalysis_PowerBI AS
--Unpivoting the data for more efficient calculation
WITH IndexData_Unpivoted AS (
      SELECT
        observation_date,
        asset_id,
        index_value
    FROM
       AllstateCaseStudy.dbo.IndexData
    UNPIVOT
       (index_value FOR asset_id IN
          (FEDFUNDS, DFII30, DGS30, DGS10, DBAA, AAA, DGS5, DGS1, BAMLHYH0A0HYM2TRIV, BAMLCC4A0710YTRIV, NASDAQ100, SP500)
       ) AS unpvt
--CTE to Calculate prior month and prior quarter indexes
),
Prior_Indexes AS(
    SELECT 
    observation_date,
    asset_id,
    index_value,
    --finding prior month (-1 month) or prior quarter (-3 months) for the same index
    LAG(index_value,1) OVER (PARTITION BY asset_id ORDER BY observation_date ASC) AS prior_mth, 
    LAG(index_value,3) OVER (PARTITION BY asset_id ORDER BY observation_date ASC) AS prior_qtr
    FROM IndexData_Unpivoted),
--CTE to calculate monthly income and valuation changes
Return_calculations AS(
    SELECT
    p.observation_date,
    p.asset_id,
    p.index_value,
    (p.index_value / p.prior_mth) - 1 AS mth_return_percentage,
    (p.index_value / p.prior_qtr) - 1 AS qtr_return_percentage,
    --calculating monthly income for yield% based indexes assuming a $1M investment
    CASE
        WHEN p.asset_id NOT IN ('BAMLHYH0A0HYM2TRIV', 'BAMLCC4A0710YTRIV', 'NASDAQ100', 'SP500')
        THEN 100000000 * (p.index_value / 100)
        ELSE NULL
    END AS monthly_income,
    --calculating change in valuation for all indexes
    100000000 * ((p.index_value / p.prior_mth) - 1) AS monthly_change_valuation
    FROM Prior_Indexes p
)
--combining all the calculations from previous steps, calculating the quarterly values (rolling sum), changing columns names to Power BI ready namings
SELECT
    rc.observation_date AS [Observation Date],
    rc.asset_id AS [Asset ID],
    rc.index_value AS [Monthly Index Value],
    rc.mth_return_percentage AS [Monthly Return %],
    rc.qtr_return_percentage AS [Quarterly Return %],
    rc.monthly_income / 1000 AS [Monthly Income ($000s)],
    rc.monthly_change_valuation / 1000 AS [Monthly Valuation Change ($000s)],
    --Calculating the sum of 3month rolling values for Income and Valuation Change values
    SUM(rc.monthly_income / 1000) OVER (PARTITION BY rc.asset_id ORDER BY rc.observation_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [Quarterly Income ($000s)],
    SUM(rc.monthly_change_valuation / 1000) OVER (PARTITION BY rc.asset_id ORDER BY rc.observation_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [Quarterly Valuation Change ($000s)]
FROM Return_calculations rc

--Additional assumption #1:Assuming that no investment was made prior to the earliest month which is availbe in dataset (2018-12) therefore Monthly Return % is null for the first month and Quarterly % is null for the first three months
--Additional assumption #2: the raw index data table will only have data in the form of YYYY-MM-01, in other words the data will not contain duplicate month&year values.