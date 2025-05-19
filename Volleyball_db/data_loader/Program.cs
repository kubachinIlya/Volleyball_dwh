using System;
using System.Globalization;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

public static class Program
{
    public static async Task Main(string[] args)
    {
        // Загрузка конфигурации
        var config = AppConfig.LoadConfig();

        // Инициализация импортеров
        var matchImporter = new MatchStatsImporter(
            config.ConnectionStrings.VolleyballDB,
            config.DataPaths.BasePath
        );

        var playerImporter = new PlayerStatsImporter(
            config.ConnectionStrings.VolleyballDB,
            config.DataPaths.BasePath
        );
        var playersListImporter = new PlayersListImporter(
            config.ConnectionStrings.VolleyballDB,
            config.DataPaths.BasePath
        );
        //Запуск обработки
       // matchImporter.ProcessAllMatches();
      //  playerImporter.ProcessAllPlayers();
         playersListImporter.ProcessAllPlayers();

        //Инициализация парсера
        var parser = new VolleyServiceParser(
            config.ParserSettings.VolleyServiceUrl,
            config.ConnectionStrings.VolleyballDB,
            config.ParserSettings.RequestDelayMs
        );

        // Запуск парсера
       // await parser.StartParsing();

    }
}