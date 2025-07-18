import 'package:flutter/material.dart';
import 'package:shop/screens/favoris/views/login_pop_up.dart';
import 'package:shop/services/favoris_service.dart';

import '../../constants.dart';
import '../../services/auth_service.dart';
import '../network_image_with_loader.dart';

class ProductCard extends StatefulWidget {
  ProductCard({
    super.key,
    required this.id,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    required this.press,
    this.isFavorite = false,
    this.onFavoritePressed,
  });
  final String image, brandName, title, id;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final VoidCallback press;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isLoggedIn = false;
  late bool _isFavorite;

  final AuthService _auth = AuthService();
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _auth.isLoggedIn();
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
      });
    }
  }

  void _showDiscountModal() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => DiscountModal(),
    );
  }

  Future<void> addToFavorites() async {
    if (!mounted) return;

    try {
      final userId = await _auth.getUserId();
      await _favoritesService.addFavorite(userId as String, widget.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opération réussie'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ));
        }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error occurred: ${e.toString()}"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 220,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.press,
            child: AspectRatio(
              aspectRatio: 1.15,
              child: Stack(
                children: [
                  NetworkImageWithLoader(widget.image, radius: defaultBorderRadious),
                  Positioned(
                    left: defaultPadding / 2,
                    top: defaultPadding / 2,
                    child: GestureDetector(
                      onTap: () async {
                        if (widget.onFavoritePressed == null) return;

                        if (isLoggedIn) {
                          await addToFavorites();
                          if (mounted) {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          }
                          widget.onFavoritePressed!();
                        } else {
                          _showDiscountModal();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: _isFavorite ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  if (widget.dicountpercent != null)
                    Positioned(
                      right: defaultPadding / 2,
                      top: defaultPadding / 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                        height: 16,
                        decoration: const BoxDecoration(
                          color: errorColor,
                          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
                        ),
                        child: Text(
                          "${widget.dicountpercent}% off",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2,
                  vertical: defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.press,
                    child: Text(
                      widget.brandName.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  GestureDetector(
                    onTap: widget.press,
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (widget.priceAfetDiscount != null)
                        Text(
                          "${widget.priceAfetDiscount} DT",
                          style: const TextStyle(
                            color: Color(0xFF31B0D8),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      if (widget.priceAfetDiscount != null)
                        const SizedBox(width: defaultPadding / 4),
                      Text(
                        "${widget.price} DT",
                        style: TextStyle(
                          color: widget.priceAfetDiscount == null
                              ? const Color(0xFF31B0D8)
                              : Theme.of(context).textTheme.bodyMedium!.color,
                          fontWeight: widget.priceAfetDiscount == null
                              ? FontWeight.w500
                              : null,
                          fontSize: widget.priceAfetDiscount == null ? 12 : 10,
                          decoration: widget.priceAfetDiscount != null
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
