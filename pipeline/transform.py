import pandas as pd

T3_tables = pd.read_csv('data/3_hour_data_raw.csv')

# print(T3_tables.head())
# print(T3_tables.describe())

# Checks Non-numeric characters like £
T3_tables['total'] = pd.to_numeric(T3_tables['total'], errors='coerce')
T3_tables = T3_tables.dropna(subset=['total'])

# Negative values
T3_tables = T3_tables[T3_tables['total'] >= 0]

# Unrealistically large values
T3_tables = T3_tables[T3_tables['total'] < 2000]

# removes duplicates
T3_tables = T3_tables.drop_duplicates()

# print(T3_tables.head())
# print(T3_tables.describe())

T3_tables.to_csv('data/3_hour_data_cleaned.csv', index=False)
