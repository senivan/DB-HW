LOAD DATA INFILE '/var/lib/mysql-files/csv/bookings.csv'
    INTO TABLE Bookings
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (UserId, ServiceType, BookingTime, TotalCost, PaymentStatus, TransportId, RouteId);
