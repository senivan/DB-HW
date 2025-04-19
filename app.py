from fastapi import FastAPI, HTTPException, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, Column, BigInteger, String, Float, Boolean, Time, Enum, Text, ForeignKey, DateTime, func, desc
from sqlalchemy.orm import sessionmaker, declarative_base
from datetime import datetime
import uvicorn

DATABASE_URL = 'mysql+pymysql://root:ANDPMSHXPT1V5kv5pfqmjGMhVzbcpXTe@localhost/tourist_routes'

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# Models
class Routes(Base):
    __tablename__ = 'routes'
    RouteId = Column(BigInteger, primary_key=True, autoincrement=True)
    Name = Column(String(256), nullable=False)
    Description = Column(Text)
    StartTime = Column(Time, nullable=False)
    EndTime = Column(Time, nullable=False)
    Distance = Column(Float)
    RecommendedSeason = Column(Enum('winter','spring','summer','autumn'))
    DifficultyLevel = Column(Enum('very easy','easy','normal','hard','expert'))

class RoutesDestinations(Base):
    __tablename__ = 'routesdestinations'
    RouteId = Column(BigInteger, ForeignKey('routes.RouteId', ondelete='CASCADE'), primary_key=True)
    DestinationId = Column(BigInteger, ForeignKey('destinations.DestinationId', ondelete='CASCADE'), primary_key=True)
    StopOrder = Column(BigInteger, nullable=False)

class Destinations(Base):
    __tablename__ = 'destinations'
    DestinationId = Column(BigInteger, primary_key=True, autoincrement=True)
    Name = Column(String(256), nullable=False)
    Latitude = Column(Float, nullable=False)
    Longtitude = Column(Float, nullable=False)
    Category = Column(String(256))
    Description = Column(Text)
    OpenTime = Column(Time, nullable=False)
    CloseTime = Column(Time, nullable=False)

class Bookings(Base):
    __tablename__ = 'bookings'
    BookingId = Column(BigInteger, primary_key=True, autoincrement=True)
    UserId = Column(BigInteger, ForeignKey('users.UserId', ondelete='CASCADE'), nullable=False)
    ServiceType = Column(String(255))
    BookingTime = Column(DateTime, nullable=False)
    TotalCost = Column(Float)
    PaymentStatus = Column(Boolean)
    TransportId = Column(BigInteger, ForeignKey('transport.TransportId', ondelete='CASCADE'), nullable=False)
    RouteId = Column(BigInteger, ForeignKey('routes.RouteId', ondelete='CASCADE'), nullable=False)

class Users(Base):
    __tablename__ = 'users'
    UserId = Column(BigInteger, primary_key=True, autoincrement=True)
    Name = Column(String(256), nullable=False)
    Email = Column(String(128), nullable=False)
    Phone = Column(String(16), nullable=False)

class Transport(Base):
    __tablename__ = 'transport'
    TransportId = Column(BigInteger, primary_key=True, autoincrement=True)
    Mode = Column(String(256), nullable=False)
    Provider = Column(String(256), nullable=False)
    Price = Column(Float, nullable=False)
    IsAvailable = Column(Boolean)
    DepartureTime = Column(Time, nullable=False)
    ArrivalTime = Column(Time, nullable=False)

class Feedback(Base):
    __tablename__ = 'feedback'
    FeedbackId = Column(BigInteger, primary_key=True, autoincrement=True)
    UserId = Column(BigInteger, ForeignKey('users.UserId', ondelete='CASCADE'), nullable=False)
    RouteId = Column(BigInteger, ForeignKey('routes.RouteId', ondelete='CASCADE'), nullable=False)
    Rating = Column(BigInteger, nullable=False)
    Comment = Column(Text)

# API Endpoints
@app.get("/", response_class=HTMLResponse)
def index(request: Request):
    return RedirectResponse(url="/routes")

@app.get("/routes", response_class=HTMLResponse)
def list_routes(request: Request):
    session = SessionLocal()
    routes = session.query(Routes).all()
    session.close()
    return templates.TemplateResponse("routes.html", {"request": request, "routes": routes})

@app.post("/routes/create")
def create_route(Name: str = Form(...), Description: str = Form(...), StartTime: str = Form(...), EndTime: str = Form(...),
                 Distance: float = Form(...), RecommendedSeason: str = Form(...), DifficultyLevel: str = Form(...)):
    session = SessionLocal()
    route = Routes(Name=Name, Description=Description, StartTime=datetime.strptime(StartTime, '%H:%M').time(),
                   EndTime=datetime.strptime(EndTime, '%H:%M').time(), Distance=Distance,
                   RecommendedSeason=RecommendedSeason, DifficultyLevel=DifficultyLevel)
    session.add(route)
    session.commit()
    session.close()
    return RedirectResponse(url="/routes", status_code=303)

@app.post("/routes/{route_id}/update")
def update_route(route_id: int, Description: str = Form(...)):
    session = SessionLocal()
    route = session.query(Routes).get(route_id)
    if route:
        route.Description = Description
        session.commit()
    session.close()
    return RedirectResponse(url="/routes", status_code=303)

@app.post("/routes/{route_id}/destinations")
def link_destinations(route_id: int, DestinationId: int = Form(...), StopOrder: int = Form(...)):
    session = SessionLocal()
    link = RoutesDestinations(RouteId=route_id, DestinationId=DestinationId, StopOrder=StopOrder)
    session.add(link)
    session.commit()
    session.close()
    return RedirectResponse(url=f"/routes", status_code=303)

@app.post("/routes/{route_id}/reorder")
def reorder_destinations(route_id: int, DestinationId: int = Form(...), NewStopOrder: int = Form(...)):
    session = SessionLocal()
    dest = session.query(RoutesDestinations).filter_by(RouteId=route_id, DestinationId=DestinationId).first()
    if dest:
        dest.StopOrder = NewStopOrder
        session.commit()
    session.close()
    return RedirectResponse(url=f"/routes", status_code=303)

@app.get("/routes/filter", response_class=HTMLResponse)
def filter_routes(request: Request, MinDistance: float = 0.0, MaxDistance: float = 1000.0, Difficulty: str = None):
    session = SessionLocal()
    query = session.query(Routes).filter(Routes.Distance >= MinDistance, Routes.Distance <= MaxDistance)
    if Difficulty:
        query = query.filter(Routes.DifficultyLevel == Difficulty)
    routes = query.all()
    session.close()
    return templates.TemplateResponse("routes_filtered.html", {"request": request, "routes": routes})

@app.get("/routes/sort", response_class=HTMLResponse)
def sort_routes(request: Request, order: str = 'desc'):
    session = SessionLocal()
    ratings = session.query(Routes.RouteId, Routes.Name, func.avg(Feedback.Rating).label('AverageRating'))\
        .join(Feedback, isouter=True).group_by(Routes.RouteId).order_by(desc('AverageRating') if order=='desc' else 'AverageRating').all()
    session.close()
    return templates.TemplateResponse("routes_sorted.html", {"request": request, "routes": ratings})

@app.get("/bookings", response_class=HTMLResponse)
def list_bookings(request: Request):
    session = SessionLocal()
    bookings = session.query(Bookings).all()
    session.close()
    return templates.TemplateResponse("bookings.html", {"request": request, "bookings": bookings})

@app.post("/bookings/create")
def create_booking(UserId: int = Form(...), ServiceType: str = Form(...), BookingTime: str = Form(...),
                   TotalCost: float = Form(...), PaymentStatus: bool = Form(...), TransportId: int = Form(...),
                   RouteId: int = Form(...)):
    session = SessionLocal()
    booking = Bookings(UserId=UserId, ServiceType=ServiceType, BookingTime=datetime.strptime(BookingTime, '%Y-%m-%d %H:%M:%S'),
                       TotalCost=TotalCost, PaymentStatus=PaymentStatus, TransportId=TransportId, RouteId=RouteId)
    session.add(booking)
    session.commit()
    session.close()
    return RedirectResponse(url="/bookings", status_code=303)

@app.post("/bookings/{booking_id}/confirm")
def confirm_booking(booking_id: int):
    session = SessionLocal()
    booking = session.query(Bookings).get(booking_id)
    if booking:
        booking.PaymentStatus = True
        session.commit()
    session.close()
    return RedirectResponse(url="/bookings", status_code=303)

@app.post("/bookings/{booking_id}/delete")
def delete_booking(booking_id: int):
    session = SessionLocal()
    booking = session.query(Bookings).get(booking_id)
    if booking:
        session.delete(booking)
        session.commit()
    session.close()
    return RedirectResponse(url="/bookings", status_code=303)


@app.get("/reports/upcoming", response_class=HTMLResponse)
def upcoming_bookings_report(request: Request):
    session = SessionLocal()
    # Get upcoming bookings (those with dates in the future)
    current_time = datetime.now()
    upcoming = session.query(
        Bookings, Users.Name.label('UserName'), Routes.Name.label('RouteName'), 
        Transport.Provider.label('TransportProvider')
    ).join(Users, Bookings.UserId == Users.UserId)\
     .join(Routes, Bookings.RouteId == Routes.RouteId)\
     .join(Transport, Bookings.TransportId == Transport.TransportId)\
     .filter(Bookings.BookingTime > current_time)\
     .order_by(Bookings.BookingTime)\
     .all()
    
    # Format the data for the template
    data = []
    for booking, user_name, route_name, transport_provider in upcoming:
        data.append({
            'BookingId': booking.BookingId,
            'UserName': user_name,
            'RouteName': route_name,
            'BookingTime': booking.BookingTime,
            'TotalCost': booking.TotalCost,
            'PaymentStatus': booking.PaymentStatus,
            'TransportProvider': transport_provider
        })
    
    session.close()
    return templates.TemplateResponse("report_upcoming.html", {"request": request, "data": data})
@app.post("/feedback")
def submit_feedback(UserId: int = Form(...), RouteId: int = Form(...), Rating: int = Form(...), Comment: str = Form(...)):
    session = SessionLocal()
    feedback = Feedback(UserId=UserId, RouteId=RouteId, Rating=Rating, Comment=Comment)
    session.add(feedback)
    session.commit()
    session.close()
    return RedirectResponse(url="/routes/sort", status_code=303)

if __name__ == "__main__":
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=True)
