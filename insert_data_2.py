from threading import Timer

import pandas
import time

from airflow import DAG
from datetime import datetime
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.hooks.postgres_hook import PostgresHook
from sqlalchemy import create_engine


def insert_data(table_name):
    sql_engine = create_engine('postgresql+psycopg2://airflow:airflow@host.docker.internal:5433/postgres', echo=False)
    sql_engine_logs = create_engine('postgresql+psycopg2://logs:111@host.docker.internal:5433/postgres', echo=False)

    def log_end():
        end_log = f"INSERT INTO logs.logs_information (data_time,message) VALUES('{datetime.today().strftime('%Y-%m-%d %H:%M:%S.000')}','end load to {table_name}')"
        sql_engine_logs.execute(end_log)

    print("pandas ver = " + pandas.__version__)
    df = pandas.read_csv(f"/opt/airflow/dags/{table_name}.csv", delimiter=";")
    # postgres_hook = PostgresHook("postgres_db")
    # engine = postgres_hook.get_sqlalchemy_engine()

    # drop = f"DROP TABLE ds.{table_name}"
    # sql_engine.execute(drop)
    connection = sql_engine.connect()
    # connection_logs = sql_engine_logs.connect()
    start_log = f"INSERT INTO logs.logs_information (data_time,message) VALUES('{datetime.today().strftime('%Y-%m-%d %H:%M:%S.000')}','start load to {table_name}')"
    sql_engine_logs.execute(start_log)
    df.to_sql(table_name, con=connection, schema="ds", if_exists="replace", index=False)
    t = Timer(5.0, log_end)
    t.start()
    time.sleep(5)


default_args = {
    "owner": "airflow",
    "start_date": datetime(2024, 7, 19),
    "retries": 2
}

with DAG(
        "insert_data_new",
        default_args=default_args,
        description="Загрузка данных в stage",
        catchup=False,
        schedule="0 0 * * *"
) as dag:
    start = DummyOperator(
        task_id="start"
    )

    ft_balance_f = PythonOperator(
        task_id="ft_balance_f",
        python_callable=insert_data,
        op_kwargs={"table_name": "ft_balance_f"}
    )

    ft_posting_f = PythonOperator(
        task_id="ft_posting_f",
        python_callable=insert_data,
        op_kwargs={"table_name": "ft_posting_f"}
    )

    md_account_d = PythonOperator(
        task_id="md_account_d",
        python_callable=insert_data,
        op_kwargs={"table_name": "md_account_d"}
    )

    md_currency_d = PythonOperator(
        task_id="md_currency_d",
        python_callable=insert_data,
        op_kwargs={"table_name": "md_currency_d"}
    )

    md_exchange_rate_d = PythonOperator(
        task_id="md_exchange_rate_d",
        python_callable=insert_data,
        op_kwargs={"table_name": "md_exchange_rate_d"}
    )

    md_ledger_account_s = PythonOperator(
        task_id="md_ledger_account_s",
        python_callable=insert_data,
        op_kwargs={"table_name": "md_ledger_account_s"}
    )

    end = DummyOperator(
        task_id="end"
    )

    var = (
            start
            >> [ft_balance_f, ft_posting_f, md_account_d, md_currency_d, md_exchange_rate_d, md_ledger_account_s]
            >> end
    )
