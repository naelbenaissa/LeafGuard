import 'package:flutter/material.dart';

Widget mesPlantesSection() {
  final plantes = [
    {
      'name': 'Pink Gerbera',
      'image': 'assets/img/plantes/pink_gerbera.png',
      'days': 10
    },
    {
      'name': 'Nest Fern',
      'image': 'assets/img/plantes/nest_fern.png',
      'days': 26
    },
    {
      'name': 'Young Banana',
      'image': 'assets/img/plantes/young_banana.png',
      'days': 27
    },
    {'name': 'Dahlia', 'image': 'assets/img/plantes/dahlia.png', 'days': 8},
    {
      'name': 'Pink Gerbera',
      'image': 'assets/img/plantes/pink_gerbera.png',
      'days': 10
    },
    {
      'name': 'Nest Fern',
      'image': 'assets/img/plantes/nest_fern.png',
      'days': 26
    },
    {
      'name': 'Young Banana',
      'image': 'assets/img/plantes/young_banana.png',
      'days': 27
    },
    {'name': 'Dahlia', 'image': 'assets/img/plantes/dahlia.png', 'days': 8},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Mes Plantes",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: plantes.length,
          itemBuilder: (context, index) {
            final plante = plantes[index];

            return Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        plante['image'] as String,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          value: (plante['days'] as int) / 30,
                          backgroundColor: Colors.grey[300],
                          color: Colors.green,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plante['name'] as String,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${plante['days']} jours avant arrosage",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ),
    ],
  );
}
