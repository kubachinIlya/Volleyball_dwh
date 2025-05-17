// Базовый класс для всех импортеров
using Dapper;
using data_loader.Models;
using Microsoft.Data.SqlClient;
using OfficeOpenXml;
using System.Globalization;
using System.Text.RegularExpressions;

public abstract class BaseImporter
{
    protected readonly string _connectionString;
    protected readonly string _rootFolder;

    protected BaseImporter(string connectionString, string rootFolder)
    {
        ExcelPackage.License.SetNonCommercialOrganization("My Noncommercial organization");
        _connectionString = connectionString;
        _rootFolder = rootFolder;
    }

    protected (DateTime MatchDate, string HomeTeam, string AwayTeam, string FolderName) GetFolderInfo(string filePath)
    {
        var directory = new DirectoryInfo(Path.GetDirectoryName(filePath));
        var folderName = directory.Name;

        var dateMatch = Regex.Match(folderName, @"(\d{2}[_-]\d{2}[_-]\d{4})");
        if (!dateMatch.Success) throw new FormatException($"Дата не найдена в: {folderName}");

        var datePart = dateMatch.Value.Replace('_', '-');
        if (!DateTime.TryParseExact(datePart, new[] { "dd-MM-yyyy", "d-MM-yyyy" },
            CultureInfo.InvariantCulture, DateTimeStyles.None, out var matchDate))
        {
            throw new FormatException($"Неверный формат даты: {datePart}");
        }

        var противIndex = folderName.IndexOf("_против_", StringComparison.Ordinal);
        if (противIndex == -1) throw new FormatException($"Нет разделителя '_против_' в: {folderName}");

        return (
            matchDate,
            folderName.Substring(0, противIndex).Split('_').Last(),
            folderName.Substring(противIndex + 8).Split('_').First(),
            folderName
        );
    }

    protected int ParseInt(string value) =>
        int.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out int result) ? result : 0;

    protected decimal ParseDecimal(string value) =>
        decimal.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal result) ? result : 0m;

    protected int? ParseNullableInt(string value) =>
        int.TryParse(value, NumberStyles.Any, CultureInfo.InvariantCulture, out int result) ? result : (int?)null;


    // Обобщенный метод для сохранения данных
    protected void SaveToDatabase<T>(IEnumerable<T> data, string tableName)
    {
        var properties = typeof(T).GetProperties();
        var columns = string.Join(", ", properties.Select(p => $"[{p.Name}]"));
        var parameters = string.Join(", ", properties.Select(p => $"@{p.Name}"));

        using var connection = new SqlConnection(_connectionString);
        connection.Execute(
            $@"INSERT INTO {tableName} 
            ({columns}) 
        VALUES 
            ({parameters})",
            data);
    }
}

 

 

 

