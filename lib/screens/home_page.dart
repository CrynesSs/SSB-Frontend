import 'package:flutter/material.dart';
import 'package:qsb/screens/about_page.dart';
import 'package:qsb/screens/signup_page.dart';
import 'package:qsb/screens/welcome_page.dart';
import '../enums/e_pages.dart';
import 'dashboard_page.dart';
import 'keygen_page.dart';
import 'login_page.dart';
import 'package:qsb/globals.dart';

class HomePage extends StatefulWidget {
  final Function(bool) toggleDarkMode;
  final bool isDarkMode;

  const HomePage(
      {super.key, required this.toggleDarkMode, required this.isDarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _currentPage = const WelcomeScreen(); // Default page
  String _selectedLanguage = 'EN';
  bool loggedIn = isLoggedIn;

  void _changeLanguage(String? lang) {
    if (lang != null) {
      setState(() {
        _selectedLanguage = lang;
      });
      // Implement actual localization logic here if needed
    }
  }



  void _switchPage(EPages page) {
    setState(() {

      _currentPage = switch(page)
      {

        EPages.login => LoginScreen(login: _login),

        EPages.signup => SignupScreen(switchPage: _switchPage),

        EPages.about => const AboutPage(),

        EPages.dashboard => const DashboardPage(),

        EPages.keygen => const KeygenScreen(),

        EPages.home => const WelcomeScreen(),
      };
    });
  }

  void _login() {
    setState(() {
      loggedIn = isLoggedIn;
      if(loggedIn){
        _switchPage(EPages.dashboard);
      }
      else{
        _switchPage(EPages.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text("SecureShareBox"),
          actions: [
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'EN', child: Text("EN")),
                DropdownMenuItem(value: 'DE', child: Text("DE")),
              ],
              onChanged: _changeLanguage,
            ),
            IconButton(
              icon:
                  Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => widget.toggleDarkMode(!widget.isDarkMode),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Navigation',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              if (!loggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: (){
                    Navigator.pop(context); // close drawer
                    _switchPage(EPages.home);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login'),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    _switchPage(EPages.login);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Signup'),
                  onTap: () {
                    Navigator.pop(context);
                    _switchPage(EPages.signup);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: const Text('Keygen'),
                  onTap: () {
                    Navigator.pop(context);
                    _switchPage(EPages.keygen);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: (){
                    Navigator.pop(context);
                    _switchPage(EPages.about);
                  },
                )
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.dashboard_sharp),
                  title: const Text('Dashboard'),
                  onTap: () {
                    setState(() {
                      _currentPage = const DashboardPage();
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.meeting_room),
                  title: const Text('Rooms'),
                  onTap: (){
                    setState(() {
                      //TODO
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    setState(() {
                      isLoggedIn = false;
                      sessionCookie = '';
                      _login();
                    });
                    Navigator.pop(context);
                  },
                ),
              ]
            ],
          ),
        ),
        body: _currentPage,
      ),
    );
  }
}
