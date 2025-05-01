LOAD DATA INFILE '/var/lib/mysql-files/csv/facilities.csv'
    INTO TABLE Facilities
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (DestinationId, OpeningHour, ClosingHour, Description);