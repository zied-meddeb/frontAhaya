import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';

class ProfileNotConnected extends StatefulWidget {
  const ProfileNotConnected({super.key});

  @override
  State<ProfileNotConnected> createState() => _ProfileNotConnectedState();
}

class _ProfileNotConnectedState extends State<ProfileNotConnected> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header text
              const Text(
                'Connectez-vous pour la meilleure expérience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 24),

              // Sign in button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, logInScreenRoute);
                },
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5C518),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),)
              ),
              const SizedBox(height: 12),

              // Create account button
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, signUpScreenRoute);

                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Bonus features section
              const FeatureItem(
                icon: Icons.favorite,
                color: Colors.red,
                title: 'Favoris',
                description: 'Ajoutez vos produits préférés à votre liste de favoris',
              ),
              const SizedBox(height: 20),

              const FeatureItem(
                icon: Icons.recommend,
                color: Colors.purple,
                title: 'Préférences',
                description: 'Recevez des suggestions de produits selon vos préférences',
              ),
              const SizedBox(height: 20),

              const FeatureItem(
                icon: Icons.card_giftcard,
                color: Colors.lightBlue,
                title: 'Bonus exclusifs',
                description: 'Découvrez vos avantages et bonus personnalisés',
              ),
              const SizedBox(height: 20),

              const FeatureItem(
                icon: Icons.handshake,
                color: Colors.green,
                title: 'Programme partenaires',
                description: 'Accédez aux offres spéciales de nos partenaires',
              ),
              const SizedBox(height: 20),

              const FeatureItem(
                icon: Icons.star,
                color: Colors.amber,
                title: 'Contenu Ahaya',
                description: 'Profitez de contenus exclusifs et personnalisés',
              ),
            ],
          ),
        ),
      ),
    );

  }
}


class FeatureItem extends StatelessWidget {
  final IconData icon;
  final MaterialColor color;
  final String title;
  final String description;

  const FeatureItem({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 30,
            color: color[600],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
