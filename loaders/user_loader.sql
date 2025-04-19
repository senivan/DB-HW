LOAD DATA INFILE '/var/lib/mysql-files/csv/users.csv'
    INTO TABLE Users
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (Name, Email, Phone);
