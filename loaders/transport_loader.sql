LOAD DATA INFILE '/var/lib/mysql-files/csv/transport.csv'
    INTO TABLE Transport
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (Mode, Provider, Price, IsAvailable, DepartureTime, ArrivalTime);