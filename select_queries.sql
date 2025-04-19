/* Query 1: Union */
select Name from Routes
union
select Name from Destinations;

/* Query 2: Intersection */
select R.Name
from Routes R
where R.Name in (select Name from Destinations);

/* Query 3: Subtraction */
select R.Name
from Routes R
where R.Name not in (select Name from Destinations);

/* Query 4: Cartesian product */
select  U.Name as UserName, T.Mode, T.Provider
from Users U, Transport T;

/* Query 5: Selection */
select * from Bookings
where PaymentStatus = 1;

/* Query 6: Projection */
select Name, Email from Users;

/* Query 7: Theta join */
select U.Name, B.BookingTime, B.TotalCost
from Users U
join Bookings B on U.UserId = B.UserId
where b.TotalCost < 20;