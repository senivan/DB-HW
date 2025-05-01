LOAD DATA INFILE '/var/lib/mysql-files/csv/RoutesDesc.csv'
    INTO TABLE RouteDesc
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (RouteId, ExtendedDesc);
