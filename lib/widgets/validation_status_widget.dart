import 'package:flutter/material.dart';
import '../models/offer.dart';

class ValidationStatusWidget extends StatelessWidget {
  final List<Offer> offers;

  const ValidationStatusWidget({
    super.key,
    required this.offers,
  });

  @override
  Widget build(BuildContext context) {
    final pendingOffers = offers.where((o) => o.status == OfferStatus.pendingValidation).toList();
    final rejectedOffers = offers.where((o) => o.status == OfferStatus.rejected).toList();

    if (pendingOffers.isEmpty && rejectedOffers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Offres en attente
        if (pendingOffers.isNotEmpty) ...[
          Card(
            color: const Color(0xFFF5F5F5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: const Color(0xFF000000)),
                      const SizedBox(width: 8),
                      Text(
                        'Offres en attente de validation (${pendingOffers.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...pendingOffers.take(3).map((offer) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Soumise le ${_formatDate(offer.submittedAt!)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.hourglass_empty, size: 12, color: const Color(0xFF000000)),
                                SizedBox(width: 4),
                                Text(
                                  'En validation',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: const Color(0xFF000000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  if (pendingOffers.length > 3)
                    Text(
                      '+${pendingOffers.length - 3} autres offres en attente...',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF424242),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 16, color: const Color(0xFF000000)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Temps de validation habituel : 24-48 heures ouvrables',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Offres rejetées
        if (rejectedOffers.isNotEmpty) ...[
          Card(
            color: const Color(0xFFF5F5F5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel, color: const Color(0xFF757575)),
                      const SizedBox(width: 8),
                      Text(
                        'Offres rejetées (${rejectedOffers.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...rejectedOffers.take(2).map((offer) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  offer.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cancel, size: 12, color: const Color(0xFF757575)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Rejetée',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: const Color(0xFF757575),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (offer.rejectionReason != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Raison :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    offer.rejectionReason!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rejetée le ${_formatDate(offer.validatedAt!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.edit, size: 12),
                                label: const Text('Modifier', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF000000),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
