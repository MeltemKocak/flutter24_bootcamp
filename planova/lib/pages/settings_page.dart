import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            Navigator.of(context).pop(true);
          },
        ),
        elevation: 0,
        flexibleSpace: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Text(
                  'Settings',
                  style: GoogleFonts.didactGothic(
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
            title: tr("Themes"),
            icon: Icons.color_lens,
            onTap: _showThemeDialog,
          ),
          _buildListTile(
            context,
            title: tr("Language"),
            icon: Icons.language,
            onTap: _showLanguageDialog,
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
      title: Text(title,
          style: GoogleFonts.didactGothic(color: theme.welcomeText)),
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
          title: Text("Select Theme",
                  style: GoogleFonts.didactGothic(color: theme.welcomeText))
              .tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(context, tr("Daylight Tracker"), 1),
              _buildThemeOption(context, tr("Cyber Planner"), 2),
              _buildThemeOption(context, tr("Pastel Habit Tracker"), 3),
              _buildThemeOption(context, tr("Purple Night Planner"), 4),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Provider.of<ThemeProvider>(context).currentTheme;
        return AlertDialog(
          backgroundColor: theme.background,
          title: Text("Select Language",
                  style: GoogleFonts.didactGothic(color: theme.welcomeText))
              .tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, "English", const Locale('en', 'US'),
                  'assets/images/flags/uk.png'),
              _buildLanguageOption(context, "Turkish", const Locale('tr', 'TR'),
                  'assets/images/flags/turkey.png'),
              _buildLanguageOption(context, "German", const Locale('de', 'DE'),
                  'assets/images/flags/germany.png'),
              _buildLanguageOption(context, "Spanish", const Locale('es', 'ES'),
                  'assets/images/flags/spain.png'),
              _buildLanguageOption(context, "French", const Locale('fr', 'FR'),
                  'assets/images/flags/france.png'),
              _buildLanguageOption(context, "Chinese", const Locale('zh', 'CN'),
                  'assets/images/flags/china.png'),
              _buildLanguageOption(context, "Russian", const Locale('ru', 'RU'),
                  'assets/images/flags/russia.png'),
              _buildLanguageOption(
                  context,
                  "Japanese",
                  const Locale('ja', 'JP'),
                  'assets/images/flags/japan.png'),
              _buildLanguageOption(context, "Hindi", const Locale('hi', 'IN'),
                  'assets/images/flags/india.png'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
      BuildContext context, String themeName, int themeValue) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return ListTile(
      title: Text(themeName,
          style: GoogleFonts.didactGothic(color: theme.welcomeText)),
      onTap: () {
        Provider.of<ThemeProvider>(context, listen: false)
            .setThemeValue(themeValue);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageName,
      Locale locale, String flagPath) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return ListTile(
      title: Row(
        children: [
          Image.asset(flagPath,
              width: 30, height: 20),
          const SizedBox(width: 10),
          Text(languageName,
              style: GoogleFonts.didactGothic(color: theme.welcomeText)),
        ],
      ),
      onTap: () async {
        await context.setLocale(locale);
        Navigator.of(context).pop(true);
        setState(() {});
      },
    );
  }
}

class FeedbackSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        centerTitle: true,
        title: Text(
          'feedback_and_support',
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ).tr(),
        leading: IconButton(
  icon: Icon(Icons.arrow_back_ios, color: theme.welcomeText),
  onPressed: () {
    Navigator.of(context).pop(true);
  },
)

      ),
      backgroundColor: theme.background,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('social_media_links'),
          _buildSectionContent(
            'social_media_content',
            theme.welcomeText,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('faq'),
          _buildSectionContent(
            'faq_content',
            theme.welcomeText,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('contact_support'),
          _buildSectionContent(
            'contact_support_content',
            theme.welcomeText,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('visit_our_website'),
          _buildSectionContent(
            'visit_our_website_content',
            theme.welcomeText,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String titleKey) {
    return Text(
      titleKey,
      style:
          GoogleFonts.didactGothic(fontSize: 20, fontWeight: FontWeight.bold),
    ).tr();
  }

  Widget _buildSectionContent(String contentKey, Color textColor) {
    return Text(
      contentKey,
      style: GoogleFonts.didactGothic(color: textColor, fontSize: 16),
    ).tr();
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        centerTitle: true,
        title: Text(
          'about',
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ).tr(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.loginTextAndBorder),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: theme.background,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'about_planova'),
          _buildSectionContent(context, 'about_description'),
          const SizedBox(height: 16),
          _buildSectionTitle(context, 'planova_features'),
          _buildFeatureList(context),
          const Divider(height: 32),
          _buildSectionContent(context, 'design_interface'),
          const Divider(height: 32),
          _buildSectionTitle(context, 'team_members'),
          _buildTeamList(context),
          const Divider(height: 32),
          _buildSectionTitle(context, 'contact_us'),
          _buildSectionContent(context, 'contact_info'),
          const Divider(height: 32),
          _buildSectionContent(context, 'managing_time'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        titleKey,
        style: GoogleFonts.didactGothic(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText,
        ),
      ).tr(),
    );
  }

  Widget _buildSectionContent(BuildContext context, String contentKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        contentKey,
        style: GoogleFonts.didactGothic(
          fontSize: 16,
          color: Provider.of<ThemeProvider>(context).currentTheme.welcomeText,
        ),
      ).tr(),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final features = [
      'goal_setting',
      'diary_notes',
      'todo_list',
      'detailed_analysis',
      'ai_stories'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: theme.welcomeText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feature,
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ).tr(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTeamList(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final teamMembers = [
      'melisa_role',
      'olgun_role',
      'meltem_role',
      'oguzhan_role',
      'onur_role'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: teamMembers.map((member) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: theme.welcomeText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  member,
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ).tr(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
