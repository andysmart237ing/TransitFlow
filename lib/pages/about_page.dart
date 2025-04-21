import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget réutilisable pour le contenu "À propos"
class AboutContent extends StatelessWidget {
  final double avatarRadius;
  const AboutContent({this.avatarRadius = 60, super.key});

  // À personnaliser
  static const _avatarUri = 'assets/images/AvatarAndy.png';
  static const _name = 'Andy SIWA';
  static const _role = 'Ingénieur électricien et développeur';
  static const _bio =
      "Passionné par le développement logiciel, j’ai travaillé sur plusieurs projets open-source. Je sais fournir des solutions logicielles pratiques et esthétiques, et j'aime partager mes compétences et travailler en équipe.";
  static const _email = 'mailto:blendy03ing@gmail.com';
  static const _linkedin = 'https://www.linkedin.com/in/andy-kammoe-180283199';
  static const _phone = 'https://wa.me/237652481643';
  static const _facebook =
      'https://www.facebook.com/profile.php?id=100069460269257';

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Impossible d'ouvrir l'$url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          child: Image.asset(
            _avatarUri,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _role,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(
          _bio,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.email),
              tooltip: 'Gmail',
              onPressed: () => _launchUrl(_email),
            ),
            IconButton(
              icon: const Icon(Icons.account_box_rounded),
              tooltip: 'LinkedIn',
              onPressed: () => _launchUrl(_linkedin),
            ),
            IconButton(
              icon: const Icon(Icons.facebook_rounded),
              tooltip: 'Facebook',
              onPressed: () => _launchUrl(_facebook),
            ),
            IconButton(
              icon: const Icon(Icons.message),
              tooltip: 'Whatsapp',
              onPressed: () => _launchUrl(_phone),
            ),
          ],
        ),
      ],
    );
  }
}

/// Page complète "À propos"
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: AboutContent(),
      ),
    );
  }
}

/// Sheet modal pour afficher "À propos" en bas
class AboutModalSheet extends StatelessWidget {
  const AboutModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(16),
          child: AboutContent(),
        );
      },
    );
  }
}

/// Fonction helper pour afficher le modal
void showAboutModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const AboutModalSheet(),
  );
}
