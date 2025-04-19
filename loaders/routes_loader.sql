LOAD DATA INFILE '/var/lib/mysql-files/csv/routes.csv'
    INTO TABLE Routes
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (Name, Description, StartTime, EndTime, Distance, RecommendedSeason, DifficultyLevel);
