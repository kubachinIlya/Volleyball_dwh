# скрипт для расчета атаки регресия
# -*- coding: utf-8 -*-
import pyodbc
import pandas as pd

from sqlalchemy import create_engine

# Для Windows-аутентификации
engine = create_engine('mssql+pyodbc://@localhost/Volleyball_dwh?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server')

query = """
SELECT * 
FROM [ml_mart].[fact_MathReportByPlayersRich] 

ORDER BY DateTime, PlayerID
"""

df = pd.read_sql(query, engine)


# Преобразование данных
df['IsHome'] = df['TeamID'] == df['HostTeamID']
df['DaysSinceLastGame'] = df.groupby('PlayerID')['DateTime'].diff().dt.days
df['MatchNumInSeason'] = df.groupby(['SeasonID', 'PlayerID']).cumcount() + 1

# Расчет скользящих статистик
player_stats = ['AttackPointPercent', 'TotalAttacks', 'AttackBlocks', 'AttackErrors']
for stat in player_stats:
    df[f'RollingAvg_{stat}'] = df.groupby('PlayerID')[stat].transform(
        lambda x: x.rolling(3, min_periods=1).mean()
    )

# Статистика соперника
opponent_stats = df.groupby(['OpponentTeamName', 'DateTime']).agg({
    'AttackBlocks': 'mean',
    'TotalReceptions': 'mean',
    'PerfectReceptionPercent': 'mean'
}).add_prefix('OpponentAvg_').reset_index()

df = pd.merge(df, opponent_stats, on=['OpponentTeamName', 'DateTime'], how='left')

# Исторические встречи
historical = df.groupby(['PlayerTeamName', 'OpponentTeamName']).agg({
    'AttackPointPercent': 'mean',
    'TotalAttacks': 'mean'
}).add_prefix('Historical_').reset_index()

df = pd.merge(df, historical, on=['PlayerTeamName', 'OpponentTeamName'], how='left')

features = [
    'PlayerHeight', 'IsHome', 'DaysSinceLastGame', 'MatchNumInSeason',
    'RollingAvg_AttackPointPercent', 'RollingAvg_TotalAttacks',
    'OpponentAvg_AttackBlocks', 'OpponentAvg_PerfectReceptionPercent',
    'Historical_AttackPointPercent', 'PlayerID', 'TeamID', 'OpponentTeamName'
]

target = 'AttackPointPercent'

from xgboost import XGBRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error

X = df[features].select_dtypes(include=['number'])
y = df[target]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False)

model = XGBRegressor(objective='reg:squarederror', n_estimators=100)
model.fit(X_train, y_train)

preds = model.predict(X_test)
print(f"MAE: {mean_absolute_error(y_test, preds)}")
print(f"Baseline MAE: {mean_absolute_error(y_test, [y_train.mean()] * len(y_test))}")

# Добавляем предсказания в исходный DataFrame
df['Predicted_AttackPercent'] = model.predict(X)

# Сортируем по разнице между предсказанием и реальностью
df['Prediction_Diff'] = df['Predicted_AttackPercent'] - df['AttackPointPercent']

player_stats = df.groupby(['PlayerID', 'PlayerName']).agg({
    'AttackPointPercent': 'mean',
    'Predicted_AttackPercent': 'mean',
    'Prediction_Diff': 'mean',
    'TotalAttacks': 'sum'
}).sort_values('TotalAttacks', ascending=False).head(10)

print(player_stats)
import matplotlib.pyplot as plt


def plot_player_performance(player_id):
    player_data = df[df['PlayerID'] == player_id].sort_values('DateTime')

    plt.figure(figsize=(12, 6))
    plt.plot(player_data['DateTime'], player_data['AttackPointPercent'],
             label='Реальный %', marker='o')
    plt.plot(player_data['DateTime'], player_data['Predicted_AttackPercent'],
             label='Предсказанный %', marker='x')
    plt.title(f'Процент атак для {player_data["PlayerName"].iloc[0]}')
    plt.legend()
    plt.grid()
    plt.xticks(rotation=45)
    plt.show()


# Пример вызова для первого игрока из топ-10
#plot_player_performance(player_stats.index[0][0])

from xgboost import plot_importance
plot_importance(model)
plt.show()