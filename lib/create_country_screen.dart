import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CreateCountryScreen extends StatefulWidget {
  @override
  _CreateCountryScreenState createState() => _CreateCountryScreenState();
}

class _CreateCountryScreenState extends State<CreateCountryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _populationController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  void _createCountry() async {
    final HttpLink httpLink = HttpLink(
      'http://127.0.0.1:8000/graphql/', // Cambiado para incluir la URL como argumento
    );

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation CreateCountry(\$name: String!, \$capital: String!, \$population: Int!, \$language: String!) {
          createCountry(name: \$name, capital: \$capital, population: \$population, language: \$language) {
            name
            capital
            population
            language
          }
        }
      '''),
      variables: <String, dynamic>{
        'name': _nameController.text,
        'capital': _capitalController.text,
        'population': int.parse(_populationController.text),
        'language': _languageController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException) {
      // País creado exitosamente
      // Puedes realizar alguna acción adicional si es necesario
      print('País creado exitosamente');
    } else {
      // Mostrar mensaje de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo crear el país. Intente de nuevo.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear país'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del país',
              ),
            ),
            TextField(
              controller: _capitalController,
              decoration: InputDecoration(
                labelText: 'Capital',
              ),
            ),
            TextField(
              controller: _populationController,
              decoration: InputDecoration(
                labelText: 'Población',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _languageController,
              decoration: InputDecoration(
                labelText: 'Idioma',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createCountry,
              child: Text('Crear país'),
            ),
          ],
        ),
      ),
    );
  }
}
