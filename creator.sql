drop table if exists RouteDesc;
drop table if exists Bookings;
drop table if exists RoutesDestinations;
drop table if exists PreferenceItem;
drop table if exists Preference;
drop table if exists Feedback;
drop table if exists Users;
drop table if exists Transport;
drop table if exists Routes;
drop table if exists Facilities;
drop table if exists Destinations;


create table if not exists Users(
    UserId bigint primary key auto_increment,
    Name varchar(256) not null,
    Email varchar(128) not null,
    Phone varchar(16) not null
) engine=innodb comment "User entity";
CREATE TABLE Preference (
    PreferenceId BIGINT PRIMARY KEY AUTO_INCREMENT,
    UserId BIGINT NOT NULL,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);
CREATE TABLE PreferenceItem (
    PreferenceItemId BIGINT PRIMARY KEY AUTO_INCREMENT,
    PreferenceId BIGINT NOT NULL,
    PreferenceName VARCHAR(128) NOT NULL,
    FOREIGN KEY (PreferenceId) REFERENCES Preference(PreferenceId) ON DELETE CASCADE
);
create table if not exists Transport(
    TransportId bigint primary key auto_increment,
    Mode varchar(256) not null,
    Provider varchar(256) not null,
    Price double not null,
    IsAvailable bool,
    DepartureTime time not null,
    ArrivalTime time not null
) engine=innodb comment="Transport entity";
create table if not exists Routes(
    RouteId bigint primary key auto_increment,
    Name varchar(256) not null,
    Description longtext,
    StartTime time not null,
    EndTime time not null,
    Distance float,
    RecommendedSeason enum('winter', 'spring', 'summer', 'autumn'),
    DifficultyLevel enum('very easy', 'easy', 'normal', 'hard', 'expert')
) engine=innodb comment="Route entity";
create table if not exists Bookings(
    BookingId bigint primary key auto_increment,
    UserId bigint not null,
    ServiceType varchar(255),
    BookingTime datetime not null,
    TotalCost double,
    PaymentStatus bool,
    TransportId bigint not null,
    RouteId bigint not null,
    foreign key (UserId) references Users(UserId)
        on delete cascade,
    foreign key (TransportId) references Transport(TransportId)
        on delete cascade,
    foreign key (RouteId) references Routes(RouteId)
        on delete cascade
)engine=innodb comment="Booking entity";
create table if not exists Destinations(
    DestinationId bigint primary key auto_increment,
    Name varchar(256) not null,
    Latitude double not null,
    Longtitude double not null,
    Category varchar(256),
    Description longtext,
    OpenTime time not null,
    CloseTime time not null
)engine=innodb comment="Destination entity";
create table if not exists Facilities(
    FacilityId bigint primary key auto_increment,
    DestinationId bigint not null,
    OpeningHour time not null,
    ClosingHour time not null,
    Description longtext,
    foreign key (DestinationId) references Destinations(DestinationId)
     on delete cascade
)engine=innodb comment="Facillity entity";
create table if not exists RoutesDestinations(
    RouteId bigint not null,
    DestinationId bigint not null,
    StopOrder int not null,
    primary key (RouteId, DestinationId),
    foreign key (RouteId) references Routes(RouteId)
     on delete cascade,
    foreign key (DestinationId) references Destinations(DestinationId)
     on delete cascade
)engine=innodb comment="Relationship helper table";

CREATE TABLE IF NOT EXISTS Feedback (
    FeedbackId BIGINT PRIMARY KEY AUTO_INCREMENT,
    UserId BIGINT NOT NULL,
    RouteId BIGINT NOT NULL,
    Rating INT NOT NULL,
    Comment TEXT,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (RouteId) REFERENCES Routes(RouteId) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Feedback entity';
CREATE TABLE IF NOT EXISTS RouteDesc (
                                         RouteTextId       BIGINT      NOT NULL AUTO_INCREMENT,
                                         RouteId           BIGINT      NOT NULL,
                                         ExtendedDesc      TEXT        NOT NULL,
                                         PRIMARY KEY (RouteTextId),
                                         FOREIGN KEY (RouteId) REFERENCES Routes(RouteId)
                                             ON DELETE CASCADE
) ENGINE=MyISAM
  DEFAULT CHARSET = utf8mb4
    COMMENT = 'Full-text descriptions for tourist routes';