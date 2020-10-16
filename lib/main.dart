import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:location_search_autocomplete/addres_search.dart';
import 'package:location_search_autocomplete/place_service.dart';
import 'package:uuid/uuid.dart';
void main() => runApp(AutocompletePlaces());

class AutocompletePlaces extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Places API Demo',
      home: HomePage(title: 'Place Autocomplete Demo'),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', ''), // Portuguese, no country code
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _state = '';
  String _zipCode = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            readOnly: true,
            onTap: () async {
              final sessionToken = Uuid().v4();
              final Suggestion suggestion = await showSearch(
                context: context,
                delegate: AddressSearch(sessionToken),
              );
              if (suggestion != null) {
                final placesApi = PlaceApiProvider(sessionToken);
                final placeDetails = await placesApi.getPlaceDetailFromId(
                  suggestion.placeId,
                  Localizations.localeOf(context).languageCode,
                );
                setState(() {
                  _controller.text = 'Endereço para entrega';
                  _streetNumber = placeDetails.streetNumber;
                  _street = placeDetails.street;
                  _city = placeDetails.city;
                  _state = placeDetails.state;
                  _zipCode = placeDetails.zipCode;
                });
              }
            },
            decoration: InputDecoration(
              icon: Container(
                margin: EdgeInsets.only(left: 20),
                width: 10,
                height: 10,
                child: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
              ),
              hintText: 'Insira o endereço de entrega',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
            ),
          ),
          SizedBox(height: 20.0),
          Text('Rua: $_street'),
          Text('Número: $_streetNumber'),
          Text('Cidade: $_city'),
          Text('Estado: $_state'),
          Text('CEP: $_zipCode'),
        ],
      ),
    );
  }
}