import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'create_country_screen.dart'; // Importar CreateCountryScreen en lugar de CreateCountryWidget
import 'movie_list_widget.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String? token = await storage.read(key: 'token');
  print('Token JWT: $token');

  final HttpLink httpLink = HttpLink(
    'http://34.174.30.44:8080/graphql/',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer $token',
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    ),
  );

  runApp(MyApp(client: client, link: link));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  final Link link;

  MyApp({required this.client, required this.link});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'SKYFLIX: CINEFILOS EL COMIENZO',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(client: client),
        routes: {
          '/home': (context) => MyHomePage(client: client),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/createCountry': (context) => CreateMovieScreen(),
          '/countryList': (context) => LinkListWidget(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ValueNotifier<GraphQLClient> client;

  MyHomePage({required this.client});

  @override
  _MyHomePageState createState() => _MyHomePageState(client: client);
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<GraphQLClient> client;
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    LinkListWidget(),
    LoginScreen(),
    SignupScreen(),
    CreateMovieScreen(),
  ];

  _MyHomePageState({required this.client});

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SKYFLIX'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20), // Añadir espacio aquí para bajar los botones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _onItemTapped(0),
                child: Text('PELICULAS PUBLICADAS'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(1),
                child: Text('INICIA SESION'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(2),
                child: Text('CREA USUARIO'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(3),
                child: Text('SUBE TU PELI PIRATA'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await storage.delete(key: 'token');
                  Navigator.pushReplacementNamed(context, '/login'); // Redirigir a la pantalla de Login después del logout
                },
                child: Text('Logout'),
              ),
            ],
          ),
          SizedBox(height: 20), // Añadir espacio aquí si se requiere más separación
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
    );
  }
}
