
# скрипт для расчета приема и метрики по подачам
# Загрузка данных
import numpy as np
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sqlalchemy import create_engine
# Подключение к БД
engine = create_engine('mssql+pyodbc://@localhost/Volleyball_dwh?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server')

from sqlalchemy import create_engine
query = """
SELECT * 
FROM [ml_mart].[fact_MathReportByPlayersRich] 
WHERE [FolderName] LIKE '%Тур%'
ORDER BY DateTime, PlayerID
"""
df = pd.read_sql(query, engine)

# Фильтрация игроков с подачами
df = df[df['TotalServes'] > 0].copy()

# Расчет статистики приема соперников
opponent_reception_stats = df.groupby(['OpponentTeamName', 'DateTime']).agg({
    'ReceptionErrors': 'mean',
    'PerfectReceptionPercent': 'mean',
    'ExcellentReceptionPercent': 'mean',
    'TotalReceptions': 'sum'
}).reset_index()
opponent_reception_stats = opponent_reception_stats.add_prefix('Opponent_')

df = pd.merge(df, opponent_reception_stats, 
             left_on=['OpponentTeamName', 'DateTime'],
             right_on=['Opponent_OpponentTeamName', 'Opponent_DateTime'],
             how='left').drop(['Opponent_OpponentTeamName', 'Opponent_DateTime'], axis=1)

# Дополнительные признаки
df['IsHome'] = df['TeamID'] == df['HostTeamID']
df['ServeEff'] = (df['ServePoints'] - df['ServeErrors']) / df['TotalServes'].replace(0, 1)
df['DaysSinceLastGame'] = df.groupby('PlayerID')['DateTime'].diff().dt.days

features = [
    'PlayerHeight',
    'IsHome',
    'DaysSinceLastGame',
    'Opponent_PerfectReceptionPercent',
    'Opponent_ExcellentReceptionPercent',
    'Opponent_ReceptionErrors',
    'Opponent_TotalReceptions',
    'RollingAvg_TotalServes',  # Скользящее среднее по 3 последним играм
    'RollingAvg_ServeEff',     # Эффективность подачи
    'Historical_TotalServes'   # Историческое среднее против этого соперника
]

target = 'TotalServes'

# Расчет скользящих статистик
df['RollingAvg_TotalServes'] = df.groupby('PlayerID')['TotalServes'].transform(
    lambda x: x.rolling(3, min_periods=1).mean()
)
df['RollingAvg_ServeEff'] = df.groupby('PlayerID')['ServeEff'].transform(
    lambda x: x.rolling(3, min_periods=1).mean()
)

# Исторические данные против соперников
historical_serve = df.groupby(['PlayerID', 'OpponentTeamName']).agg({
    'TotalServes': 'mean'
}).reset_index().rename(columns={'TotalServes': 'Historical_TotalServes'})

df = pd.merge(df, historical_serve, on=['PlayerID', 'OpponentTeamName'], how='left')

from sklearn.ensemble import RandomForestRegressor

X = df[features].select_dtypes(include=['number'])
y = df[target]

# Разделение с сохранением временного порядка
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, shuffle=False)

# Используем RandomForest для лучшей интерпретируемости
model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Оценка
preds = model.predict(X_test)
print(f"MAE: {mean_absolute_error(y_test, preds):.2f}")
print(f"RMSE: {np.sqrt(mean_squared_error(y_test, preds)):.2f}")
print(f"R²: {r2_score(y_test, preds):.2f}")

# Загрузка данных плей-офф
playoff_query = """
SELECT * 
FROM [ml_mart].[fact_MathReportByPlayersRich] 
WHERE [FolderName] NOT LIKE '%Тур%'
ORDER BY DateTime, PlayerID
"""
playoff_df = pd.read_sql(playoff_query, engine)

# Применяем те же преобразования
playoff_df = playoff_df[playoff_df['TotalServes'] > 0].copy()
playoff_df = pd.merge(playoff_df, opponent_reception_stats,
                     left_on=['OpponentTeamName', 'DateTime'],
                     right_on=['Opponent_OpponentTeamName', 'Opponent_DateTime'],
                     how='left').drop(['Opponent_OpponentTeamName', 'Opponent_DateTime'], axis=1)

playoff_df['IsHome'] = playoff_df['TeamID'] == playoff_df['HostTeamID']
playoff_df['ServeEff'] = (playoff_df['ServePoints'] - playoff_df['ServeErrors']) / playoff_df['TotalServes'].replace(0, 1)
playoff_df['DaysSinceLastGame'] = playoff_df.groupby('PlayerID')['DateTime'].diff().dt.days

# Расчет скользящих статистик для плей-офф
for player_id in playoff_df['PlayerID'].unique():
    player_mask = df['PlayerID'] == player_id
    if player_mask.any():
        last_values = df[player_mask].iloc[-3:][['TotalServes', 'ServeEff']].mean()
        playoff_df.loc[playoff_df['PlayerID'] == player_id, 'RollingAvg_TotalServes'] = last_values['TotalServes']
        playoff_df.loc[playoff_df['PlayerID'] == player_id, 'RollingAvg_ServeEff'] = last_values['ServeEff']

playoff_df = pd.merge(playoff_df, historical_serve, on=['PlayerID', 'OpponentTeamName'], how='left')

# Прогноз для игрока 171
player_171 = playoff_df[playoff_df['PlayerID'] == 171].copy()
X_player = player_171[features].select_dtypes(include=['number'])
player_171['Predicted_TotalServes'] = model.predict(X_player)

# Визуализация
plt.figure(figsize=(12, 6))
plt.plot(player_171['DateTime'], player_171['TotalServes'],
         label='Реальные подачи', marker='o')
plt.plot(player_171['DateTime'], player_171['Predicted_TotalServes'],
         label='Прогнозируемые подачи', marker='x')
plt.title(f'Прогноз количества подач для игрока ID 171 ({player_171["PlayerName"].iloc[0]})')
plt.xlabel('Дата матча')
plt.ylabel('Количество подач')
plt.legend()
plt.grid()
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()





# Топ-10 игроков по количеству подач в плей-офф
top_servers = playoff_df.groupby(['PlayerID', 'PlayerName']).agg({
    'TotalServes': 'sum',
    'ServePoints': 'sum',
    'ServeErrors': 'sum'
}).sort_values('TotalServes', ascending=False).head(10)

top_servers['ServeEff'] = (top_servers['ServePoints'] - top_servers['ServeErrors']) / top_servers['TotalServes']
print("Топ-10 игроков по подачам в плей-офф:")
print(top_servers)
# Подготовка данных
top_servers = top_servers.reset_index()
top_servers['Player'] = top_servers['PlayerName'].apply(lambda x: x.split()[-1])  # Берем только фамилии

# Создаем фигуру
plt.figure(figsize=(14, 7))

# График эффективности
ax1 = plt.subplot(1, 2, 1)
sns.barplot(x='ServeEff', y='Player', data=top_servers, palette='RdYlGn', ax=ax1)
ax1.set_title('Эффективность подач топ-игроков в плей-офф')
ax1.set_xlabel('Коэффициент эффективности (очки - ошибки)/все подачи')
ax1.set_ylabel('Игрок')
ax1.axvline(0, color='black', linestyle='--')  # Нулевая линия

# Добавляем аннотации
for p in ax1.patches:
    ax1.annotate(f"{p.get_width():.2f}",
                (p.get_width(), p.get_y() + p.get_height()/2),
                ha='left', va='center', xytext=(5, 0), textcoords='offset points')

# График соотношения очков и ошибок
ax2 = plt.subplot(1, 2, 2)
top_servers['SuccessRate'] = top_servers['ServePoints'] / top_servers['TotalServes']
top_servers['ErrorRate'] = top_servers['ServeErrors'] / top_servers['TotalServes']
top_servers[['Player', 'SuccessRate', 'ErrorRate']].set_index('Player').plot(
    kind='barh', stacked=True, color=['green', 'red'], ax=ax2)
ax2.set_title('Соотношение результативных подач и ошибок')
ax2.set_xlabel('Доля от общего числа подач')
ax2.legend(['Успешные подачи', 'Ошибки'], loc='lower right')

plt.tight_layout()
plt.show()
# Получаем данные топ-игроков
top_player_ids = top_servers['PlayerID'].tolist()
top_players_data = playoff_df[playoff_df['PlayerID'].isin(top_player_ids)]

# Группируем по игрокам и матчам
player_match_stats = top_players_data.groupby(['PlayerName', 'DateTime']).agg({
    'TotalServes': 'sum',
    'ServePoints': 'sum',
    'ServeErrors': 'sum'
}).reset_index()

# Создаем график
plt.figure(figsize=(15, 8))

# Используем swarmplot для отображения распределения
sns.swarmplot(
    x='TotalServes',
    y='PlayerName',
    data=player_match_stats,
    size=8,
    palette='viridis'
)

# Добавляем средние значения
mean_values = player_match_stats.groupby('PlayerName')['TotalServes'].mean().reset_index()
sns.pointplot(
    x='TotalServes',
    y='PlayerName',
    data=mean_values,
    color='black',
    markers='d',
    scale=0.7,
    linestyles=''
)

plt.title('Распределение количества подач за матч для топ-игроков\n(ромбики - средние значения)', pad=20)
plt.xlabel('Количество подач за матч')
plt.ylabel('Игрок')
plt.grid(axis='x', alpha=0.3)
plt.axvline(player_match_stats['TotalServes'].mean(), color='red', linestyle='--', label='Среднее по всем')
plt.legend()

plt.tight_layout()
plt.show()

