
/* Update 1 */
update Users
set Email = 'updated_john@updated_email.com'
where UserId = 1;

/* Update 2 */
update Users
set UserId = 50
where UserId = 2;

/* Update 3 */
update Transport
set Provider = 'Very fast express'
where TransportId = 3;

/* Update 4 */
update Routes
set DifficultyLevel = 'expert'
where RouteId = 3;

/* Update 5 */
update RoutesDestinations
set StopOrder = 2
where RouteId = 1 and DestinationId = 3;



-- For the Preference table:
# ALTER TABLE Preference
# DROP FOREIGN KEY preference_ibfk_1,
# ADD CONSTRAINT fk_preference_users
#     FOREIGN KEY (UserId)
#         REFERENCES Users(UserId)
#         ON DELETE CASCADE
#         ON UPDATE CASCADE;
#
# For the Bookings table:
# ALTER TABLE Bookings
#     DROP FOREIGN KEY bookings_ibfk_1,
#     ADD CONSTRAINT fk_bookings_users
#         FOREIGN KEY (UserId)
#             REFERENCES Users(UserId)
#             ON DELETE CASCADE
#             ON UPDATE CASCADE;
