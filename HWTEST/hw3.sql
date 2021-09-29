CREATE SCHEMA firstdb;
USE firstdb;
CREATE TABLE birdstrikes 
(id INTEGER NOT NULL,
aircraft VARCHAR(32),
flight_date DATE NOT NULL,
damage VARCHAR(16) NOT NULL,
airline VARCHAR(255) NOT NULL,
state VARCHAR(255),
phase_of_flight VARCHAR(32),
reported_date DATE,
bird_size VARCHAR(16),
cost INTEGER NOT NULL,
speed INTEGER,PRIMARY KEY(id));

SHOW VARIABLES LIKE "secure_file_priv";
SHOW VARIABLES LIKE "local_infile";
set global local_infile='on';

LOAD DATA INFILE '/tmp/birdstrikes_small.csv'
INTO TABLE birdstrikes 
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, aircraft, flight_date, damage, airline, state, phase_of_flight, @v_reported_date, bird_size, cost, @v_speed)
SET
reported_date = nullif(@v_reported_date, ''),
speed = nullif(@v_speed, '');
#EXERCISE1
SELECT aircraft, airline, speed, 
    if (speed<100 or speed is null,'low speed','high speed') as speed_category
    from birdstrikes
    order by speed_category
    
  ## if (condition,'true','false')
  
SELECT COUNT(*) FROM birdstrikes;
SELECT COUNT(reported_date) FROM birdstrikes;
SELECT DISTINCT state FROM birdstrikes;
SELECT COUNT(DISTINCT state) FROM birdstrikes;

#EXERCISE2
SELECT count(distinct  aircraft) from birdstrikes;

SELECT SUM(cost) FROM birdstrikes;
SELECT (AVG(speed)*1.852) as avg_kmh FROM birdstrikes;
SELECT DATEDIFF(MAX(reported_date),MIN(reported_date)) from birdstrikes;

#exercise3
SELECT min(speed) aircraft from birdstrikes where aircraft like 'H%';

SELECT max(speed), aircraft FROM birdstrikes GROUP BY aircraft;
SELECT state, aircraft, SUM(cost) AS sum FROM birdstrikes WHERE state !='' GROUP BY state, aircraft ORDER BY sum DESC;
#exercise4
select phase_of_flight, count(*) as count from birdstrikes group by phase_of_flight order by count limit 1;

#exercise5
select phase_of_flight, round(avg(cost)) as avg_cost from birdstrikes group by phase_of_flight order by avg_cost desc limit 1 ;

#exercise6
SELECT AVG(speed) AS avg_speed,state FROM birdstrikes group by state having length(state)<5 and state!='' order by avg_speed desc limit 1;


   
        