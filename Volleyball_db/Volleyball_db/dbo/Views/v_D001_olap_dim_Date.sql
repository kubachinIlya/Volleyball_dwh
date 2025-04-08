CREATE VIEW [dbo].[v_D001_olap_dim_Date]
AS
SELECT
	 [DateID] AS [D001_DateID]
	,[DateTime] AS [D001_DateTime]
	,[DateName] AS [D001_DateName]
	,[DayTypeID] AS [D001_DayTypeID]
	,[DayTypeName] AS [D001_DayTypeName]
	,[WeekdayNumber] AS [D001_WeekdayNumber]
	,[WeekdayName] AS [D001_WeekdayName]
	,[WeekID] AS [D001_WeekID]
	,[WeekName] AS [D001_WeekName]
	,[WeekFullName] AS [D001_WeekFullName]
	,[WeekNumber] AS [D001_WeekNumber]
	,[MonthID] AS [D001_MonthID]
	,[MonthName] AS [D001_MonthName]
	,[MonthFullName] AS [D001_MonthFullName]
	,[MonthNumber] AS [D001_MonthNumber]
	,[QuarterID] AS [D001_QuarterID]
	,[QuarterName] AS [D001_QuarterName]
	,[QuarterFullName] AS [D001_QuarterFullName]
	,[YearID] AS [D001_YearID]
	,[YearName] AS [D001_YearName]
FROM [dbo].[dim_Date]
WHERE 
	[YearID] <= YEAR(GETDATE()) + 2
	AND [YearID] >= 2020