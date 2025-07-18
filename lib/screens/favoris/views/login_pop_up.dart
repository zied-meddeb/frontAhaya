import 'package:flutter/material.dart';

class DiscountModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 320,
        color: Colors.white,
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header avec titre et bouton fermer
            Container(
              padding: EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produits remisés',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                    iconSize: 20,
                    color: Colors.grey[400],
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Contenu
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texte d'introduction
                  Text(
                    'Connectez-vous pour profiter des fonctionnalités de promotion !',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Liste des fonctionnalités
                  _buildFeatureItem(
                    icon: Icons.favorite_border,
                    text: 'Sélectionnez vos produits préférés',
                  ),

                  SizedBox(height: 16),

                  _buildFeatureItem(
                    icon: Icons.notifications_none,
                    text: 'Recevez des notifications de baisse de prix pour vos produits préférés',
                  ),

                  SizedBox(height: 16),

                  _buildFeatureItem(
                    icon: Icons.track_changes,
                    text: 'Recevez des alertes de prix souhaités pour vos produits préférés',
                  ),

                  SizedBox(height: 16),

                  _buildFeatureItem(
                    icon: Icons.star_border,
                    text: 'Donnez votre avis sur tous les produits',
                  ),

                  SizedBox(height: 24),

                  // Bouton OK
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        minimumSize: Size(0, 32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[400],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
