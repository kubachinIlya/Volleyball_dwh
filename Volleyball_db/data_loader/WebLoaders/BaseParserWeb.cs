using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using HtmlAgilityPack;
using Microsoft.Data.SqlClient;

public abstract class BaseParserWeb
{
    protected readonly HttpClient _httpClient;
    protected readonly string _baseUrl;
    protected readonly int _delayMs;

    protected BaseParserWeb(string baseUrl, int delayMs = 1000)
    {
        _httpClient = new HttpClient();
        _baseUrl = baseUrl;
        _delayMs = delayMs;
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

        _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
    }

    protected virtual async Task<HtmlDocument> LoadPage(string url)
    {
        try
        {
            await Task.Delay(_delayMs);

            // Получаем ответ как поток байтов
            var response = await _httpClient.GetByteArrayAsync(url);

            // Автоопределение кодировки
            var encoding = DetectEncoding(response) ?? Encoding.UTF8;

            // Декодируем с правильной кодировкой
            var html = encoding.GetString(response);

            var doc = new HtmlDocument();
            doc.LoadHtml(html);

            // Логирование HTML для проверки
            Console.WriteLine(doc.DocumentNode.OuterHtml);

            return doc;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Ошибка загрузки: {ex.Message}");
            return null;
        }
    }
    private Encoding DetectEncoding(byte[] content)
    {
        try
        {
            // Попытка определить кодировку через meta-теги
            var metaMatch = Regex.Match(Encoding.ASCII.GetString(content),
                @"<meta.*?charset=[""']?([\w-]+)""?/?>",
                RegexOptions.IgnoreCase);

            if (metaMatch.Success)
            {
                var charset = metaMatch.Groups[1].Value
                    .Replace("windows-1251", "WINDOWS-1251"); // нормализация
                return Encoding.GetEncoding(charset);
            }
        }
        catch { }

        // Fallback кодировки для русских сайтов
        return Encoding.GetEncoding(1251); // windows-1251
    }

    protected abstract Task ParseData(HtmlDocument doc);

    public virtual async Task StartParsing()
    {
        Console.WriteLine($"Начало парсинга {_baseUrl}");
        var doc = await LoadPage(_baseUrl);
        if (doc != null)
        {
            await ParseData(doc);
        }
    }
}

 
 
 