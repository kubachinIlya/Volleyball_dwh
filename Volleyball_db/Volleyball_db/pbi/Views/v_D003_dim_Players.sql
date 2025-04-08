CREATE VIEW [pbi].[v_D003_dim_Players]
AS
SELECT [PlayerID]
      ,[PlayerName]
      ,[PlayerNumber]
      ,[PlayerHeight]
      ,[PlayerBirthdayDateID]
      ,[PlayerCitizenship]
  FROM [Volleyball_dwh].[dbo].[dim_Players]