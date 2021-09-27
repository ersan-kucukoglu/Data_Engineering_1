#Exercise1
CREATE TABLE employee 
(id INTEGER NOT NULL,
employee_name varchar(255) not null, PRIMARY KEY(id));

#Exercise2
SELECT * FROM birdstrikes LIMIT 144,1;
Answer:'Tennessee'
#Exercise3
SELECT * FROM birdstrikes WHERE flight_date=(SELECT max(flight_date) FROM birdstrikes) limit 1;
Answer: '2000-04-18'
#Exercise4
select distinct cost from birdstrikes order by cost asc limit 49,1;
Answer:'86864'
#Exercise5
select state, bird_size from birdstrikes where state is not null and state !='' and bird_size is not null and bird_size !='' limit 1,1;
Answer: 'Colorado'
#Exercise6
select weekofyear(flight_date) week_,flight_date from birdstrikes where state = 'Colorado' and flight_date='not null'; 
select datediff(now(),'2000-01-01');
Answer:'7940'

