import 'dart:ui' as UI;

import 'package:flutter/material.dart';

import '../utils/image.dart';

enum VehicleType {
  unknown,
  carRace,
  carSport,
  carService,
  van,
  limousine,
  firetruck,
  police,
  ambulance,
  truck,
}

const double vehicleScale = 1.5;

class Vehicle {
  Vehicle({
    required this.name,
    required this.type,
    Size? size,
    double? maxSpeed,
  }) {
    this.size = size ??
        switch (type) {
          VehicleType.carRace => const Size(25.5, 48),
          VehicleType.carSport => const Size(22.5, 43),
          VehicleType.carService => name != 'car_service_black'
              ? const Size(25.5, 49.5)
              : const Size(23.5, 45.5),
          VehicleType.van => name != 'van_black_red'
              ? const Size(27.5, 51.5)
              : const Size(27.5, 53),
          VehicleType.limousine => const Size(25.5, 68.5),
          VehicleType.firetruck => const Size(30, 69.5),
          VehicleType.truck => const Size(26, 46),
          VehicleType.police => const Size(29, 46.5),
          VehicleType.ambulance => const Size(28.5, 45.5),
          VehicleType.unknown => const Size(30, 50),
        };
    this.size = this.size * vehicleScale;

    this.maxSpeed = maxSpeed ??
        switch (type) {
          VehicleType.carRace || VehicleType.police => 5,
          VehicleType.carSport || VehicleType.ambulance => 4,
          VehicleType.carService || VehicleType.unknown => 3,
          VehicleType.truck => 2.75,
          VehicleType.van || VehicleType.limousine => 2.5,
          VehicleType.firetruck => 2,
        };
  }

  Future<Vehicle> load() async {
    image = await loadUiImage('assets/vehicles/$name.png');
    return this;
  }

  final String name;
  final VehicleType type;
  late Size size;
  late double maxSpeed;
  UI.Image? image;
}
