// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Tema rengi
        title: null, // Başlığı burada ayarlamayacağız
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0, // Gölgeyi kaldırmak isterseniz
        flexibleSpace: Column(
          children: [
            SizedBox(height: 30), // Geri ok simgesi ile başlık arasındaki boşluk
            Expanded(
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E), // Arkaplan rengi
      body: ListView(
        children: [
          ListTile(
            title: Text('Profile Settings', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.person, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Text('Security and Privacy', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.security, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecurityPrivacyPage()),
              );
            },
          ),
          ListTile(
            title: Text('Notifications', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.notifications, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          ListTile(
            title: Text('Themes', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.color_lens, color: Colors.white),
            onTap: () {
              _showThemeDialog();
            },
          ),
          ListTile(
            title: Text('Language', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.language, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguagePage()),
              );
            },
          ),
          ListTile(
            title: Text('Data and Synchronization', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.sync, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DataSyncPage()),
              );
            },
          ),
          ListTile(
            title: Text('App Settings', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.settings, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Text('Feedback and Support', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.feedback, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackSupportPage()),
              );
            },
          ),
          ListTile(
            title: Text('About', style: TextStyle(color: Colors.white)),
            leading: Icon(Icons.info, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Provider.of<ThemeProvider>(context).currentTheme.background, // Tema rengi
          title: Text('Select Theme', style: TextStyle(color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText)), // Başlık rengi
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Light Theme', style: TextStyle(color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText)),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false).setThemeValue(1);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Dark Theme', style: TextStyle(color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText)),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false).setThemeValue(2);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Blue Theme', style: TextStyle(color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText)),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false).setThemeValue(3);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Purple Theme', style: TextStyle(color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText)),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false).setThemeValue(4);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
class ProfileSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('Profile Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('Profile Settings Page', style: TextStyle(color: Colors.white))),
    );
  }
}

class SecurityPrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('Security and Privacy', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('Security and Privacy Page', style: TextStyle(color: Colors.white))),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('Notifications Page', style: TextStyle(color: Colors.white))),
    );
  }
}

class LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('Language', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('Language Page', style: TextStyle(color: Colors.white))),
    );
  }
}

class DataSyncPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('Data and Synchronization', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('Data and Synchronization Page', style: TextStyle(color: Colors.white))),
    );
  }
}

class AppSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('App Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('App Settings Page', style: TextStyle(color: Colors.white))),
    );
  }
}

class FeedbackSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('Feedback and Support', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('Feedback and Support Page', style: TextStyle(color: Colors.white))),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        title: Text('About', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // iOS stilinde geri ok
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(child: Text('About Page', style: TextStyle(color: Colors.white))),
    );
  }
}
