LOAD DATA INFILE '/var/lib/mysql-files/csv/routes_destinations.csv'
    INTO TABLE RoutesDestinations
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (RouteId, DestinationId, StopOrder);