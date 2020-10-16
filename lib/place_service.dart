import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Place {
  const Place({
    this.streetNumber,
    this.street,
    this.city,
    this.state,
    this.zipCode,
  });

  final String streetNumber;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
  }
}

class Suggestion {
  const Suggestion(this.placeId, this.description);

  final String placeId;
  final String description;

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  PlaceApiProvider(this.sessionToken);

  final client = http.Client();
  final sessionToken;

  static final String androidKey = '<YOUR_API_KEY_HERE>';
  static final String iosKey = '<YOUR_API_KEY_HERE>';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String languageCode) async {
    final request =
      'https://maps.googleapis.com/maps/api/place/autocomplete/'
      'json?input=$input&types=address&language=$languageCode'
      '&components=country:br&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final suggestions = result['predictions'].map<Suggestion>((predictions) =>
          Suggestion(predictions['place_id'], predictions['description']));
        return suggestions.toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId, String languageCode) async {
    final request =
      'https://maps.googleapis.com/maps/api/place/details/'
      'json?place_id=$placeId&fields=address_component&language=$languageCode&'
      'key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    String streetNumber;
    String street;
    String city;
    String state;
    String zipCode;

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final List<dynamic> components = result['result']['address_components'];
        for (Map<String, dynamic> component in components) {
          final List type = component['types'];
          if (type.contains('street_number')) {
            streetNumber = component['long_name'];
          }
          if (type.contains('route')) {
            street = component['long_name'];
          }
          if (type.contains('administrative_area_level_2')) {
            city = component['long_name'];
          }
          if (type.contains('administrative_area_level_1')) {
            state = component['short_name'];
          }
          if (type.contains('postal_code')) {
            zipCode = component['long_name'];
          }
        }
        return Place(
          street: street,
          streetNumber:
          streetNumber,
          city: city,
          state:state,
          zipCode: zipCode
        );
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
