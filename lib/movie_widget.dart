import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class LinkWidget extends StatelessWidget {
  final int id;
  final String title;
  final String director;
  final String genre;
  final int releaseYear;
  final int duration;
  final String imageUrl;
  final String postedBy;
  final int votes;

  LinkWidget({
    required this.id,
    required this.title,
    required this.director,
    required this.genre,
    required this.releaseYear,
    required this.duration,
    required this.imageUrl,
    required this.postedBy,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink('http://34.174.30.44:8080/graphql/');

    final AuthLink authLink = AuthLink(
      getToken: () async => 'JWT ${await storage.read(key: 'token')}',
    );

    final Link link = authLink.concat(httpLink);

    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: Mutation(
        options: MutationOptions(
        document: gql('''
          mutation CreateVote(\$linkId: Int!) {
            createVote(linkId: \$linkId) {
              user {
                id
                username
              }
              link {
                id
                title
                director
                genre
                releaseYear
                duration
                imageUrl
                postedBy {
                  username
                }
                votes {
                  id
                }
              }
            }
          }
        '''),
        onCompleted: (dynamic resultData) {
          print('Voto creado exitosamente');
        },
      ),
      builder: (
        RunMutation runMutation,
        QueryResult? result,
      ) {
        return ListTile(
          title: Text(title),
          subtitle: Text('$director\n$genre, $releaseYear\n$duration\n$imageUrl\n$votes votes | by $postedBy'),
          trailing: InkWell(
            onTap: () async {
              final authToken = await storage.read(key: 'jwt_token');
              runMutation({'linkId': id}, optimisticResult: {'linkId': id});
            },
            child: Text('Like'),
          ),
          );
        },
      ),
    );
  }
}
