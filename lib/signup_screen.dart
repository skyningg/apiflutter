import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signupUser() async {
    final HttpLink httpLink = HttpLink(
      'http://127.0.0.1:8000/graphql/',
    );

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation CreateUser(\$username: String!, \$email: String!, \$password: String!) {
          createUser(username: \$username, email: \$email, password: \$password) {
            user {
              username
              email
            }
          }
        }
      '''),
      variables: <String, dynamic>{
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException) {
      // Usuario creado exitosamente
      // Puedes redirigir a la pantalla de inicio de sesión o realizar alguna acción adicional
      print('Usuario creado exitosamente');
    } else {
      // Mostrar mensaje de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo crear la cuenta. Intente de nuevo.'),
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
        title: Text('Crear cuenta'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signupUser,
              child: Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
