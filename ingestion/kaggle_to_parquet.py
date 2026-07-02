import io
import os
import zipfile
import kaggle  # kaggle package auto-reads ~/.kaggle/kaggle.json
import pyarrow as pa
import pyarrow.csv as pacsv
import pyarrow.parquet as pq
 
KAGGLE_DATASET  = "mkechinov/ecommerce-behavior-data-from-multi-category-store"
DOWNLOAD_DIR    = "./kaggle_download"   # zip lands here (then we stream out of it)
PARQUET_PATH    = "data.parquet"
 
 
def download_dataset(download_dir: str) -> str:
    """Download the Kaggle dataset zip and return the path to the zip file."""
    os.makedirs(download_dir, exist_ok=True)
    print(f"[kaggle] Downloading dataset: {KAGGLE_DATASET}")
 
    kaggle.api.authenticate()
    kaggle.api.dataset_download_files(
        KAGGLE_DATASET,
        path=download_dir,
        unzip=False,   # keep as zip so we can stream individual CSVs
        quiet=False,
    )
 
    # Kaggle names the zip after the dataset slug
    zip_name = KAGGLE_DATASET.split("/")[-1] + ".zip"
    zip_path = os.path.join(download_dir, zip_name)
 
    if not os.path.exists(zip_path):
        # Fallback: find any .zip in the folder
        zips = [f for f in os.listdir(download_dir) if f.endswith(".zip")]
        if not zips:
            raise FileNotFoundError(f"No zip file found in {download_dir}")
        zip_path = os.path.join(download_dir, zips[0])
 
    print(f"[kaggle] Downloaded → {zip_path}")
    return zip_path
 
 
def stream_zip_to_parquet(zip_path: str, parquet_path: str, target_csv: str | None = None) -> None:
    """
    Open each CSV inside the zip and stream it into a single Parquet file.
    If target_csv is specified, only that file is processed.
    Otherwise, all CSVs are processed in sorted order   
    """
    writer    = None
    row_count = 0
    schema    = None

    with zipfile.ZipFile(zip_path, "r") as zf:
        if target_csv:
            if target_csv not in zf.namelist():
                raise FileNotFoundError(f"{target_csv!r} not found in {zip_path}. Available: {zf.namelist()}")
            csv_files = [target_csv]
        else:
            csv_files = sorted(
                name for name in zf.namelist()
                if name.endswith(".csv") and not name.startswith("__MACOSX")
            )

        if not csv_files:
            raise ValueError(f"No CSV files found inside {zip_path}")

        print(f"[zip] Processing {len(csv_files)} CSV file(s): {csv_files}")

        for csv_name in csv_files:
            print(f"\n[stream] Processing: {csv_name}")

            with zf.open(csv_name) as raw_file:
                buffered = io.BufferedReader(raw_file, buffer_size=8 * 1024 * 1024)

                read_options  = pacsv.ReadOptions(block_size=64 * 1024 * 1024)
                parse_options = pacsv.ParseOptions()
                convert_options = pacsv.ConvertOptions(
                    column_types={
                        "event_type":    pa.string(),
                        "product_id":    pa.string(),
                        "category_id":  pa.string(),
                        "category_code": pa.string(),
                        "brand":        pa.string(),
                        "price":        pa.float64(),
                        "user_id":      pa.string(),
                        "user_session": pa.string(),
                    },
                    timestamp_parsers=["%Y-%m-%d %H:%M:%S UTC", "%Y-%m-%d %H:%M:%S"],
                )

                reader = pacsv.open_csv(
                    buffered,
                    read_options=read_options,
                    parse_options=parse_options,
                    convert_options=convert_options,
                )

                for batch in reader:
                    table = pa.Table.from_batches([batch])

                    if writer is None:
                        schema = table.schema
                        writer = pq.ParquetWriter(
                            parquet_path,
                            schema,
                            compression="zstd",
                        )
                    else:
                        table = table.cast(schema)

                    writer.write_table(table)
                    row_count += len(batch)
                    print(
                        f"\r  [convert] {row_count:,} rows written...",
                        end="", flush=True,
                    )

    if writer:
        writer.close()

    print(f"\n[done] {row_count:,} total rows → {parquet_path}")
 
 
def main() -> None:
    zip_path = download_dataset(DOWNLOAD_DIR)
    stream_zip_to_parquet(zip_path, PARQUET_PATH, target_csv="2019-Oct.csv")
 
    # Remove the zip to save disk space
    os.remove(zip_path)
    print(f"[cleanup] Removed {zip_path}")
 
 
if __name__ == "__main__":
    main()