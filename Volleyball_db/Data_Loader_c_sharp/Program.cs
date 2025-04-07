using Data_Loader_c_sharp;
using Data_Loader_c_sharp.Parsers;
using Data_Loader_c_sharp.Repositories;
using Data_Loader_c_sharp.Services;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = Host.CreateDefaultBuilder(args)
        .ConfigureServices(services =>
        {
            services.AddTransient<IExcelParser, EPPlusExcelParser>();
            services.AddTransient<IStatsRepository>(provider =>
                new SqlServerStatsRepository("ваша_строка_подключения"));
            services.AddTransient<StatsImporter>();
        })
        .Build();

var importer = host.Services.GetRequiredService<StatsImporter>();

// Пример: обработка всех файлов в папке
var files = Directory.GetFiles("C:/StatsFiles/", "*.xlsx");
foreach (var file in files)
{
    Console.WriteLine($"Processing {Path.GetFileName(file)}");
    await importer.ImportAsync(file);
}

Console.WriteLine("Import completed!");