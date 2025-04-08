CREATE FUNCTION [dbo].[DateToInt]
(
	@Date date
)
RETURNS int
AS
BEGIN
  
	DECLARE @ResDate as int

	SELECT @ResDate = YEAR(@Date) * 10000 + MONTH(@Date) * 100 + DAY(@Date)

	RETURN @ResDate

END