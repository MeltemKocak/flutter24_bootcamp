import 'package:easy_localization/easy_localization.dart';
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
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        title: null,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.welcomeText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        flexibleSpace: Column(
          children: [
            SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: theme.welcomeText,
                  ),
                ).tr(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: theme.background,
      body: ListView(
        children: [
          _buildListTile(
            context,
            title: tr("Profile Settings"),
            icon: Icons.person,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
            ),
          ),
          _buildListTile(
            context,
            title: tr("Security and Privacy"),
            icon: Icons.security,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecurityPrivacyPage()),
            ),
          ),
          _buildListTile(
            context,
            title: tr("Notifications") ,
            icon: Icons.notifications,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            ),
          ),
          _buildListTile(
            context,
            title: tr("Themes"),
            icon: Icons.color_lens,
            onTap: _showThemeDialog,
          ),
          _buildListTile(
            context,
            title: tr("Language"),
            icon: Icons.language,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LanguagePage()),
            ),
          ),
          _buildListTile(
            context,
            title: tr("Data and Synchronization"),
            icon: Icons.sync,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataSyncPage()),
            ),
          ),
          _buildListTile(
            context,
            title: tr("App Settings"),
            icon: Icons.settings,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppSettingsPage()),
            ),
          ),
          _buildListTile(
            context,
            title: tr("Feedback and Support"),
            icon: Icons.feedback,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedbackSupportPage()),
            ),
          ),
          _buildListTile(
            context,
            title: tr("About"),
            icon: Icons.info,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return ListTile(
      title: Text(title, style: TextStyle(color: theme.welcomeText)),
      leading: Icon(icon, color: theme.welcomeText),
      onTap: onTap,
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Provider.of<ThemeProvider>(context).currentTheme;
        return AlertDialog(
          backgroundColor: theme.background,
          title: Text("Select Theme", style: TextStyle(color: theme.welcomeText)).tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(context, tr("Light Theme"), 1),
              _buildThemeOption(context, tr("Dark Theme"), 2),
              _buildThemeOption(context, tr("Blue Theme"), 3),
              _buildThemeOption(context, tr("Purple Theme"), 4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String themeName, int themeValue) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return ListTile(
      title: Text(themeName, style: TextStyle(color: theme.welcomeText)),
      onTap: () {
        Provider.of<ThemeProvider>(context, listen: false).setThemeValue(themeValue);
        Navigator.of(context).pop();
      },
    );
  }
}

class ProfileSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text('Profile Settings', style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text("Profile Settings", style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}

class SecurityPrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text("Security and Privacy", style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text('Security and Privacy', style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text("Notifications", style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text("Bildirimler", style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}

class LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text('Language', style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text("Language", style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}

class DataSyncPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text('Data and Synchronization', style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text('Data and Synchronization', style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}

class AppSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text('App Settings', style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text('App Settings', style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}

class FeedbackSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text('Feedback and Support', style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text('Feedback and Support', style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBar,
        centerTitle: true,
        title: Text('About', style: TextStyle(color: theme.welcomeText)).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: Center(child: Text('About', style: TextStyle(color: theme.welcomeText)).tr()),
    );
  }
}
