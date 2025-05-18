public class PlayerStat
{
    public string Name { get; set; }
    public string Position { get; set; }
    public string Games { get; set; }
    public int Points { get; set; }
    public double AveragePoints { get; set; }
    public int PointsDifference { get; set; }
    public int SourceTotal { get; set; }
    public int SourcePoints { get; set; }
    public double SourceEfficiency { get; set; }
    public int ReceiveTotal { get; set; }
    public double ReceiveGood { get; set; }
    public double ReceiveEfficiency { get; set; }
    public int AttackTotal { get; set; }
    public int AttackPoints { get; set; }
    public double AttackEfficiency { get; set; }
    public int BlockPoints { get; set; }
    public double BlockAverage { get; set; }
    public int ErrorServe { get; set; }
    public int ErrorReceive { get; set; }
    public int ErrorAttack { get; set; }
    public int ErrorTotal { get; set; }
}
