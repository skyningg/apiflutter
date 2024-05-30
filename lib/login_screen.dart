import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginUser() async {
    final HttpLink httpLink = HttpLink(
      'http://127.0.0.1:8000/graphql/',
    );

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation TokenAuth(\$username: String!, \$password: String!) {
          tokenAuth(username: \$username, password: \$password) {
            token
          }
        }
      '''),
      variables: <String, dynamic>{
        'username': _usernameController.text,
        'password': _passwordController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException) {
      final token = result.data?['tokenAuth']?['token'];
      if (token != null) {
        await storage.write(key: 'token', value: token);
        
        // Navegar a la siguiente pantalla después de iniciar sesión
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('No se pudo obtener el token. Intente de nuevo.');
      }
    } else {
      _showErrorDialog('Usuario o contraseña incorrectos.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loginUser,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
