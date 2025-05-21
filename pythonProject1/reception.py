import pandas as pd
from sqlalchemy import create_engine
import numpy as np

# Подключение к БД
engine = create_engine('mssql+pyodbc://@localhost/Volleyball_dwh?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server')

# Загрузка данных
query = """
SELECT * 
FROM [ml_mart].[fact_MathReportByPlayersRich] 
WHERE [FolderName] LIKE '%Тур%'
ORDER BY DateTime, PlayerID
"""
df = pd.read_sql(query, engine)

# Фильтрация игроков с малым количеством приемов
df = df[df['TotalReceptions'] >= 4].copy()

# Расчет целевой переменной
df['PerfectReceptionPercent'] = df['PerfectReceptionPercent'].fillna(0)

# Базовые преобразования
df['IsHome'] = df['TeamID'] == df['HostTeamID']
df['DaysSinceLastGame'] = df.groupby('PlayerID')['DateTime'].diff().dt.days
df['MatchNumInSeason'] = df.groupby(['SeasonID', 'PlayerID']).cumcount() + 1

# Скользящие статистики игрока
player_stats = ['PerfectReceptionPercent', 'TotalReceptions', 'ReceptionErrors']
for stat in player_stats:
    df[f'RollingAvg_{stat}'] = df.groupby('PlayerID')[stat].transform(
        lambda x: x.rolling(3, min_periods=1).mean()
    )

# Статистика подач соперника (агрегируем по командам)
opponent_serve_stats = df.groupby(['OpponentTeamName', 'DateTime']).agg({
    'ServePoints': 'sum',
    'ServeErrors': 'sum',
    'TotalServes': 'sum'
}).reset_index()
opponent_serve_stats['OpponentServeEff'] = (
    (opponent_serve_stats['ServePoints'] - opponent_serve_stats['ServeErrors']) /
    opponent_serve_stats['TotalServes'].replace(0, 1)
)
df = pd.merge(df, opponent_serve_stats, on=['OpponentTeamName', 'DateTime'], how='left')

# Исторические показатели против конкретных соперников
historical_reception = df.groupby(['PlayerID', 'OpponentTeamName']).agg({
    'PerfectReceptionPercent': 'mean',
    'TotalReceptions': 'mean'
}).add_prefix('Historical_').reset_index()
df = pd.merge(df, historical_reception, on=['PlayerID', 'OpponentTeamName'], how='left')


features = [
    'PlayerHeight', 'IsHome', 'DaysSinceLastGame', 'MatchNumInSeason',
    'RollingAvg_PerfectReceptionPercent', 'RollingAvg_TotalReceptions',
    'OpponentServeEff', 'Historical_PerfectReceptionPercent',
    'TotalReceptions'  # Количество приемов в текущем матче
]

target = 'PerfectReceptionPercent'


from xgboost import XGBRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score, mean_squared_error

# Подготовка данных
X = df[features].select_dtypes(include=['number'])
y = df[target]

# Разделение на train/test с сохранением временного порядка
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, shuffle=False)

# Обучение модели
model = XGBRegressor(
    objective='reg:squarederror',
    n_estimators=150,
    max_depth=5,
    learning_rate=0.1
)
model.fit(X_train, y_train)

# Оценка
preds = model.predict(X_test)
print(f"MAE: {mean_absolute_error(y_test, preds):.2f}")
print(f"RMSE: {np.sqrt(mean_squared_error(y_test, preds)):.2f}")
print(f"R²: {r2_score(y_test, preds):.2f}")

from xgboost import plot_importance
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6))
plot_importance(model)
plt.title('Важность признаков для прогноза приема')
plt.show()

# Загрузка данных плей-офф
playoff_query = """
SELECT * 
FROM [ml_mart].[fact_MathReportByPlayersRich] 
WHERE [FolderName] NOT LIKE '%Тур%'
ORDER BY DateTime, PlayerID
"""
playoff_df = pd.read_sql(playoff_query, engine)
playoff_df = playoff_df[playoff_df['TotalReceptions'] >= 4].copy()

# Применяем те же преобразования
playoff_df['IsHome'] = playoff_df['TeamID'] == playoff_df['HostTeamID']
playoff_df['DaysSinceLastGame'] = playoff_df.groupby('PlayerID')['DateTime'].diff().dt.days
playoff_df['MatchNumInSeason'] = playoff_df.groupby(['SeasonID', 'PlayerID']).cumcount() + 1

for stat in player_stats:
    playoff_df[f'RollingAvg_{stat}'] = playoff_df.groupby('PlayerID')[stat].transform(
        lambda x: x.expanding().mean()
    )

playoff_df = pd.merge(playoff_df, opponent_serve_stats, on=['OpponentTeamName', 'DateTime'], how='left')
playoff_df = pd.merge(playoff_df, historical_reception, on=['PlayerID', 'OpponentTeamName'], how='left')

# Предсказание
X_playoff = playoff_df[features].select_dtypes(include=['number'])
y_playoff = playoff_df[target]

playoff_preds = model.predict(X_playoff)
print("\nРезультаты на данных плей-офф:")
print(f"MAE: {mean_absolute_error(y_playoff, playoff_preds):.2f}")
print(f"RMSE: {np.sqrt(mean_squared_error(y_playoff, playoff_preds)):.2f}")
print(f"R²: {r2_score(y_playoff, playoff_preds):.2f}")

# График реальных vs предсказанных значений
plt.figure(figsize=(10, 6))
plt.scatter(y_playoff, playoff_preds, alpha=0.5)
plt.plot([0, 100], [0, 100], 'r--')
plt.xlabel('Реальный процент позитивного приема')
plt.ylabel('Предсказанный процент')
plt.title('Качество предсказаний на данных плей-офф')
plt.grid()
plt.show()

# Топ-10 игроков по количеству приемов
top_receivers = playoff_df.groupby('PlayerName').agg({
    'TotalReceptions': 'sum',
    'PerfectReceptionPercent': 'mean',
    'PerfectReceptionPercent': 'mean'
}).sort_values('TotalReceptions', ascending=False).head(10)

print("\nТоп-10 игроков по приему в плей-офф:")
print(top_receivers)