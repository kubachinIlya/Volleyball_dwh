using System.Text.Json;

public class AppConfig
{
    public ConnectionStringsConfig ConnectionStrings { get; set; }
    public DataPathsConfig DataPaths { get; set; }
    public ParserSettingsConfig ParserSettings { get; set; }

    public class ConnectionStringsConfig
    {
        public string VolleyballDB { get; set; }
    }

    public class DataPathsConfig
    {
        public string BasePath { get; set; }
    }

    public class ParserSettingsConfig
    {
        public string VolleyServiceUrl { get; set; }
        public int RequestDelayMs { get; set; }
    }
    public static AppConfig LoadConfig(string configPath = "appconfig.json")
    {
        var json = File.ReadAllText(configPath);
        return JsonSerializer.Deserialize<AppConfig>(json, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
            ReadCommentHandling = JsonCommentHandling.Skip
        });
    }
}