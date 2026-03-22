-- finds the most profitable truck. This can be used to identify which trucks are performing well and which may need additional support or resources.
select
    truck_name,
    SUM(total) as total_revenue
from
    t3_data
group by
    truck_name;

-- finds the revenue by payment method. This can be used to identify which payment methods are most popular and ensure that the necessary infrastructure is in place to support them (e.g. card readers, mobile payment options).
select
    payment_method,
    SUM(total) as total_revenue
from
    t3_data
group by
    payment_method;

-- finds the number of transactions by day. This can be used to identify busy days and plan trucks accordingly. Although, this is not useful because the data only contains 1 week of data, which is not enough to identify trends or patterns in customer behavior. A longer time frame would be needed to make meaningful conclusions about busy days and plan trucks accordingly.
select
    day,
    COUNT(*) as num_transactions
from
    t3_data
group by
    day
ORDER BY
    day ASC;

-- finds the average transaction total by truck. This can be used to identify which trucks are generating higher average sales and may indicate that they are offering more popular or higher-priced items.
select
    truck_name,
    AVG(total) as avg_transaction_total
from
    t3_data
group by
    truck_name
ORDER BY
    avg_transaction_total DESC;
