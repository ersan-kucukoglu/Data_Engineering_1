#exercise1
SELECT aircraft, airline, speed, 
    if (speed<100 or speed is null,'low speed','high speed') as speed_category
    from birdstrikes
    order by speed_category
#exercise2
select count(distinct  aircraft) from birdstrikes;
	#answer=3
#exercise3
select min(speed) aircraft from birdstrikes where aircraft like 'H%';
	#answer=9
#exercise4
select phase_of_flight, count(*) as count from birdstrikes group by phase_of_flight order by count limit 1;
	#answer=taxi
#exercise5
select phase_of_flight, round(avg(cost)) as avg_cost from birdstrikes group by phase_of_flight order by avg_cost desc limit 1 ;
	#answer=climb54673
#exercise6
SELECT AVG(speed) AS avg_speed,state FROM birdstrikes group by state having length(state)<5 and state!='' order by avg_speed desc limit 1;
	#answer=2862.5000
