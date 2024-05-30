import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'movie_widget.dart'; // Asegúrate de tener esta clase definida

final storage = new FlutterSecureStorage();

class LinkListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql('''
        query {
          links {
            id
            title
            director
            releaseYear
            duration
            genre
            imageUrl
            votes {
              id
            }
            postedBy {
              username
            }
          }
        }
      ''')),
      builder: (
        QueryResult result, {
        Future<QueryResult<Object?>> Function(FetchMoreOptions)? fetchMore,
        Future<QueryResult<Object?>?> Function()? refetch,
      }) {
        if (result.hasException) {
          return Text('Error al cargar los enlaces');
        }

        if (result.isLoading) {
          return CircularProgressIndicator();
        }

        final links = result.data!['links'] as List<dynamic>;

        return ListView.builder(
          itemCount: links.length,
          itemBuilder: (context, index) {
            final link = links[index] as Map<String, dynamic>;

            return LinkWidget(
              id: int.parse(link['id']), // Convertir id a entero
              title: link['title'],
              director: link['director'],
              releaseYear: link['releaseYear'],
              duration: link['duration'],
              genre: link['genre'],
              imageUrl: link['imageUrl'],
              postedBy: link['postedBy'] != null ? link['postedBy']['username'] : 'Unknown',
              votes: link['votes'].length,
            );
          },
        );
      },
    );
  }
}