from pathlib import Path
import pandas as pd

out_root = Path("parquet_files")
out_root.mkdir(parents=True, exist_ok=True)

joined_df = pd.read_csv('../local_save_data/joined_data.csv')

# ensure datetime and helper columns exist
joined_df["at"] = pd.to_datetime(joined_df["at"])
joined_df["year"] = joined_df["at"].dt.year
joined_df["month"] = joined_df["at"].dt.month
joined_df["day"] = joined_df["at"].dt.day

# write one parquet file per day
for (y, m, d), grp in joined_df.groupby(["year", "month", "day"]):
    dirpath = out_root / f"year={y}" / f"month={m:02d}" / f"day={d:02d}"
    dirpath.mkdir(parents=True, exist_ok=True)
    file_path = dirpath / "data.parquet"
    # drop helper cols if you don't want them inside the file
    grp_to_write = grp.drop(columns=["year", "month", "day"])
    grp_to_write.to_parquet(file_path, engine="pyarrow",
                            compression="snappy", index=False)
