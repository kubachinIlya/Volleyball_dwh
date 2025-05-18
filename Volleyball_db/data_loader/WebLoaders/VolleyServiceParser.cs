using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net.Http;
using System.Threading.Tasks;
using Dapper;
using HtmlAgilityPack;
using Microsoft.Data.SqlClient;

public class VolleyServiceParser : BaseParserWeb
{
    private readonly string _connectionString;

    public VolleyServiceParser(
        string baseUrl,
        string connectionString,
        int delayMs = 1000)
        : base(baseUrl, delayMs)
    {
        _connectionString = connectionString;
    }

    protected override async Task ParseData(HtmlDocument doc)
    {
        var table = doc.DocumentNode.SelectSingleNode("//table[contains(@style, 'width:810px')]");
        if (table == null)
        {
            Console.WriteLine("Таблица статистики не найдена");
            return;
        }

        Console.WriteLine("Таблица найдена, начинаем парсинг...");

        var playersData = new List<PlayerStat>();

        var rows = table.SelectNodes(".//tr[position()>2]");
        if (rows == null || rows.Count == 0)
        {
            Console.WriteLine("Строки таблицы не найдены");
            return;
        }

        foreach (var row in rows)
        {
            var cells = row.SelectNodes(".//td");
            if (cells == null)
            {
                Console.WriteLine("Ячейки не найдены в строке");
                continue;
            }

            try
            {
                //if (cells.Count < 24)
                //{
                //    Console.WriteLine("Недостаточно ячеек в строке, пропускаем");
                //    continue;
                //}

                var playerStat = new PlayerStat
                {
                    Name = cells[1].InnerText.Trim(),
                    Position = "",
                    Games = cells[2].InnerText.Trim(),
                    Points = ParseInt(cells[3].InnerText),
                    AveragePoints = ParseDouble(cells[4].InnerText),
                    PointsDifference = ParseInt(cells[5].InnerText),
                    SourceTotal = ParseInt(cells[6].InnerText),
                    SourcePoints = ParseInt(cells[7].InnerText),
                    SourceEfficiency = ParseDouble(cells[8].InnerText),
                    ReceiveTotal = ParseInt(cells[9].InnerText),
                    ReceiveGood = ParseDouble(cells[10].InnerText),
                    ReceiveEfficiency = ParseDouble(cells[11].InnerText),
                    AttackTotal = ParseInt(cells[12].InnerText),
                    AttackPoints = ParseInt(cells[13].InnerText),
                    AttackEfficiency = ParseDouble(cells[14].InnerText),
                    BlockPoints = ParseInt(cells[15].InnerText),
                    BlockAverage = ParseDouble(cells[16].InnerText),
                    ErrorServe = ParseInt(cells[17].InnerText),
                    ErrorReceive = ParseInt(cells[18].InnerText),
                    ErrorAttack = ParseInt(cells[19].InnerText),
                    ErrorTotal = ParseInt(cells[20].InnerText)
                };

                playersData.Add(playerStat);
                Console.WriteLine($"Обработан игрок: {playerStat.Name}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Ошибка парсинга строки: {ex.Message}");
            }
        }

        await SaveToDatabase(playersData);
    }


    private async Task SaveToDatabase(IEnumerable<PlayerStat> stats)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        const string query = @"INSERT INTO [stg_web].[PlayerStats]
    (Name, Position, Games, Points, AveragePoints, PointsDifference, SourceTotal, SourcePoints, SourceEfficiency,
     ReceiveTotal, ReceiveGood, ReceiveEfficiency, AttackTotal, AttackPoints, AttackEfficiency,
     BlockPoints, BlockAverage, ErrorServe, ErrorReceive, ErrorAttack, ErrorTotal)
    VALUES
    (@Name, @Position, @Games, @Points, @AveragePoints, @PointsDifference, @SourceTotal, @SourcePoints, @SourceEfficiency,
     @ReceiveTotal, @ReceiveGood, @ReceiveEfficiency, @AttackTotal, @AttackPoints, @AttackEfficiency,
     @BlockPoints, @BlockAverage, @ErrorServe, @ErrorReceive, @ErrorAttack, @ErrorTotal)";


        await connection.ExecuteAsync(query, stats);
    }

    private int ParseInt(string input)
    {
        if (string.IsNullOrEmpty(input))
            return 0;

        return int.TryParse(input, out var result) ? result : 0;
    }

    private double ParseDouble(string input)
    {
        if (string.IsNullOrEmpty(input))
            return 0.0;

        // Заменяем запятую на точку для корректного парсинга
        input = input.Replace(",", ".");

        return double.TryParse(input, NumberStyles.Any, CultureInfo.InvariantCulture, out var result) ? result : 0.0;
    }
}
