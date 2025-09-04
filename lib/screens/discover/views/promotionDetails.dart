import 'package:flutter/material.dart';
import '../../../models/promotion.dart';
import '../../../route/route_constants.dart';

/// Register this screen in your routes with [promotionDetailsRoute]
/// Example: routes: { promotionDetailsRoute: (ctx) => PromotionDetailsScreen() }
class PromotionDetailsScreen extends StatelessWidget {
  final Promotion promotion;
  const PromotionDetailsScreen({super.key, required this.promotion});


  @override
  Widget build(BuildContext context) {
    final promotion = ModalRoute.of(context)!.settings.arguments as Promotion;

    return Scaffold(
      appBar: AppBar(
        title: Text(promotion.titre),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images carousel
              if (promotion.afficheUrls.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: promotion.afficheUrls.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          promotion.afficheUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Price
              Row(
                children: [
                  Text(
                    '${promotion.prixOffre.toStringAsFixed(2)} DT',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${promotion.prixOriginal.toStringAsFixed(2)} DT',
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Date range
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Du ${promotion.dateDebut.toLocal().toShortDateString()} au ${promotion.dateFin.toLocal().toShortDateString()}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                promotion.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(height: 24),
              // Action button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: add logic to apply promotion or view products
                  },
                  child: const Text('Voir les produits'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper extension for formatting date
extension DateHelpers on DateTime {
  String toShortDateString() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
