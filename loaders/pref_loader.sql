LOAD DATA INFILE '/var/lib/mysql-files/csv/preferences.csv'
    INTO TABLE Preference
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (UserId, Preferences);