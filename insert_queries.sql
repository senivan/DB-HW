/* Simple insert query */
insert into Users (UserId, Name, Email, Phone)
values (51,'New user', 'new_user@new_mail.com', '1112223333');

/* Complex insert query */
start transaction;

insert into Routes (Name, Description, StartTime, EndTime, Distance, RecommendedSeason, DifficultyLevel)
values ('New Scenic Route', 'A scenic tour along the coast', '08:00:00', '10:00:00', 15, 'summer', 'easy');

set @new_route_id = last_insert_id();

insert into Transport (Mode, Provider, Price, IsAvailable, DepartureTime, ArrivalTime)
values ('Bus', 'Coastal Transport', 8.00, 1, '08:00:00', '09:30:00');

set @new_transport_id = last_insert_id();

insert into Bookings (UserId, ServiceType, BookingTime, TotalCost, PaymentStatus, TransportId, RouteId)
values (1, 'Standard', NOW(), 20.00, 1, @new_transport_id, @new_route_id);

commit;

/* replace query */
REPLACE INTO Users (UserId, Name, Email, Phone)
VALUES (51, 'Replaced person', 'person.replaced@example.com', '1234567890');

