CREATE DATABASE ev_network;
USE ev_network;

CREATE TABLE stations (
    station_id INT PRIMARY KEY,
    city VARCHAR(50),
    area VARCHAR(50),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    installation_date DATE,
    number_of_chargers INT,
    charger_type VARCHAR(20),
    power_capacity_kw INT,
    rental_cost_per_month DECIMAL(12,2),
    maintenance_cost_per_month DECIMAL(12,2));
    
    CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    vehicle_type VARCHAR(20),
    registration_city VARCHAR(50),
    membership_type VARCHAR(30),
    join_date DATE);
    
    CREATE TABLE charger_units (
    charger_id INT PRIMARY KEY,
    station_id INT,
    charger_type VARCHAR(20),
    max_power_kw INT,
    installation_date DATE,
    operational_status VARCHAR(30),
    FOREIGN KEY (station_id) REFERENCES stations(station_id));
    
    CREATE TABLE tariff_plan (
    tariff_id INT PRIMARY KEY,
    charger_type VARCHAR(20),
    time_band VARCHAR(20),
    price_per_kwh DECIMAL(6,2),
    effective_from DATE,
    effective_to DATE);
    
    CREATE TABLE city_demo (
    city VARCHAR(50) PRIMARY KEY,
    population INT,
    ev_registration_count INT,
    avg_income DECIMAL(12,2),
    commercial_activity_index DECIMAL(4,2));
    
    CREATE TABLE charging_sessions (
    session_id INT PRIMARY KEY,
    station_id INT,
    customer_id INT,
    start_time DATETIME,
    end_time DATETIME,
    energy_consumed_kwh DECIMAL(10,2),
    charging_duration_minutes INT,
    price_per_kwh DECIMAL(6,2),
    total_revenue DECIMAL(10,2),
    payment_mode VARCHAR(20),
    FOREIGN KEY (station_id) REFERENCES stations(station_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id));
    
    CREATE TABLE maintenance_logs (
    log_id INT PRIMARY KEY,
    station_id INT,
    downtime_start DATETIME,
    downtime_end DATETIME,
    issue_type VARCHAR(50),
    repair_cost DECIMAL(12,2),
    FOREIGN KEY (station_id) REFERENCES stations(station_id));
    
    CREATE TABLE electricity_costs (
    station_id INT,
    month DATE,
    electricity_cost_per_kwh DECIMAL(6,2),
    total_energy_supplied_kwh DECIMAL(12,2),
    total_energy_cost DECIMAL(12,2),
    FOREIGN KEY (station_id) REFERENCES stations(station_id));
    ALTER TABLE electricity_costs
    ADD PRIMARY KEY (station_id, month);
    
select count(*) from customers;
select count(*) from stations;
select count(*) from city_demo;
select count(*) from charging_sessions;
select count(*) from charger_units;
select count(*) from electricity_costs;
select count(*) from tariff_plan;
select count(*) from maintenance_logs;

ALTER TABLE charging_sessions
ADD COLUMN charger_id INT;

ALTER TABLE charging_sessions
ADD CONSTRAINT fk_charger
FOREIGN KEY (charger_id)
REFERENCES charger_units(charger_id);

UPDATE charging_sessions cs
SET charger_id = (SELECT cu.charger_id FROM charger_units cu
WHERE cu.station_id = cs.station_id
ORDER BY RAND() LIMIT 1);

CREATE INDEX idx_charger_id ON charging_sessions(charger_id);

select * from charging_sessions;
## Total Revenue by Station

SELECT station_id, SUM(total_revenue) AS total_revenue
FROM charging_sessions
GROUP BY station_id ORDER BY total_revenue DESC;  

## Revenue per Station

SELECT s.station_id, s.city,
COUNT(cs.session_id) AS total_sessions,
SUM(cs.total_revenue) AS total_revenue
FROM charging_sessions cs
JOIN stations s ON cs.station_id = s.station_id
GROUP BY s.station_id, s.city
ORDER BY total_revenue DESC; 

## Revenue per Charger

SELECT cu.charger_id, cu.station_id,
SUM(cs.total_revenue) AS revenue_per_charger
FROM charging_sessions cs JOIN charger_units cu ON cs.charger_id = cu.charger_id
GROUP BY cu.charger_id, cu.station_id
ORDER BY revenue_per_charger DESC;

## Station-Level Average Revenue per Session

with cte1 as
(SELECT s.station_id, s.city,
COUNT(cs.session_id) AS total_sessions,
SUM(cs.total_revenue) AS total_revenue
from charging_sessions cs JOIN stations s 
ON cs.station_id = s.station_id GROUP BY s.station_id, s.city),
cte2 as
(SELECT *, ROUND(total_revenue/total_sessions, 2) AS avg_revenue_per_session
from cte1
ORDER BY avg_revenue_per_session DESC)
select * from cte2;

## Utilization Rate = Charging Time / Available Time

with cte1 as
(select s.station_id, datediff(MAX(cs.start_time),MIN(cs.start_time)) as Total_Days,
COUNT(DISTINCT cu.charger_id) AS total_chargers,
SUM(cs.charging_duration_minutes) AS total_charging_minutes
FROM stations s JOIN charger_units cu ON s.station_id = cu.station_id
JOIN charging_sessions cs ON s.station_id = cs.station_id
GROUP BY s.station_id),
cte2 as
(select *, (total_chargers * Total_Days * 24 * 60) as Available_time
from cte1),
cte3 as 
(select *, Round((total_charging_minutes/Available_time)*100,2) as Utilization_per
from cte2 order by Utilization_per desc)
select * from cte3;

## Peak hour Analysis

SELECT HOUR(start_time) AS hour_of_day,
COUNT(*) AS total_sessions FROM charging_sessions 
GROUP BY hour_of_day ORDER BY hour_of_day;

## Sessions per Charger

SELECT cu.charger_id, cu.station_id, cu.charger_type,
COUNT(cs.session_id) AS sessions_per_charger
FROM charging_sessions cs JOIN charger_units cu 
ON cs.charger_id = cu.charger_id
GROUP BY cu.charger_id, cu.station_id, cu.charger_type
ORDER BY sessions_per_charger DESC;

## Revenue by Charger Type

SELECT cu.charger_type, 
SUM(cs.total_revenue) as revenue_by_charger_type
from charger_units cu join charging_sessions cs
on cs.charger_id = cu.charger_id
group by cu.charger_type
order by revenue_by_charger_type desc;

## Revenue by City

SELECT s.city,
SUM(cs.total_revenue) as revenue_by_city
from stations s join charging_sessions cs
on cs.station_id = s.station_id
group by s.city
order by revenue_by_city desc;

## Electricity Cost per Station

SELECT ec.station_id, s.city,
SUM(ec.total_energy_cost) as elec_cost_per_station
from stations s join electricity_costs ec 
on ec.station_id = s.station_id group by ec.station_id, s.city 
order by elec_cost_per_station desc;

## Maintenance Cost per Station

SELECT s.station_id, s.city,
SUM(ml.repair_cost) as maint_cost_per_station
from maintenance_logs ml join stations s on ml.station_id = s.station_id
group by s.station_id, s.city
order by maint_cost_per_station desc;

## Gross Margin per Station

with revenue as 
(select station_id,
SUM(total_revenue) as total_revenue
from charging_sessions group by station_id),
electricity as 
(select station_id,
SUM(total_energy_cost) as electricity_cost
from electricity_costs group by station_id),
period as 
(select timestampdiff(month, MIN(start_time), MAX(start_time)) AS months
from charging_sessions),
maintenance as 
(select station_id,
SUM(repair_cost) as repair_cost
from maintenance_logs group by station_id)
select s.station_id, s.city, r.total_revenue,
e.electricity_cost, m.repair_cost, 
s.maintenance_cost_per_month, s.rental_cost_per_month,
(r.total_revenue - IFNULL(e.electricity_cost,0)- IFNULL(m.repair_cost,0)- 
(s.maintenance_cost_per_month*p.months)- (s.rental_cost_per_month*p.months)) 
as gross_margin_per_station
from stations s
left join revenue r on s.station_id = r.station_id
left join electricity e on s.station_id = e.station_id
left join maintenance m on s.station_id = m.station_id
cross join period p
order by gross_margin_per_station desc;

## Downtime Percentage

with downtime as 
(select station_id,
SUM(timestampdiff(minute, downtime_start, downtime_end)) as total_downtime_minutes
from maintenance_logs group by station_id),
period as 
(select timestampdiff(day, MIN(start_time), MAX(start_time)) as total_days
from charging_sessions)
select d.station_id, d.total_downtime_minutes,
(p.total_days * 24 * 60) AS total_possible_minutes,
ROUND((d.total_downtime_minutes / (p.total_days * 24 * 60)) * 100,2) as downtime_percentage
from downtime d cross join period p
order by downtime_percentage desc;

## Tariff Pricing Efficiency

with tariff_match as 
(select cs.session_id, cs.station_id, cu.charger_type, cs.energy_consumed_kwh,
cs.total_revenue, tp.price_per_kwh,
row_number() over (partition by cs.session_id order by tp.effective_from desc) as rn
from charging_sessions cs
join charger_units cu on cs.charger_id = cu.charger_id
join tariff_plan tp on cu.charger_type = tp.charger_type
and cs.start_time >= tp.effective_from
and cs.start_time <= tp.effective_to)
select station_id, charger_type,
SUM(total_revenue) as actual_revenue,
SUM(energy_consumed_kwh * price_per_kwh) as expected_revenue,
SUM(total_revenue) - SUM(energy_consumed_kwh * price_per_kwh) as revenue_variance
from tariff_match where rn = 1 group by station_id, charger_type
order by revenue_variance desc;

## EV Adoption vs Charging Revenue

select cd.city, cd.ev_registration_count,
SUM(cs.total_revenue) AS city_revenue,
ROUND(SUM(cs.total_revenue) / cd.ev_registration_count,2) as revenue_per_ev
from city_demo cd
join stations s on cd.city = s.city
join charging_sessions cs on s.station_id = cs.station_id
group by cd.city, cd.ev_registration_count
order by city_revenue desc;