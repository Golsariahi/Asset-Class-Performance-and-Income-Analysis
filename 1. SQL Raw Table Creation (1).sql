--Code in MSSQL (T-SQL);
---------------------------------------------------
--Database & table Setup
--create the index data table containing monthly values for each index

CREATE TABLE IndexData (
    observation_date DATE PRIMARY KEY,
    FEDFUNDS DECIMAL(18, 4),
    DFII30 DECIMAL(18, 4),
    DGS30 DECIMAL(18, 4),
    DGS10 DECIMAL(18, 4),
    DBAA DECIMAL(18, 4),
    AAA DECIMAL(18, 4),
    DGS5 DECIMAL(18, 4),
    DGS1 DECIMAL(18, 4),
    BAMLHYH0A0HYM2TRIV DECIMAL(18, 4),
    BAMLCC4A0710YTRIV DECIMAL(18, 4),
    NASDAQ100 DECIMAL(18, 4),
    SP500 DECIMAL(18, 4)
);

--Insert the sample data from local location into the db (This data was extracted from the "Sample Monthly Data" tab from the assessment excel file)
BULK INSERT IndexData
FROM 'C:\Users\r\OneDrive\Desktop\\CaseStudy\Sample Monthly Data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2
);

--Create the index description table containing long description for each index ID (This data was extracted from the "FRED Index" tab from the assessment excel file)
CREATE TABLE IndexDescription (
    AssetID VARCHAR(25) PRIMARY KEY,
    DESCRIPTION VARCHAR(256),
    LastUpdated VARCHAR(124)
);


--Insert the index description data from local location into the db
BULK INSERT IndexDescription
FROM 'C:\Users\r\OneDrive\Desktop\CaseStudy\FRED Index.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 1
);
