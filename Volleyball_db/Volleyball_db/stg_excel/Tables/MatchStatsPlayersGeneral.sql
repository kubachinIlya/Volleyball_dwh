﻿CREATE TABLE [stg_excel].[MatchStatsPlayersGeneral] (
    [Id]                        INT            IDENTITY (1, 1) NOT NULL,
    [FileName]                  NVARCHAR (255) NOT NULL,
    [FolderName]                NVARCHAR (500) NOT NULL,
    [MatchDate]                 DATETIME       DEFAULT (getdate()) NOT NULL,
    [OpponentTeamName]          NVARCHAR (100) NOT NULL,
    [TeamName]                  NVARCHAR (100) NOT NULL,
    [PlayerNumber]              INT            NULL,
    [PlayerName]                NVARCHAR (100) NULL,
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
    [ParentFolderName]          NVARCHAR (128) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

