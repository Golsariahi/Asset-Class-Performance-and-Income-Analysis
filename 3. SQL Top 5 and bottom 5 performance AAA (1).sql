--Code in MSSQL (T-SQL);
--Selecting top 5 and bottom 5 performing months for the 'AAA' index
--performance is defined as monthly return % for this exercise
SELECT * FROM (
    SELECT TOP (5)
        'Top 5 Monthly Return %' AS [Performance Rank],
        [Asset ID],
        [Observation Date],
        [Monthly Return %]
    FROM [AllstateCaseStudy].[dbo].[AssetAnalysis_PowerBI]
    WHERE [Asset ID] = 'AAA'
      AND [Monthly Return %] IS NOT NULL
    ORDER BY [Monthly Return %] DESC
) AS TopReturns
--Appending the bottom 5 performance to top 5 performance
UNION ALL

SELECT * FROM (
    SELECT TOP (5)
        'Bottom 5 Monthly Return %' AS [Performance Rank],
        [Asset ID],
        [Observation Date],
        [Monthly Return %]
    FROM [AllstateCaseStudy].[dbo].[AssetAnalysis_PowerBI]
    WHERE [Asset ID] = 'AAA'
      AND [Monthly Return %] IS NOT NULL
    ORDER BY [Monthly Return %] ASC
) AS BottomReturns;