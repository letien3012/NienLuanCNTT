import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../models/place.dart';
import '../../services/place_service.dart';
class PlaceManager with ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  List<Place>? places; 
  Future<void> loadPlaces(bool filteredByUser) async {
    places = await _placeService.fetchPlace(filteredByUser);
    notifyListeners();
  }

  Future<void> addPlace(Map<String, dynamic> place) async {
    return _placeService.addPlace(place);
  }

  Future<List<Place>> fetchPlace(bool filteredByUser) async {
    return await _placeService.fetchPlace(filteredByUser);
  }

  Future<Place> getPlace(String placeId) async {
    return await _placeService.getPlace(placeId);
  }

  Future<void> updatePlace(Map<String, dynamic> placeData) async {
    return _placeService.updatePlace(placeData);
  }

  
  Future<void> deletePlace(String placeId) async {
    return await _placeService.deletePlace(placeId);
  }

}