-- ----------------------------------------------------------
-- DATA WAREHOUSE: ACTOR PERFORMANCE
-- ----------------------------------------------------------
USE Movie;
DROP PROCEDURE IF EXISTS GetActorsPerformance;

DELIMITER //

CREATE PROCEDURE GetActorsPerformance()
BEGIN
		DROP TABLE IF EXISTS Actors_Performance;
		CREATE TABLE Actors_Performance AS
SELECT  
		a.ActorID,
		a.name AS Actor_Name,
		a.Birth_Country,
        a.gender,
        a.Date_of_Birth,
        a.Height_Inches*2.54 AS Height_cm,
        a.Ethnicity,
		c.Character_name,
        c.creditOrder,
        a.Networth,
		m.genre,
        m.title AS Movie_Title,
		m.rating AS Movie_Rating,
        gross-budget AS Movie_Profit
FROM characters c
LEFT JOIN actors a
using (ActorID)
LEFT JOIN movies m
using (MovieID)
where a.name is not null and a.NetWorth!=''
order by Networth desc,movie_rating;

END //

DELIMITER ;
Call GetActorsPerformance;
-- View Actors_Performance Data Warehouse
SELECT * FROM Actors_Performance;

-- ----------------------------------------------------------
-- DATA WAREHOUSE: MOVIES PERFORMANCE
-- ----------------------------------------------------------

USE Movie;
DROP PROCEDURE IF EXISTS GetMoviesPerformance;

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
        m.Runtime,
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
-- View Movies_Performance Data Warehouse
SELECT * FROM Movies_Performance;

-- ----------------------------------------------------------
-- TOP 50 MOVIES BY RATING 
-- ----------------------------------------------------------
DROP VIEW IF EXISTS Top_10MoviesByRating;
CREATE VIEW `Top_10MoviesByRating` AS
SELECT MovieID,Movie_Title,genre,MPAA_Rating,Movie_Rating,Movie_Profit,Main_Actor,
row_number() over (order by Movie_Rating desc,movie_profit desc) as TOP_50
FROM Movies_Performance
Limit 50;
-- ----------------------------------------------------------
-- RATINGS BY GENRE
-- ----------------------------------------------------------
DROP VIEW IF EXISTS TopRatings_By_Genre;
CREATE VIEW `TopRatings_By_Genre` AS
SELECT distinct genre,count(Movie_Rating) AS Top_Ratings
FROM Movies_Performance
group by genre
order by Top_Ratings desc;


-- ----------------------------------------------------------
-- RATINGS BY MPAA RATINGS
-- ----------------------------------------------------------
DROP VIEW IF EXISTS TopRatings_By_MPAA;
CREATE VIEW `TopRatings_By_MPAA` AS
SELECT distinct MPAA_Rating,count(Movie_Rating) AS Top_Ratings
FROM Movies_Performance
group by MPAA_Rating
order by Top_Ratings desc;


-- ----------------------------------------------------------
-- AVERAGE PROFIT BY GENRE
-- ----------------------------------------------------------
    
DROP VIEW IF EXISTS AvgProfit_By_Genre;
CREATE VIEW `AvgProfit_By_Genre` AS
SELECT distinct genre,count(Movie_title) AS Total_Movies,avg(Movie_Profit) AS Avg_Profit
FROM Movies_Performance
group by genre
order by Avg_Profit desc;

-- ----------------------------------------------------------
-- DATA MARTS - the most expensive 10 action movies
-- ----------------------------------------------------------

DROP VIEW IF EXISTS HighCost_Action_Movies;
CREATE VIEW `HighCost_Action_Movies` AS
SELECT * FROM Movies_Performance 
	WHERE Movies_Performance.Genre = 'Action'
    ORDER BY budget desc
    LIMIT 10;
    
















	
		








