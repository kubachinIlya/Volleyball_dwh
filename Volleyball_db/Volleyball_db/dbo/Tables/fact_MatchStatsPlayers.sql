CREATE TABLE [dbo].[fact_MatchStatsPlayers] (
    [MatchDateID]               INT            NOT NULL,
    [FolderName]                NVARCHAR (400) NULL,
    [SeasonID]                  INT            NOT NULL,
    [StageID]                   INT            NOT NULL,
    [HostCityID]                INT            NOT NULL,
    [HostTeamID]                INT            NOT NULL,
    [GuestTeamID]               INT            NOT NULL,
    [OpponentTeamName]          NVARCHAR (100) NULL,
    [TeamID]                    INT            NOT NULL,
    [PlayerTeamName]            NVARCHAR (100) NULL,
    [PlayerID]                  INT            NOT NULL,
    [PlayerName]                NVARCHAR (100) NULL,
    [PlayerNumber]              INT            NULL,
    [Set1]                      INT            NULL,
    [Set2]                      INT            NULL,
    [Set3]                      INT            NULL,
    [Set4]                      INT            NULL,
    [Set5]                      INT            NULL,
    [TotalPoints]               INT            NULL,
    [BreakPoints]               INT            NULL,
    [ScoredLostPoints]          INT            NULL,
    [TotalServes]               INT            NULL,
    [ServeErrors]               INT            NULL,
    [ServePoints]               INT            NULL,
    [TotalReceptions]           INT            NULL,
    [ReceptionErrors]           INT            NULL,
    [PerfectReceptionPercent]   INT            NULL,
    [ExcellentReceptionPercent] INT            NULL,
    [TotalAttacks]              INT            NULL,
    [AttackErrors]              INT            NULL,
    [AttackBlocks]              INT            NULL,
    [AttackPoints]              INT            NULL,
    [AttackPointPercent]        INT            NULL,
    [BlockPoints]               INT            NULL,
    CONSTRAINT [PK_fact_MatchStatsPlayers] PRIMARY KEY CLUSTERED ([SeasonID] ASC, [MatchDateID] ASC, [TeamID] ASC, [PlayerID] ASC) ON [ps_MatchStatsPlayersBySeason] ([SeasonID])
) ON [ps_MatchStatsPlayersBySeason] ([SeasonID]);


GO
CREATE COLUMNSTORE INDEX [NCCI_fact_MatchStatsPlayers]
    ON [dbo].[fact_MatchStatsPlayers]([MatchDateID], [SeasonID], [StageID], [HostCityID], [HostTeamID], [GuestTeamID], [TeamID], [PlayerID], [TotalPoints], [BreakPoints], [ScoredLostPoints], [TotalServes], [ServeErrors], [ServePoints], [TotalReceptions], [ReceptionErrors], [PerfectReceptionPercent], [ExcellentReceptionPercent], [TotalAttacks], [AttackErrors], [AttackBlocks], [AttackPoints], [AttackPointPercent], [BlockPoints])
    ON [ps_MatchStatsPlayersBySeason] ([SeasonID]);

