import 'package:flutter/material.dart';
import '../providers/offer_provider.dart';
import '../theme/app_theme.dart';

class OfferStatsCards extends StatelessWidget {
  final OfferProvider offerProvider;

  const OfferStatsCards({
    super.key,
    required this.offerProvider,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': 'Total Offres',
        'value': offerProvider.totalOffers.toString(),
        'icon': Icons.business_center,
        'gradient': SupplierTheme.blueGradient,
      },
      {
        'title': 'Offres Actives',
        'value': offerProvider.activeOffers.toString(),
        'icon': Icons.check_circle,
        'gradient': SupplierTheme.emeraldGradient,
      },
      {
        'title': 'Total Vues',
        'value': offerProvider.totalViews.toString(),
        'icon': Icons.visibility,
        'gradient': LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Réservations',
        'value': offerProvider.totalBookings.toString(),
        'icon': Icons.people,
        'gradient': SupplierTheme.orangeGradient,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          decoration: BoxDecoration(
            gradient: stat['gradient'] as LinearGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat['title'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  stat['icon'] as IconData,
                  color: Colors.white.withOpacity(0.7),
                  size: 32,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 2;
    return 1;
  }
}
