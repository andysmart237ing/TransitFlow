import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<int> onTabSelect;

  HomePage({super.key, required this.onTabSelect});

  final List menus = [
    {
      'titre': 'Air transit',
      'sous_titre': 'fret aérien',
      'icon': Icons.airplanemode_active,
    },
    {
      'titre': 'Sea transit',
      'sous_titre': 'fret maritime',
      'icon': Icons.directions_boat,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              "Veuillez choisir un moyen de transit",
              textAlign: TextAlign.center,
              style: GoogleFonts.signika(
                  textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              )),
            )
                .animate()
                .fadeIn(duration: 500.ms, begin: 0.8)
                .slideY(duration: 700.ms, begin: -0.3),
          ),
          Column(
            children: menus
                .asMap()
                .entries
                .map((items) {
                  int index = items.key;
                  Map menu = items.value;
                  return GestureDetector(
                      onTap: () {
                        onTabSelect(index + 1);
                      },
                      child: Card(
                        elevation: 5,
                        color: Colors.white.withAlpha(232),
                        margin: EdgeInsets.only(bottom: 25),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Icon(
                                  menu['icon'],
                                  size: 60,
                                  color: Colors.cyan,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      menu['titre'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      menu['sous_titre'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black.withAlpha(120),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                })
                .toList()
                .animate(interval: 500.ms)
                .then(delay: 600.ms)
                .fade(duration: 500.ms)
                .slideX(begin: -0.05),
          ),
        ],
      ),
    );
  }
}
