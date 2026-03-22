from dotenv import dotenv_values
import os
import streamlit as st
import pandas as pd
import plotly.express as px
import awswrangler as wr

st.set_page_config(page_title="T3 Analytics Dashboard", layout="wide")

st.title("🚚 T3 Truck Analytics Dashboard")

creds = dotenv_values(".env")
os.environ['AWS_ACCESS_KEY_ID'] = creds.get('AWS_ACCESS_KEY_ID')
os.environ['AWS_SECRET_ACCESS_KEY'] = creds.get('AWS_SECRET_ACCESS_KEY')
os.environ['AWS_DEFAULT_REGION'] = creds.get('AWS_DEFAULT_REGION')


@st.cache_data(ttl=10800)  # cache for 3 hours
def load_data():
    return wr.athena.read_sql_query(
        sql="SELECT * FROM t3_data",
        database="c22_lance_t3_database",
        s3_output="s3://c22-lance-s3-bucket/athena-results/"
    )


df = load_data()

with st.sidebar:
    selected_trucks = st.multiselect(
        "Filter by Truck",
        options=df['truck_name'].unique(),
        default=df['truck_name'].unique()
    )

    if selected_trucks:
        filtered_df = df[df['truck_name'].isin(selected_trucks)]
    else:
        filtered_df = df[0:0]  # empty dataframe


total_transactions = filtered_df['total'].count()

revenue_by_truck = filtered_df.groupby('truck_name')['total'].sum(
).reset_index().sort_values(by='total', ascending=False)
revenue_by_truck['total'] = revenue_by_truck['total'] / 100
fig = px.bar(revenue_by_truck, x='truck_name', y='total',
             title="Total Revenue by Truck", labels={'total': 'Total Revenue', 'truck_name': 'Truck Name'}, color='truck_name')

avg_transaction = filtered_df['total'].mean()

revenue_by_payment = filtered_df.groupby('payment_method')[
    'total'].sum().reset_index()
revenue_by_payment['total'] = revenue_by_payment['total'] / 100
fig2 = px.pie(revenue_by_payment, values='total', names='payment_method',
              title="Revenue Distribution by Payment Method", hole=0.4, color='payment_method')


col1, col2 = st.columns(2)

with col1:
    st.metric(label="Total Transactions", value=f"{total_transactions}")

    st.plotly_chart(fig, use_container_width=True)


with col2:
    st.metric(label="Average Transaction Value",
              value=f"£{avg_transaction/100:.2f}")

    st.plotly_chart(fig2, use_container_width=True)


transactions_over_time = filtered_df.groupby(filtered_df['at'].dt.date)[
    'total'].count().reset_index()
fig3 = px.line(transactions_over_time, x='at', y='total', title="Number of Transactions Over Time", labels={
    'at': 'Date', 'total': 'Number of Transactions'})
st.plotly_chart(fig3, use_container_width=True)
