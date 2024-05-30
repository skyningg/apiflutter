import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CreateMovieScreen extends StatefulWidget {
  @override
  _CreateMovieScreenState createState() => _CreateMovieScreenState();
}

class _CreateMovieScreenState extends State<CreateMovieScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _releaseYearController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  void _createMovie() async {
    final HttpLink httpLink = HttpLink(
      'http://34.174.30.44:8080/graphql/', // Asegúrate de que esta URL sea correcta
    );

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation CreateLink(\$title: String!, \$director: String!, \$releaseYear: Int!, \$duration: Int!, \$genre: String!, \$imageUrl: String!) {
          createLink(title: \$title, director: \$director, releaseYear: \$releaseYear, duration: \$duration, genre: \$genre, imageUrl: \$imageUrl) {
            id
            title
            director
            releaseYear
            duration
            genre
            imageUrl
          }
        }
      '''),
      variables: <String, dynamic>{
        'title': _titleController.text,
        'director': _directorController.text,
        'releaseYear': int.parse(_releaseYearController.text),
        'duration': int.parse(_durationController.text),
        'genre': _genreController.text,
        'imageUrl': _imageUrlController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException) {
      // Película creada exitosamente
      // Puedes realizar alguna acción adicional si es necesario
      print('Película creada exitosamente');
    } else {
      // Mostrar mensaje de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo crear la película. Intente de nuevo.'),
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
        title: Text('Crear película'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título de la película',
              ),
            ),
            TextField(
              controller: _directorController,
              decoration: InputDecoration(
                labelText: 'Director',
              ),
            ),
            TextField(
              controller: _releaseYearController,
              decoration: InputDecoration(
                labelText: 'Año de lanzamiento',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _durationController,
               decoration: InputDecoration(
                labelText: 'Duración (minutos)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _genreController,
              decoration: InputDecoration(
                labelText: 'Genero',
              ),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'URL de la imagen',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createMovie,
              child: Text('Crear película'),
            ),
          ],
        ),
      ),
    );
  }
}