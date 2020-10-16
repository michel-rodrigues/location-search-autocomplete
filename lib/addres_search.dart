import 'package:flutter/material.dart';
import 'package:location_search_autocomplete/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion> {

  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => null;

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
        ? null
        : apiClient.fetchSuggestions(query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) {
        if (query == '') {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Text('Insira o endereço de entrega'),
          );
        } else if (snapshot.hasData) {
          final int suggestionsCount = snapshot.data.length;
          return ListView.builder(
            itemBuilder: (context, index) {
              Suggestion suggestion = snapshot.data[index];
              return ListTile(
                key: Key('suggestion_$index'),
                title: Text(suggestion.description),
                onTap: () => close(context, suggestion),
              );
            },
            itemCount: suggestionsCount,
          );
        } else {
          return Container(child: Text('Carregando...'));
        }
      }
    );
  }

}