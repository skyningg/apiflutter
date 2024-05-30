import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'create_country_screen.dart'; // Importar CreateCountryScreen en lugar de CreateCountryWidget
import 'country_list_widget.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  final String? token = await storage.read(key: 'token');
  print('Token JWT: $token');

  final HttpLink httpLink = HttpLink(
    'http://127.0.0.1:8000/graphql/',
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

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  MyApp({required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Countries',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
        routes: {
          '/home': (context) => MyHomePage(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/createCountry': (context) => CreateCountryScreen(),
          '/countryList': (context) => CountryListWidget(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    CountryListWidget(),
    LoginScreen(),
    SignupScreen(),
    CreateCountryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Countries'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _onItemTapped(0),
                child: Text('List Countries'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(1),
                child: Text('Login'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(2),
                child: Text('Create Account'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(3),
                child: Text('Create Country'),
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
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
    );
  }
}
