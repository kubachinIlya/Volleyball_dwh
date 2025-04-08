

CREATE VIEW [pbi].[v_D001_dim_Date]
AS
SELECT
	 [DateID] AS [DateID]
	,[DateTime] AS [DateTime]
	,[DateName] AS [DateName]
	,[DayTypeID] AS [DayTypeID]
	,[DayTypeName] AS [DayTypeName]
	,[WeekdayNumber] AS [WeekdayNumber]
	,[WeekdayName] AS [WeekdayName]
	,[WeekID] AS [WeekID]
	,[WeekName] AS [WeekName]
	,[WeekFullName] AS [WeekFullName]
	,[WeekNumber] AS [WeekNumber]
	,[MonthID] AS [MonthID]
	,[MonthName] AS [MonthName]
	,[MonthFullName] AS [MonthFullName]
	,[MonthNumber] AS [MonthNumber]
	,[QuarterID] AS [QuarterID]
	,[QuarterName] AS [QuarterName]
	,[QuarterFullName] AS [QuarterFullName]
	,[YearID] AS [YearID]
	,[YearName] AS [YearName]
FROM [dbo].[dim_Date]
WHERE 
	[YearID] <= YEAR(GETDATE()) + 2
	AND [YearID] >= 2020