
# -*- coding: utf-8 -*-
import pyodbc
import pandas as pd

from sqlalchemy import create_engine

# Для Windows-аутентификации
engine = create_engine('mssql+pyodbc://@localhost/Volleyball_dwh?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server')

query = """
SELECT * 
FROM [ml_mart].[fact_MathReportByPlayersRich] 
WHERE [FolderName] LIKE '%Тур%'
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


#   вызов  для первого игрока из топ-10
#plot_player_performance(player_stats.index[0][0])

from xgboost import plot_importance
plot_importance(model)
plt.show()

# Загрузка тестовых данных (плей-офф)
playoff_query = """
SELECT * 
FROM [ml_mart].[fact_MathReportByPlayersRich] 
WHERE [FolderName] NOT LIKE '%Тур%'
ORDER BY DateTime, PlayerID
"""

playoff_df = pd.read_sql(playoff_query, engine)

# Применяем те же преобразования, что и для обучающих данных
playoff_df['IsHome'] = playoff_df['TeamID'] == playoff_df['HostTeamID']
playoff_df['DaysSinceLastGame'] = playoff_df.groupby('PlayerID')['DateTime'].diff().dt.days
playoff_df['MatchNumInSeason'] = playoff_df.groupby(['SeasonID', 'PlayerID']).cumcount() + 1

# Расчет скользящих статистик ТОЛЬКО по исходным признакам
player_stats = ['AttackPointPercent', 'TotalAttacks', 'AttackBlocks', 'AttackErrors']  # Только исходные колонки
for stat in player_stats:
    playoff_df[f'RollingAvg_{stat}'] = playoff_df.groupby('PlayerID')[stat].transform(
        lambda x: x.expanding().mean()  # Используем expanding mean для тестовых данных
    )

# Добавляем статистику соперников из ОБУЧАЮЩЕЙ выборки
opponent_stats_train = df.groupby(['OpponentTeamName', 'DateTime']).agg({
    'AttackBlocks': 'mean',
    'TotalReceptions': 'mean',
    'PerfectReceptionPercent': 'mean'
}).add_prefix('OpponentAvg_').reset_index()

playoff_df = pd.merge(playoff_df, opponent_stats_train, on=['OpponentTeamName', 'DateTime'], how='left')

# Добавляем исторические встречи из ОБУЧАЮЩЕЙ выборки
historical_train = df.groupby(['PlayerTeamName', 'OpponentTeamName']).agg({
    'AttackPointPercent': 'mean',
    'TotalAttacks': 'mean'
}).add_prefix('Historical_').reset_index()

playoff_df = pd.merge(playoff_df, historical_train, on=['PlayerTeamName', 'OpponentTeamName'], how='left')

# Подготовка финальных признаков
X_playoff = playoff_df[features].select_dtypes(include=['number'])
y_playoff = playoff_df[target]

# Делаем предсказания
playoff_preds = model.predict(X_playoff)

# Оценка модели
print("\nРезультаты на данных плей-офф:")
print(f"MAE: {mean_absolute_error(y_playoff, playoff_preds)}")
print(f"Baseline MAE: {mean_absolute_error(y_playoff, [y_train.mean()] * len(y_playoff))}")

# Добавляем предсказания в датафрейм ТОЛЬКО ПОСЛЕ ВСЕХ ВЫЧИСЛЕНИЙ
playoff_df['Predicted_AttackPercent'] = playoff_preds
playoff_df['Prediction_Diff'] = playoff_df['Predicted_AttackPercent'] - playoff_df['AttackPointPercent']

# Анализ топ-игроков
top_players_playoff = playoff_df.groupby(['PlayerID', 'PlayerName']).agg({
    'AttackPointPercent': 'mean',
    'Predicted_AttackPercent': 'mean',
    'Prediction_Diff': 'mean',
    'TotalAttacks': 'sum'
}).sort_values('TotalAttacks', ascending=False).head(10)

print("\nТоп-игроки в плей-офф:")
print(top_players_playoff)

# Визуализация для конкретного игрока
if not top_players_playoff.empty:
    plot_player_performance(top_players_playoff.index[0][0])
import numpy as np
import seaborn as sns
from sklearn.metrics import mean_squared_error, r2_score

# 1. Дополнительные метрики оценки
print("\nРасширенные метрики на данных плей-офф:")
print(f"MAE: {mean_absolute_error(y_playoff, playoff_preds):.2f}")
print(f"RMSE: {np.sqrt(mean_squared_error(y_playoff, playoff_preds)):.2f}")
print(f"R²: {r2_score(y_playoff, playoff_preds):.2f}")
print(f"Средний процент атак (реальный): {y_playoff.mean():.2f}%")
print(f"Средний процент атак (предсказанный): {np.mean(playoff_preds):.2f}%")

# 2. Анализ топ-10 игроков по количеству атак
top_players = playoff_df.groupby(['PlayerID', 'PlayerName']).agg({
    'AttackPointPercent': 'mean',
    'Predicted_AttackPercent': 'mean',
    'Prediction_Diff': 'mean',
    'TotalAttacks': 'sum',
    'TeamID': 'first'
}).sort_values('TotalAttacks', ascending=False).head(10)

# Добавляем абсолютное отклонение
top_players['Absolute_Diff'] = np.abs(top_players['Prediction_Diff'])
print("\nТоп-10 игроков в плей-офф:")
print(top_players[['AttackPointPercent', 'Predicted_AttackPercent',
                   'Prediction_Diff', 'Absolute_Diff', 'TotalAttacks']])

# 3. Визуализация отклонений для топ-игроков
plt.figure(figsize=(12, 6))
sns.barplot(
    x='PlayerName',
    y='Absolute_Diff',
    data=top_players.reset_index(),
    palette='viridis'
)
plt.title('Средняя абсолютная ошибка предсказания для топ-10 игроков')
plt.xticks(rotation=45)
plt.ylabel('Ошибка (абсолютное отклонение)')
plt.xlabel('Игрок')
plt.tight_layout()
plt.show()

# 4. Сравнение реальных и предсказанных значений (ИСПРАВЛЕННАЯ ВЕРСИЯ)
plt.figure(figsize=(10, 6))
scatter = plt.scatter(
    x=playoff_df['AttackPointPercent'],
    y=playoff_df['Predicted_AttackPercent'],
    c=playoff_df['TotalAttacks'],
    cmap='coolwarm',
    alpha=0.6
)
plt.plot([0, 100], [0, 100], 'r--')  # Линия идеальных предсказаний
plt.title('Реальный vs Предсказанный процент успешных атак')
plt.xlabel('Реальный процент атак')
plt.ylabel('Предсказанный процент атак')
cbar = plt.colorbar(scatter)
cbar.set_label('Количество атак')
plt.grid()
plt.show()
# 5. Распределение ошибок
plt.figure(figsize=(10, 6))
sns.histplot(
    playoff_df['Prediction_Diff'],
    bins=30,
    kde=True,
    color='skyblue'
)
plt.title('Распределение ошибок предсказания')
plt.xlabel('Ошибка предсказания (Предсказанный - Реальный)')
plt.ylabel('Количество наблюдений')
plt.axvline(0, color='red', linestyle='--')
plt.show()


# 6. График для конкретного игрока с динамикой
def plot_player_detailed(player_id):
    player_data = playoff_df[playoff_df['PlayerID'] == player_id].sort_values('DateTime')
    if player_data.empty:
        return

    plt.figure(figsize=(14, 7))

    # График процента атак
    plt.subplot(2, 1, 1)
    plt.plot(player_data['DateTime'], player_data['AttackPointPercent'],
             label='Реальный %', marker='o', linewidth=2)
    plt.plot(player_data['DateTime'], player_data['Predicted_AttackPercent'],
             label='Предсказанный %', marker='x', linewidth=2)
    plt.fill_between(
        player_data['DateTime'],
        player_data['AttackPointPercent'] - 10,
        player_data['AttackPointPercent'] + 10,
        alpha=0.1,
        color='green'
    )
    plt.title(f'Процент атак для {player_data["PlayerName"].iloc[0]} (ID: {player_id})')
    plt.legend()
    plt.grid()
    plt.xticks(rotation=45)

    # График ошибок
    plt.subplot(2, 1, 2)
    plt.bar(
        player_data['DateTime'],
        player_data['Prediction_Diff'],
        color=np.where(player_data['Prediction_Diff'] > 0, 'blue', 'red')
    )
    plt.title('Ошибка предсказания')
    plt.xlabel('Дата матча')
    plt.ylabel('Разница (Предсказанный - Реальный)')
    plt.grid()
    plt.tight_layout()
    plt.show()


# Визуализация для первого игрока из топ-10
if not top_players.empty:
    plot_player_detailed(top_players.index[0][0])