-- ----------------------------------------------------------
-- 					OPERATIONAL LAYER
-- ----------------------------------------------------------
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
        NetWorth char(25),
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
(ActorID,Name,@Date_of_Birth,Birth_City,Birth_Country,@Height_Inches,Biography,Gender,Ethnicity,NetWorth)
SET
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






