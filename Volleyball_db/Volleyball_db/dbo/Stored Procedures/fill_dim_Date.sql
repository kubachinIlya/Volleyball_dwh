--=====================================================================	
CREATE PROCEDURE [dbo].[fill_dim_Date]
	@Date_s DATE,
	@Date_f DATE 
AS
BEGIN

	--------------------------------------------------------------------------------------------------
	--  Начало логирования:
	--------------------------------------------------------------------------------------------------	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение таблицы дат dim_date'
			,@InputParameters NVARCHAR(512) = ''

	BEGIN TRY
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		 
		SET DATEFIRST 1

		DELETE t
		FROM [dbo].[dim_Date] t
		WHERE [DateID] >= dbo.[DateToInt](@date_s) and 
			[DateID] <= dbo.[DateToInt](@date_f)

		DECLARE @dt DATE = @date_s

		WHILE @dt <= @date_f
		BEGIN
			DECLARE @year_num_dif INT = IIF(DATEPART(dw, CAST(CAST(CAST(DATEPART(yyyy,@dt) AS NVARCHAR(4)) + '-01-01' AS NVARCHAR) AS DATETIME)) <> 1, 1, 0)
			INSERT INTO [dbo].[dim_Date](
				 [DateID]
				,[DateTime]
				,[DateName]
				,[DayTypeID]
				,[DayTypeName]
				,[WeekdayNumber]
				,[WeekdayName]
				,[WeekID]
				,[WeekName]
				,[WeekFullName]
				,[WeekNumber]
				,[MonthID]
				,[MonthName]
				,[MonthFullName]
				,[MonthNumber]
				,[QuarterID]
				,[QuarterName]
				,[QuarterFullName]
				,[YearID]
				,[YearName]
				,[MonthFullMonthName]
				,[DayID]
			)
			SELECT
				[DateID] = [dbo].[DateToInt](@dt),
				[DateTime] = @dt, 
				[DateName] = CONVERT(CHAR(10),@dt,104),
				[day_type_id] = 
					CASE DATEPART(dw,@dt) 
						WHEN 1  THEN 1
						WHEN 2  THEN 1
						WHEN 3  THEN 1
						WHEN 4  THEN 1
						WHEN 5  THEN 1
						WHEN 6  THEN 2
						WHEN 7  THEN 2
					END,
				[DayTypeName] = 
					CASE DATEPART(dw,@dt) 
						WHEN 1  THEN 'Рабочий день'
						WHEN 2  THEN 'Рабочий день'
						WHEN 3  THEN 'Рабочий день'
						WHEN 4  THEN 'Рабочий день'
						WHEN 5  THEN 'Рабочий день'
						WHEN 6  THEN 'Выходной день'
						WHEN 7  THEN 'Выходной день'
					END,
				[WeekdayNumber] = 	
					CASE DATEPART(dw,@dt) 
						WHEN 1  THEN 1
						WHEN 2  THEN 2
						WHEN 3  THEN 3
						WHEN 4  THEN 4
						WHEN 5  THEN 5
						WHEN 6  THEN 6
						WHEN 7  THEN 7
					END,
				[WeekdayName] = 
					CASE DATEPART(dw,@dt) 
						WHEN 1  THEN 'Понедельник'
						WHEN 2  THEN 'Вторник'
						WHEN 3  THEN 'Среда'
						WHEN 4  THEN 'Четверг'
						WHEN 5  THEN 'Пятница'
						WHEN 6  THEN 'Суббота'
						WHEN 7  THEN 'Воскресение'
					END,
				[WeekID] = DATEPART(yyyy,@dt)*100+DATEPART(wk,@dt),
				[WeekName] = 'Н' + LEFT ('00', 2-LEN(CONVERT(CHAR(4),DATEPART(wk,@dt) - @year_num_dif)) )+CONVERT(VARCHAR(4),DATEPART(wk,@dt) - @year_num_dif),
				[WeekFullName] = CONVERT(CHAR(4),DATEPART(yyyy,@dt)) +'/'+left ('00', 2-LEN(CONVERT(VARCHAR(4),DATEPART(wk,@dt) - @year_num_dif)) )+ CONVERT(VARCHAR(4),DATEPART(wk,@dt) - @year_num_dif)+ ' неделя',
				[WeekNumber] = DATEPART(wk,@dt) - @year_num_dif,
				[MonthID] = DATEPART(yyyy,@dt)*100+DATEPART(mm,@dt),
				[MonthName] = 
					CASE DATEPART(mm,@dt) 
						WHEN 1  THEN 'Янв'
						WHEN 2  THEN 'Фев'
						WHEN 3  THEN 'Мар'
						WHEN 4  THEN 'Апр'
						WHEN 5  THEN 'Май'
						WHEN 6  THEN 'Июн'
						WHEN 7  THEN 'Июл'
						WHEN 8  THEN 'Авг'
						WHEN 9  THEN 'Сен'
						WHEN 10 THEN 'Окт'
						WHEN 11 THEN 'Ноя'
						WHEN 12 THEN 'Дек'
					END,
				[MonthFullName] = CONVERT(CHAR(4),DATEPART(yyyy,@dt)) + '/' + 
					CASE DATEPART(mm,@dt) 
						WHEN 1  THEN 'Январь'
						WHEN 2  THEN 'Февраль'
						WHEN 3  THEN 'Март'
						WHEN 4  THEN 'Апрель'
						WHEN 5  THEN 'Май'
						WHEN 6  THEN 'Июнь'
						WHEN 7  THEN 'Июль'
						WHEN 8  THEN 'Август'
						WHEN 9  THEN 'Сентябрь'
						WHEN 10 THEN 'Октябрь'
						WHEN 11 THEN 'Ноябрь'
						WHEN 12 THEN 'Декабрь'
					END,
				[MonthNumber] = DATEPART(mm,@dt),
				[QuarterID] = DATEPART(yyyy,@dt)*10+DATEPART(qq,@dt),
				[QuarterName] = CONVERT(CHAR(1),DATEPART(qq,@dt)) + ' квартал',
				[QuarterFullName] = CONVERT(CHAR(4),DATEPART(yyyy,@dt)) +'/'+ CONVERT(CHAR(1),DATEPART(qq,@dt)) + ' квартал',
				[YearID] = DATEPART(yyyy,@dt),
				[YearName] = CONVERT(CHAR(4),DATEPART(yyyy,@dt)),
				[MonthFullMonthName] = CASE DATEPART(mm,@dt) 
						WHEN 1  THEN 'Январь'
						WHEN 2  THEN 'Февраль'
						WHEN 3  THEN 'Март'
						WHEN 4  THEN 'Апрель'
						WHEN 5  THEN 'Май'
						WHEN 6  THEN 'Июнь'
						WHEN 7  THEN 'Июль'
						WHEN 8  THEN 'Август'
						WHEN 9  THEN 'Сентябрь'
						WHEN 10 THEN 'Октябрь'
						WHEN 11 THEN 'Ноябрь'
						WHEN 12 THEN 'Декабрь'
					END,
				[DayID] = [dbo].[DateToInt](@dt) % 100
			SELECT @dt = DATEADD(DAY,1,@dt)
		END 
		--=====================================================================
		--Завершение логирования c успехом:
		--=====================================================================
	EXEC [oth].[fill_SupLog] @Name = @Name, @StateName = 'finish', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
	END TRY
	
	BEGIN CATCH
		--=====================================================================
		--Завершение логирования c ошибкой:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name, @StateName = 'error', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
	END CATCH
END