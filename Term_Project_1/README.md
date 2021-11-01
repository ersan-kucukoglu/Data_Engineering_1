# MOVIES SQL PROJECT
 In this term project for Data Engineering 1, I created schema on MySQL using the Movies Dataset which contains 614 movies between 1989 and 2019, which can be found on [data.world](https://data.world/jamesgaskin/movies).
 I am going to analyse the dataset for the digital distributor movie company, which I am supposed to show them which movies or which genre are profitable and have the highest movies such as top movies by rating, top 10 actors.
 The questions that I am going to analyse can be found below in analytics part.
 #### [DATASET](https://github.com/ersan-kucukoglu/Data_Engineering_1/tree/main/Term_Project_1/data)
The dataset can be viewed by clicking on the dataset subheading.

- movies.csv file contains the features of each movie such as movie title,rating score, budget,etc.
- actors.csv file contains some information such as actors' height,gender, country of birth, ethnicity and net worth.
- characters.csv file contains the characters from the movies in relation to the actor and movies data and contains their credit order,pay and screen time.
#### RELATIONAL SCHEMAS
- Movies: Table contains all information from movies.csv file
- Actors: Table contains listings information from the actors.csv file
- Characters: Table contains hosts information from the characters.csv file
#### RELATIONSHIP BETWEEN SCHEMAS
- Characters and movies tables are linked together by MovieID
- Characters and actors tables are linked together by ActorID



## OPERATIONAL LAYER
Creating the movie dataset, and creating movies,actors and characters tables inside the created movie schema and import data in those tables:
```
DROP SCHEMA IF EXISTS movie;
CREATE SCHEMA movie;
USE movie;
-- ----------------------------------------------------------
-- CREATING THE MOVIES TABLE
-- ----------------------------------------------------------
	DROP TABLE IF EXISTS movies;
    Create Table movies(
		MovieID int,
        Title VARCHAR(255),
        MPAA_Rating VARCHAR(255),
        Budget VARCHAR(25),
        Gross VARCHAR(25),
        Release_Date DATE,
        Genre VARCHAR(25),
        Runtime INT,
        Rating char(10),
        Rating_Count char(50),
        Summary text,
        PRIMARY KEY (MovieID)
    );
TRUNCATE movies; 
ALTER TABLE movies
MODIFY budget bigint;
ALTER TABLE movies
MODIFY gross bigint; 
-- ---------------------------------------------------------- 
-- LOADING THE DATA INTO MOVIES
-- ----------------------------------------------------------
LOAD DATA INFILE '/tmp/movies.csv' 
INTO TABLE movies
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES
(MovieID,Title,MPAA_Rating,Budget,Gross,Release_Date,Genre,Runtime,Rating,Rating_Count,Summary);

-- ----------------------------------------------------------
-- CREATING THE ACTORS TABLE
-- ----------------------------------------------------------
DROP TABLE IF EXISTS actors;
    Create Table actors(
		ActorID int,
        Name VARCHAR(50),
        Date_of_Birth varchar(12),
        Birth_City VARCHAR(100),
        Birth_Country VARCHAR(100),
        Height_Inches INT,
        Biography text,
        Gender VARCHAR(10),
        Ethnicity VARCHAR(25),
        NetWorth bigint,
        PRIMARY KEY (ActorID)
    );



TRUNCATE actors; 
-- ----------------------------------------------------------
-- LOADING THE DATA INTO ACTORS   
-- ----------------------------------------------------------
LOAD DATA INFILE '/tmp/actors.csv' 
INTO TABLE actors
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES
(ActorID,Name,@Date_of_Birth,Birth_City,Birth_Country,@Height_Inches,Biography,Gender,Ethnicity,@NetWorth)
SET
NetWorth = nullif(@NetWorth, ''),
Date_of_Birth = nullif(@Date_of_Birth, ''),
Height_Inches = nullif(@Height_Inches, '');


-- ----------------------------------------------------------
-- CREATING THE CHARACTERS 
-- ----------------------------------------------------------
DROP TABLE IF EXISTS characters;
    Create Table characters(
		CharacterId int not null auto_increment,
        MovieID int,
		ActorID int,
        Character_Name VARCHAR(50),
        creditOrder int,
        pay int,
        screentime time,
        primary key(CharacterID),
		Foreign key(MovieID) REFERENCES movie.movies(MovieID),
        Foreign key(ActorID) REFERENCES movie.actors(ActorID)
    );
      
    
TRUNCATE characters;   
-- ----------------------------------------------------------
-- LOADING THE DATA INTO CHARACTERS TABLE
-- ----------------------------------------------------------
LOAD DATA INFILE '/tmp/characters.csv' 
INTO TABLE characters
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES
(MovieID,ActorID,Character_Name,creditOrder,@pay,@screentime)
SET
pay = nullif(@pay, ''),
screentime = nullif(@screentime, '');

```
The Schema structure:

![Schema](https://github.com/ersan-kucukoglu/Data_Engineering_1/blob/main/Term_Project_1/ERR_Diagram.png)

## ANALYTICS
Two data warehouses have been created, one of which contains the data about the movies, from which it is planned to measure the performances of the movies, the second consists of the data of the actors and is for the evaluation of the actors. I created an ETL pipeline for the Data warehouse and then for the data marts
I would like to consider the following questions for analysis:
1. *What is the movie genre ranking list?*

For creating the view, the data was taken from Movies data warehouse. From the view, which is sorted by sum_profit ,the movie genre can be evaluated by total movies,average rating, total profit and average profit based on genre.

2. *What are the top 50 movies by movie profit?*

To compare the profit and rating, I made left join with the genre ranking view and got the movie data from movies data warehouse to give the features of top 50 movies between 1989 and 2019.

3. *What are the top 10 movies above average rating and profit?*

I used the Top 50 movies view to create top 10 movies whihc are above the average profit and average rating score.

4. *Who are the top 10 highest-net worth African American actors?*

I used Actors data warehouse to extract the data top 10 actors which have the highest net worth and where ethnicity is African American by sorting net worth.

5. *Who are the top 10 actors with the highest main role?*

To find the top 10 famous actor with the highest number of main roles which credit order is one, I used Actors data warehouse. It can be found by counting the characters for which the credit order value is 1 for each actor and grouping them with the actorID and sorting them according to the total number of main roles.

## ANALYTICAL LAYER
In the Analytical layer, I created denormalized data structured Movies_Performance and Actors_Performance data warehouses using the operatioanal layer and by creating stored procedures inside which used commands to extract, transform and load the data into the tables; and by joining the variables which are needed for analysis from three tables into one table.
- ACTORS PERFORMANCE
```
DROP PROCEDURE IF EXISTS GetActorsPerformance;

DELIMITER //

CREATE PROCEDURE GetActorsPerformance()
BEGIN
		DROP TABLE IF EXISTS Actors_Performance;
		CREATE TABLE Actors_Performance AS
SELECT  
                      a.ActorID,
                      a.Networth AS NetWorth_$,
                      a.name AS Actor_Name,
                      a.gender,
                      a.Birth_Country,
                      a.Birth_city,
                      a.Date_of_Birth,
                      a.Height_Inches*2.54 AS Height_cm,
                      a.Ethnicity,
                      c.creditOrder,
                      c.Character_name,
                      m.title AS Movie_Title,
                      m.genre
FROM actors a
      LEFT JOIN characters c
      using (ActorID)
      LEFT JOIN movies m
      using (MovieID)
      where a.name is not null and a.NetWorth!=''
      order by Networth desc;

END //
DELIMITER ;
ALTER TABLE Actors_Performance
MODIFY Height_cm Decimal(3);

Call GetActorsPerformance;
```
- MOVIES PERFORMANCE
```
DELIMITER //

CREATE PROCEDURE GetMoviesPerformance()
BEGIN
		DROP TABLE IF EXISTS Movies_Performance;
		CREATE TABLE Movies_Performance AS
SELECT  
		m.MovieID,
        m.title AS Movie_Title,
		m.genre,
        m.MPAA_Rating,
        m.Release_date,
		m.rating AS Movie_Rating,
        m.budget,
        m.gross,
        gross-budget AS Movie_Profit,
        a.name AS Main_Actor,
        c.Character_name AS Main_Character
FROM movies m
LEFT JOIN characters c
using (MovieID)
LEFT JOIN actors a
using(ActorID)
where c.creditOrder=1
order by movie_rating desc,movie_profit;

END //

DELIMITER ;
Call GetMoviesPerformance;
```
## DATAMARTS/VIEWS
I created views as data marts which are the subset of the data warehouse prepared for BI operations to find answers to the analytical questions.

- What is the movie genre ranking list?
```
DROP VIEW IF EXISTS Genre_ranking;
CREATE VIEW `Genre_ranking` AS
SELECT distinct genre,
count(Movie_title) AS Total_Movies,
ROUND(avg(Movie_Rating),2) AS avg_rating,
sum(movie_profit) AS Sum_Profit,
ROUND(avg(Movie_Profit)) AS Avg_Profit
FROM Movies_Performance
group by genre
order by Sum_Profit desc;
```
![Genre Ranking](https://github.com/ersan-kucukoglu/Data_Engineering_1/blob/main/Term_Project_1/genre_ranking.png)
- What are the top 50 movies by movie profit?
```
DROP VIEW IF EXISTS Top_50Movies;
CREATE VIEW `Top_50Movies` AS
SELECT 
row_number() over (order by movie_profit desc) as TOP_50,
MovieID,
Movie_Title,
genre,
release_date,
MPAA_Rating,
Movie_Rating,
g.avg_rating AS Avg_Rating_Genre,
Movie_Profit,
g.Avg_Profit AS Avg_Profit_Genre,
Main_Actor
FROM Movies_Performance
left join Genre_ranking g
using(genre)
order by Movie_profit desc
Limit 50;
```
![Top 50 Movies](https://github.com/ersan-kucukoglu/Data_Engineering_1/blob/main/Term_Project_1/top50_movies.png)
- What are the top 10 movies above average rating and profit?
```
DROP VIEW IF EXISTS top10_above_avg;
CREATE VIEW `top10_above_avg` AS
Select 
	movieID,
	movie_title,
	genre,
	Movie_Rating,
	Movie_profit
From Top_50movies
where movie_rating>=Avg_rating_genre and movie_profit>=movie_profit
limit 10;
```
![Top 10 Movies Above Average](https://github.com/ersan-kucukoglu/Data_Engineering_1/blob/main/Term_Project_1/top10_movies_above_avg.png)
- Who are the top 10 highest-net worth African American actors?
```
DROP VIEW IF EXISTS TOP10_AfricanAmericanActorsByNetWorth;
CREATE VIEW `TOP10_AfricanAmericanActorsByNetWorth` AS
SELECT 
distinct ActorID,
Actor_Name,
gender,
NetWorth_$
FROM Actors_Performance
WHERE Ethnicity='African American' 
ORDER BY NetWorth_$ DESC
LIMIT 10;
![Top 10 Actors African American](https://github.com/ersan-kucukoglu/Data_Engineering_1/blob/main/Term_Project_1/top10_actors_africanAmerican.png)
```
- Who are the top 10 actors with the highest main role?
```
DROP VIEW IF EXISTS Top_10_Famous_Actors;
CREATE VIEW `Top_10_Famous_Actors` AS
SELECT ActorID,
Actor_Name,
gender,
Ethnicity,
NetWorth_$,
count(creditOrder) AS total_Nof_main_characters
FROM Actors_Performance
where creditOrder=1
GROUP BY ActorID
ORDER BY total_Nof_main_characters DESC,NetWorth_$ desc
LIMIT 10;
```
![Top 10 Famous Actors](https://github.com/ersan-kucukoglu/Data_Engineering_1/blob/main/Term_Project_1/top10_FamousActors.png)
