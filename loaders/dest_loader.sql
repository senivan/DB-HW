LOAD DATA INFILE '/var/lib/mysql-files/csv/destinations.csv'
    INTO TABLE Destinations
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (Name, Latitude, Longtitude, Category, Description, OpenTime, CloseTime);