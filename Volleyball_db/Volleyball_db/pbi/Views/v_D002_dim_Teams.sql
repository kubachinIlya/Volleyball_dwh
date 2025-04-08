

CREATE VIEW [pbi].[v_D002_dim_Teams]
AS
SELECT [TeamID]
      ,[TeamName]
      ,[CityID]
      ,[SecondCityID]
      ,[TeamOfficialName]
      ,[TeamFullName]
      ,[Address]
      ,[Phone]
      ,[Email]
      ,[Website]
  FROM [Volleyball_dwh].[dbo].[dim_Teams]