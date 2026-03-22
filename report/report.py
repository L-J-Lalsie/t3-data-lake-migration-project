from datetime import datetime, timedelta
import awswrangler as wr
import boto3


def get_yesterday_data():
    """Query yesterday's transactions from Athena."""

    yesterday = datetime.now() - timedelta(days=1)

    sql = f"""
        SELECT *
        FROM t3_data
        WHERE year = '{yesterday.year}'
        AND month = '{yesterday.month}'
        AND day = '{yesterday.day}'
    """

    df = wr.athena.read_sql_query(
        sql=sql,
        database="c22_lance_t3_database",
        s3_output="s3://c22-lance-s3-bucket/athena-results/"
    )

    return df


def calculate_metrics(df):
    """Calculate overall and per-truck metrics."""

    overall_metrics = {
        # convert from pence to pounds
        "total_revenue": f"{df['total'].sum() / 100:.2f}",
        # convert from pence to pounds
        "average_transaction": f"{df['total'].mean() / 100:.2f}",
        "transaction_count": len(df)
    }

    truck_metrics = (
        df.groupby(["truck_id", "truck_name"])
        .agg(
            total_revenue=("total", "sum"),
            average_transaction=("total", "mean"),
            transaction_count=("transaction_id", "count")
        )
        .reset_index()
    )

    truck_metrics["total_revenue"] = (
        truck_metrics["total_revenue"] / 100).round(2)

    truck_metrics["average_transaction"] = (
        truck_metrics["average_transaction"] / 100).round(2)

    return overall_metrics, truck_metrics


def generate_html_report(overall, truck_metrics):
    """Generate an HTML report."""

    truck_table = truck_metrics.to_html(index=False)

    html = f"""
    <html>
    <head>
        <title>T3 Daily Sales Report</title>
        <style>
            body {{ font-family: Arial; margin: 40px; }}
            table {{ border-collapse: collapse; width: 80%; }}
            th, td {{ border: 1px solid #ddd; padding: 8px; }}
            th {{ background-color: #f4f4f4; }}
        </style>
    </head>
    <body>

    <h1>T3 Daily Sales Report</h1>

    <h2>Overall Metrics</h2>
    <ul>
        <li><strong>Total Revenue:</strong> £{overall['total_revenue']}</li>
        <li><strong>Average Transaction:</strong> £{overall['average_transaction']}</li>
        <li><strong>Total Transactions:</strong> {overall['transaction_count']}</li>
    </ul>

    <h2>Per Truck Metrics</h2>
    {truck_table}

    </body>
    </html>
    """

    return html


def handler(event, context):

    df = get_yesterday_data()
    today = datetime.now().strftime("%Y-%m-%d")

    if df.empty:
        print("No transactions found for yesterday.")
        return

    overall, truck_metrics = calculate_metrics(df)

    html = generate_html_report(overall, truck_metrics)

    s3 = boto3.client('s3')
    s3.put_object(
        Bucket="c22-lance-s3-bucket",
        Key=f"reports/daily_report_{today}.html",
        Body=html,
        ContentType="text/html"
    )

    return {"html": html}


if __name__ == "__main__":
    handler({}, None)
