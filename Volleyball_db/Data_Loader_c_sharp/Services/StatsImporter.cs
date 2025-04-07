namespace Data_Loader_c_sharp.Services
{
    public class StatsImporter
    {
        private readonly IExcelParser _parser;
        private readonly IStatsRepository _repository;

        public StatsImporter(IExcelParser parser, IStatsRepository repository)
        {
            _parser = parser;
            _repository = repository;
        }

        public async Task ImportAsync(string filePath)
        {
            var stats = await _parser.ParsePlayerStats(filePath);
            await _repository.SavePlayerStatsAsync(stats);
        }
    }
}
