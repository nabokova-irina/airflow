CREATE SCHEMA AUTHORIZATION DS;
CREATE SCHEMA DS;
DROP role ds;

CREATE ROLE DS WITH LOGIN ENCRYPTED PASSWORD '111';

SELECT usename, usesuper, usecreatedb FROM pg_catalog.pg_user;
SELECT schema_name FROM information_schema.schemata;

CREATE SCHEMA IF NOT EXISTS DS AUTHORIZATION DS;

drop table DS.FT_BALANCE_F;
drop table DS.FT_POSTING_F;

create table DS.FT_BALANCE_F (
	on_date varchar(22) not null,
	account_rk numeric not null,
	currency_rk numeric,
	balance_out FLOAT,
	constraint date_account_pk primary key (on_date,account_rk)
);

create table DS.FT_POSTING_F (
	oper_date varchar(22) not null,
	credit_account_rk numeric not null,
	debet_account_rk numeric not null,
	credit_amount float,
	debet_amount FLOAT
);

create table DS.MD_ACCOUNT_D (
	data_actual_date DATE not null,
	data_actual_end_date DATE not null,
	account_rk numeric not null,
	account_number varchar(20)  not null,
	char_type varchar(1) not null,
	currency_rk numeric not null,
	currency_code varchar(3),
	constraint data_actual_account_pk primary key(data_actual_date,account_rk)
);

create table DS.MD_CURRENCY_D (
	currency_rk numeric not null,
	data_actual_date date not null,
	data_actual_end_date date,
	currency_code varchar(3),
	code_iso_char varchar(3),
	constraint currency_data_act_pk primary key(CURRENCY_RK, DATA_ACTUAL_DATE)
);

create table DS.MD_EXCHANGE_RATE_D (
	data_actual_date date not null,
	data_actual_end_date date ,
	currency_rk numeric not null,
	reduced_cource float,
	code_iso_num varchar(4),
	constraint data_act_currency_pk primary key(DATA_ACTUAL_DATE , CURRENCY_RK)
);
drop table DS.MD_EXCHANGE_RATE_D;
create table DS.MD_LEDGER_ACCOUNT_S(
chapter CHAR(1),
chapter_name varchar(16),
section_number INTEGER,
section_name varchar(22),
subsection_name varchar(21),
ledger1_account integer,
ledger1_account_name varchar(47),
ledger_account integer not null,
ledger_account_name varchar(153),
characteristic char(1),
is_resident integer,
is_reserve integer,
is_reserved integer,
is_loan integer,
is_reserved_assets integer,
is_overdue integer,
is_interest integer,
pair_account varchar(5),
start_date date not null,
end_date date,
is_rub_only integer,
min_term varchar(1),
min_term_measure varchar(1),
max_term varchar(1),
max_term_measure varchar(1),
ledger_acc_full_name_translit varchar(1),
is_revaluation varchar(1),
is_correct varchar(1),
constraint ledger_start_pk primary key(LEDGER_ACCOUNT, START_DATE)
);


CREATE SCHEMA AUTHORIZATION logs;
CREATE SCHEMA logs;
DROP role logs;

CREATE ROLE logs WITH LOGIN ENCRYPTED PASSWORD '111';

SELECT usename, usesuper, usecreatedb FROM pg_catalog.pg_user;
SELECT schema_name FROM information_schema.schemata;

CREATE SCHEMA IF NOT EXISTS logs AUTHORIZATION logs;

create table logs.logs_information (
	data_time timestamptz,
	message varchar(100)
);
