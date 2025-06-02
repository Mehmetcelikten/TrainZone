import 'package:flutter/material.dart';

class ExerciseInfoCard extends StatelessWidget {
  final String name;
  final String muscleGroup;
  final String difficulty;
  final String equipment;
  final String imageUrl;
  final VoidCallback onTap;

  const ExerciseInfoCard({
    super.key,
    required this.name,
    required this.muscleGroup,
    required this.difficulty,
    required this.equipment,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white10,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.broken_image,
                        color: Colors.white70, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      muscleGroup,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.whatshot,
                            color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          difficulty,
                          style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        Icon(_getEquipmentIcon(equipment),
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            equipment,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'dambıl':
        return Icons.fitness_center;
      case 'halter':
        return Icons.sports_gymnastics;
      case 'makine':
        return Icons.devices;
      case 'kettlebell':
        return Icons.sports_mma;
      case 'bant':
        return Icons.linear_scale;
      case 'kablo':
        return Icons.cable;
      case 'vücut ağırlığı':
      default:
        return Icons.accessibility;
    }
  }
}
