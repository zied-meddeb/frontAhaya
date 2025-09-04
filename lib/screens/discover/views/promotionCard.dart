import 'package:flutter/material.dart';
import '../../../models/promotion.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final bool isListView;

  const PromotionCard({
    Key? key,
    required this.promotion,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.isListView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isListView ? _buildListView(context) : _buildGridView(context);
  }

  Widget _buildListView(BuildContext context) {
    final imageUrl = promotion.afficheUrls.isNotEmpty ? promotion.afficheUrls.first : null;
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: imageUrl == null
                  ? Center(child: Text('No image', style: TextStyle(color: Colors.grey)))
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.titre,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    promotion.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${promotion.prixOffre.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${promotion.prixOriginal.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onToggleFavorite != null)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onToggleFavorite,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final imageUrl = promotion.afficheUrls.isNotEmpty ? promotion.afficheUrls.first : null;
    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                color: Colors.grey[100],
                image: imageUrl != null
                    ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: imageUrl == null ? Center(child: Text('No image')) : null,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.titre,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Text(
                    '${promotion.prixOffre.toStringAsFixed(2)} DT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
                  Text(
                    '${promotion.prixOriginal.toStringAsFixed(2)} DT',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
