# EV Charging Network Utilization & Profitability Analytics

## Project Overview

This project analyzes the operational performance, infrastructure utilization, and financial sustainability of an EV charging network. The goal is to identify revenue drivers, operational inefficiencies, and profitability challenges using data analytics.

The analysis integrates data cleaning (Python), relational modeling and KPI computation (SQL), and will be extended with interactive dashboards in Power BI.

---

## Business Problem

As EV adoption increases, charging infrastructure operators must ensure that charging stations are profitable, reliable, and optimally utilized.

Key questions addressed in this project:

* Which charging stations generate the most revenue?
* Are chargers being utilized efficiently?
* Which stations operate at a profit or loss?
* When does charging demand peak?
* How does EV adoption influence charging revenue?

---

## Tech Stack

Python

* Pandas
* Data cleaning and preprocessing

SQL (MySQL)

* Database schema design
* KPI computation
* Operational analytics

Power BI *(planned)*

* Dashboard visualization
* Business insights

---

## Project Workflow

Raw Data
→ Python Data Cleaning
→ SQL Data Modeling
→ KPI Calculation
→ Power BI Dashboard

---

## Database Schema

Tables used in the analysis:

* stations
* charging_sessions
* charger_units
* electricity_costs
* maintenance_logs
* city_demo
* tariff_plan
* customers

These tables capture infrastructure data, charging transactions, operational costs, maintenance records, and market demographics.

---

## Key Performance Indicators (KPIs)

### Revenue Analytics

* Revenue per Station
* Revenue per Charger
* Average Revenue per Session
* Revenue by City
* Revenue by Charger Type

### Demand Patterns

* Peak Hour Charging Demand
* Sessions per Charger

### Infrastructure Efficiency

* Charger Utilization Rate
* Downtime Percentage

### Cost & Profitability

* Electricity Cost per Station
* Maintenance Cost per Station
* Gross Margin per Station

### Strategic Insights

* Tariff Pricing Efficiency
* EV Adoption vs Charging Revenue

---

## Key Insights (Example Findings)

* Charging demand peaks during evening hours, indicating residential charging behavior.
* Some stations operate at negative gross margins due to high electricity costs and low utilization.
* Fast chargers generate significantly higher revenue compared to standard chargers.
* Cities with higher EV adoption generally show higher charging revenue, though infrastructure distribution varies.

---

## Repository Structure

EV-Charging-Network-Analytics
│
├── data/
│   ├── stations.csv
│   ├── charger_units.csv
│   ├── charging_sessions.csv
│   ├── electricity_costs.csv
│   ├── maintenance_logs.csv
│   └── city_demo.csv
│
├── python/
│   └── data_cleaning.ipynb
│
├── sql/
│   └── ev_network_analysis.sql
│
├── dashboard/
│   └── (Power BI dashboard - coming soon)
│
└── README.md

---

## Future Improvements

* Build an interactive Power BI dashboard for operational monitoring.
* Add predictive analytics for demand forecasting.
* Analyze customer behavior using the customers table.

---

## Author

Ishika Shandilya
