import 'package:flutter/material.dart';
import '../../../constants.dart';




class CompactProductCard extends StatelessWidget {
  final dynamic product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool isListView;

  const CompactProductCard({
    Key? key,
    required this.product,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.isListView = false,
  }) : super(key: key);

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 14,
          color: index < rating.floor() ? Colors.amber : Colors.grey[300],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isListView) {
      return _buildListView();
    }
    return _buildGridView();
  }

  Widget _buildListView() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Larger image container
            Stack(
              children: [
                Container(
                  width: 110, // Increased from 90 to 120
                  height: 110, // Increased from 90 to 120
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Text(
                              'Image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color:  Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.dicountpercent} %',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 15), // Increased spacing
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16, // Slightly larger font
                          ),
                          maxLines: 2, // Allow 2 lines for longer names
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onToggleFavorite,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? primaryColor : blackColor40,
                          size: 22, // Slightly larger icon
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStars(4),
                      SizedBox(width: 6),
                      Text(
                        '(5)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 18, // Larger price font
                        ),
                      ),

                        SizedBox(width: 8),
                        Text(
                          '${product.priceAfetDiscount!.toStringAsFixed(2)} DT',
                          style: TextStyle(
                            fontSize: 13, // Slightly larger font
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
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
    );
  }

  Widget _buildGridView() {
    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image part (unchanged size)
          Expanded(
            flex: 3, // Kept the same to maintain image size
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Text(
                              'Image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.dicountpercent} %',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? primaryColor : blackColor40,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content part (made bigger)
          Expanded(
            flex: 3, // Changed from 2 to 3 to give more space
            child: Padding(
              padding: EdgeInsets.all(14), // Increased padding from 8 to 10
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4), // Increased from 2 to 6
                  Row(
                    children: [
                      _buildStars(4),
                      SizedBox(width: 4), // Increased from 2 to 4
                      Text(
                        '(4)',
                        style: TextStyle(
                          fontSize: 12, // Increased from 11 to 12
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 16,
                        ),
                      ),

                        SizedBox(width: 4), // Increased from 4 to 6
                        Text(
                          '${product.priceAfetDiscount!.toStringAsFixed(2)} DT',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),

                    ],
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
