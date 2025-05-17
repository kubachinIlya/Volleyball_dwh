using System;
using System.Globalization;
using System.IO;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using Dapper;
using OfficeOpenXml;


 
var importer = new MatchStatSetLoader(
    connectionString: "Server=.;Database=Volleyball_dwh;Integrated Security=True;Encrypt=True;TrustServerCertificate=True;",
    rootFolder: @"C:\Users\Ilya\Documents\ITMO\8ой сем\практика производственная\Списки данных\Списки данных\Сезон_2024-2025"
);
importer.ProcessAllMatches();


// Пример использования
var importer1 = new MatchStatsPlayerLoader(
    connectionString: "ваша_строка_подключения",
    rootFolder: @"C:\Users\Ilya\Documents\...\Сезон_2024-2025"
);
importer1.ProcessAllPlayers();


var basePath = @"C:\Your\Path\Here";
var connectionString = "Your_Connection_String";

var matchImporter = new MatchStatsImporter(connectionString, basePath);
var playerImporter = new PlayerStatsImporter(connectionString, basePath);

matchImporter.ProcessAllMatches();
playerImporter.ProcessAllPlayers();