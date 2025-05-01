LOAD DATA INFILE '/var/lib/mysql-files/csv/feedback.csv'
    INTO TABLE Feedback
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(UserId, RouteId, Rating, Comment);