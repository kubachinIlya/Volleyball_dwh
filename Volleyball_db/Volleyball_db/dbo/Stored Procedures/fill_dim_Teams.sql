/*
--D:Процедура по заполнению справочника справочника команд
--E: EXEC [dbo].[fill_dim_Teams]
*/

CREATE PROCEDURE [dbo].[fill_dim_Teams]
AS
BEGIN
	--=====================================================================
	--Инициализация логирования:
	--=====================================================================	
	DECLARE  @Name NVARCHAR(MAX) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
			,@Description NVARCHAR(512) = 'Заполнение справочника команд'
			,@InputParameters NVARCHAR(512) = ''
	BEGIN TRY
		--=====================================================================
		--Запуск логирования:
		--=====================================================================
		EXEC [oth].[fill_SupLog] @Name = @Name,	@StateName = 'start', @SpID = @@SPID, @Description = @Description, @InputParameters  = @InputParameters;
		--=====================================================================
		--Тело процедуры:
		--=====================================================================	
	
		
		CREATE TABLE #Teams
		(
			[TeamName] [nvarchar](128) NULL,
			[CityName] [nvarchar](64) NULL,
			[SecondCityName] [nvarchar](64) NULL,
			[TeamOfficialName] [nvarchar](256) NULL,
			[TeamFullName] [nvarchar](128) NULL,
			[Address] [nvarchar](256) NULL,
			[Phone] [nvarchar](32) NULL,
			[Email] [nvarchar](128) NULL,
			[Website] [nvarchar](128) NULL
		)
		INSERT INTO #Teams
		(
			[TeamName],
			[CityName],
			[SecondCityName],
			[TeamOfficialName],
			[TeamFullName],
			[Address],
			[Phone],
			[Email],
			[Website]
		)
		VALUES 
		(
			N'Белогорье',
			N'Белгород',
			N'Тула',
			N'Ассоциация «ВК «Белогорье», г. Белгород',
			N'Белогорье, Белгород',
			N'308004 Белгородская обл., г. Белгород, ул. Щорса, д.51',
			N'+74722400455',
			N'belogorye-club@yandex.ru',
			N'https://belogorievolley.ru/'
		),(
			N'Динамо-ЛО',
			N'Сосновый Бор',
			NULL,
			N'Ассоциация спортивных организаций и любителей спорта «Волейбольный клуб Динамо – Ленинградская область»',
			N'Динамо-ЛО, Ленинградская обл.',
			N'188540, Ленинградская область, г.о. Сосновоборский, г. Сосновый Бор, ул. Соколова, зд.7, помещ. 2047',
			N'+79934594889',
			N'club@vc-dynamo.ru',
			NULL
		),(
			N'Зенит-Казань',
			N'Казань',
			NULL,
			NULL, -- Нет информации о полном названии клуба
			N'Зенит-Казань',
			NULL,
			N'+78437654321',
			N'media@zenit-kazan.com',
			N'zenit-kazan.com'
		),(
			N'Нова',
			N'Новокуйбышевск',
			NULL,
			NULL, -- Нет информации о полном названии клуба
			N'Нова',
			NULL,
			N'+78463536750',
			N'novavolley@mail.ru',
			N'nova-volley.ru'
		),(
			N'Ассоциация спортивных клубов Нижегородской области',
			N'Нижний Новгород',
			NULL,
			N'Ассоциация спортивных клубов Нижегородской области',
			N'АСК, Нижний Новгород',
			N'603076, г. Нижний Новгород, пр-кт Ленина, д.54А, оф.1109',
			N'+79616320252',
			N'ask-no@mail.ru',
			NULL
		),(
			N'Газпром-Югра',
			N'Сургут',
			NULL,
			NULL,  
			N'Газпром-Югра',
			NULL,
			NULL,  
			NULL, 
			N'gazprom-ugra.ru'
		),(
			N'Динамо', 
			N'Москва',
			NULL,
			N'Автономная некоммерческая организация «Волейбольный клуб Динамо (МОСКВА)»',
			N'Динамо, Москва',
			N'129110, г. Москва, Переяславская Б. ул, дом 46, строение 2',
			N'+74959871182',
			N'bvtdynamo@gmail.com',
			N'https://bvtdynamo.ru'
		),(
			N'Динамо-Урал',  
			N'Уфа',
			NULL,
			N'РОО "ФСО "ДИНАМО" РБ"',
			N'Динамо-Урал, Уфа',
			N'450071, РФ, Республика Башкортостан, г. Уфа, ул. Менделеева, д. 219/1',
			N'+7 3472680771',
			N'ural-volley@mail.ru',
			N'www.volleyufa.com'
		),(
			N'Енисей',  
			N'Красноярск',
			NULL,
			N'АНО «Волейбольный клуб «Енисей»',
			N'Енисей, Красноярск',
			N'660093, г. Красноярск, о. Отдыха, 15',
			N'+79832676463',
			N'vc-dorojnik@mail.ru',
			N'https://vc-enisey.ru/'
		),(
			N'Зенит',   
			N'Санкт-Петербург',
			NULL,
			N'АНО «Волейбольный клуб «Зенит – Санкт-Петербург»',
			N'Зенит, Санкт-Петербург',
			N'197349, г. Санкт-Петербург, а/я 750',
			N'88122302417',
			N'club@vczenit.ru',
			N'vczenit.ru'
		),(
			N'Кузбасс',   
			N'Кемерово',
			NULL,
			N'Ассоциация «ФСО «Волейбольный клуб Кузбасс»',
			N'Кузбасс, Кемерово',
			N'650036, г. Кемерово, ул.Гагарина, 124',
			N'+73842396011',
			N'vk.kuzbass@mail.ru',
			N'https://kuzbass-volley.ru/'
		), (
			N'Локомотив',
			N'Новосибирск',
			NULL,
			NULL, -- Нет информации о полном названии клуба
			N'Локомотив',
			NULL,
			N'+73832718991',
			N'office@lokovolley.com',
			N'www.lokovolley.com'
		),(
			N'Факел-Ямал',  
			N'Новый Уренгой',
			NULL,
			N'Автономная Некоммерческая Организация «Волейбольный Клуб «Факел-Ямал»',
			N'Факел-Ямал, Новый Уренгой',
			N'629307 Ямало-Ненецкий автономный округ, г. Новый Уренгой, ул. Набережная д. 42а',
			N'+73494939488',
			N'manager@fakelvolley.ru',
			N'fakelvolley.ru' -- Сайт  
		),(
			N'Оренбуржье',
			N'Оренбург',
			NULL,
			NULL, -- Нет информации о полном названии клуба
			N'Оренбуржье',
			NULL,
			N'+73532505171',
			N'orenvolley@mail.ru',
			N'orenvolley.com'
		),(
			N'МГТУ',
			N'Москва',
			NULL,
			NULL, -- Нет информации о полном названии клуба
			N'МГТУ, Москва',
			NULL,
			N'+74992632730',
			N'mgtuvolley@mail.ru',
			N'vcbmstu.ru'
		);

		MERGE INTO [dbo].[dim_Teams] AS tdbo
		USING (
			SELECT
				 [TeamName]
				,C.[CityID]
				,CS.[CityID] AS [SecondCityID]
				,[TeamOfficialName]
				,[TeamFullName]
				,[Address]
				,[Phone]
				,[Email]
				,[Website]
			FROM #Teams T
			LEFT JOIN [dbo].[dim_Cities] C
				ON T.[CityName] = C.[CityName]
			LEFT JOIN [dbo].[dim_Cities] CS
				ON T.[SecondCityName] = CS.[CityName]
		) AS tstg
		ON 
			tdbo.[TeamName] = tstg.[TeamName]
		WHEN NOT MATCHED BY TARGET
		THEN INSERT
			(
				 [TeamName]
				,[CityID]
				,[SecondCityID]
				,[TeamOfficialName]
				,[TeamFullName]
				,[Address]
				,[Phone]
				,[Email]
				,[Website]
			)
		VALUES
			(
				ISNULL(tstg.[TeamName], 'Н/Д'),
				ISNULL(tstg.[CityID], -1),
				ISNULL(tstg.[SecondCityID], -1),
				ISNULL(tstg.[TeamOfficialName], 'Н/Д'),
				ISNULL(tstg.[TeamFullName], 'Н/Д'),
				ISNULL(tstg.[Address], 'Н/Д'),
				ISNULL(tstg.[Phone], 'Н/Д'),
				ISNULL(tstg.[Email], 'Н/Д'),
				ISNULL(tstg.[Website], 'Н/Д')
			)
		WHEN MATCHED AND
			(
				   tdbo.[CityID] != ISNULL(tstg.[CityID], -1) 
				OR tdbo.[SecondCityID] != ISNULL(tstg.[SecondCityID], -1) 
				OR tdbo.[TeamOfficialName] != ISNULL(tstg.[TeamOfficialName], 'Н/Д') 
				OR tdbo.[TeamName] != ISNULL(tstg.[TeamName], 'Н/Д') 
				OR tdbo.[Address] != ISNULL(tstg.[Address], 'Н/Д') 
				OR tdbo.[Phone] != ISNULL(tstg.[Phone], 'Н/Д') 
				OR tdbo.[Email] != ISNULL(tstg.[Email], 'Н/Д') 
				OR tdbo.[Website] != ISNULL(tstg.[Website], 'Н/Д')
			)
		THEN UPDATE SET
				   tdbo.[CityID] = ISNULL(tstg.[CityID], -1) 
				  ,tdbo.[SecondCityID] = ISNULL(tstg.[SecondCityID], -1) 
				  ,tdbo.[TeamOfficialName] = ISNULL(tstg.[TeamOfficialName], 'Н/Д') 
				  ,tdbo.[TeamFullName] = ISNULL(tstg.[TeamFullName], 'Н/Д') 
				  ,tdbo.[Address] = ISNULL(tstg.[Address], 'Н/Д') 
				  ,tdbo.[Phone] = ISNULL(tstg.[Phone], 'Н/Д') 
				  ,tdbo.[Email] = ISNULL(tstg.[Email], 'Н/Д') 
				  ,tdbo.[Website] = ISNULL(tstg.[Website], 'Н/Д');


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