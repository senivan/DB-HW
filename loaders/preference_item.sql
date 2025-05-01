LOAD DATA INFILE '/var/lib/mysql-files/csv/preference_item.csv'
    INTO TABLE PreferenceItem
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(PreferenceItemId, PreferenceId, PreferenceName);