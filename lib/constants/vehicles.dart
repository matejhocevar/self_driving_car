import '../models/vehicle.dart';

final List<Vehicle> vehicles = [
  Vehicle(name: 'car_race_black', type: VehicleType.carRace),
  Vehicle(name: 'car_race_blue', type: VehicleType.carRace),
  Vehicle(name: 'car_race_red', type: VehicleType.carRace),
  Vehicle(name: 'car_race_white', type: VehicleType.carRace),
  Vehicle(name: 'car_service_ambulance', type: VehicleType.ambulance),
  Vehicle(name: 'car_service_black', type: VehicleType.carService),
  Vehicle(name: 'car_service_orange', type: VehicleType.carService),
  Vehicle(name: 'car_service_pink', type: VehicleType.carService),
  Vehicle(name: 'car_service_taxi', type: VehicleType.carService),
  Vehicle(name: 'car_sport_black', type: VehicleType.carSport),
  Vehicle(name: 'car_sport_red', type: VehicleType.carSport),
  Vehicle(name: 'car_sport_white', type: VehicleType.carSport),
  Vehicle(name: 'car_sport_white_black', type: VehicleType.carSport),
  Vehicle(name: 'car_sport_yellow', type: VehicleType.carSport),
  Vehicle(name: 'firetruck', type: VehicleType.firetruck),
  Vehicle(name: 'limousine_black', type: VehicleType.limousine),
  Vehicle(name: 'limousine_white', type: VehicleType.limousine),
  Vehicle(name: 'truck_black', type: VehicleType.truck),
  Vehicle(name: 'truck_blue', type: VehicleType.truck),
  Vehicle(name: 'truck_gold', type: VehicleType.truck),
  Vehicle(name: 'truck_red', type: VehicleType.truck),
  Vehicle(name: 'truck_silver', type: VehicleType.truck),
  Vehicle(name: 'truck_white', type: VehicleType.truck),
  Vehicle(name: 'van_black', type: VehicleType.van),
  Vehicle(name: 'van_black_red', type: VehicleType.van),
  Vehicle(name: 'van_blue', type: VehicleType.van),
  Vehicle(name: 'van_dark_blue', type: VehicleType.van),
  Vehicle(name: 'van_red', type: VehicleType.van),
  Vehicle(name: 'van_silver', type: VehicleType.van),
];

Future<void> loadAssets() async {
  for (Vehicle v in vehicles) {
    await v.load();
  }
}
