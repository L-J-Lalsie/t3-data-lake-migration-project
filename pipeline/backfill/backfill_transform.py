import pandas as pd

T3_tables = pd.read_csv('backfill_data/backfill_data_raw.csv')

# Checks Non-numeric characters like £
T3_tables['total'] = pd.to_numeric(T3_tables['total'], errors='coerce')
T3_tables = T3_tables.dropna(subset=['total'])

# Negative values
T3_tables = T3_tables[T3_tables['total'] >= 0]

# Unrealistically large values
T3_tables = T3_tables[T3_tables['total'] < 2000]

# removes duplicates
T3_tables = T3_tables.drop_duplicates()

T3_tables.to_csv('backfill_data/backfill_data_cleaned.csv', index=False)
