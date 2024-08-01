import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoViewPage extends StatelessWidget {
  final String imageUrl;

  const PhotoViewPage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.welcomeText, size: 30), // Increase the size and change the color
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Photo Viewer',
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          backgroundDecoration: BoxDecoration(color: theme.background),
        ),
      ),
      backgroundColor: theme.background,
    );
  }
}
