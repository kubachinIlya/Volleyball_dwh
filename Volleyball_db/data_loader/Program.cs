using System;
using System.Globalization;
using System.IO;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using Dapper;
using OfficeOpenXml;


 
var basePath = @"C:\Users\Ilya\Documents\ITMO\8ой сем\практика производственная\Списки данных\Списки данных\Сезон_2024-2025";
var connectionString = "Server=.;Database=Volleyball_dwh;Integrated Security=True;Encrypt=True;TrustServerCertificate=True;";

var matchImporter = new MatchStatsImporter(connectionString, basePath);
var playerImporter = new PlayerStatsImporter(connectionString, basePath);

matchImporter.ProcessAllMatches();
playerImporter.ProcessAllPlayers();