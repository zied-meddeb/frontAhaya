import 'package:flutter/material.dart';

import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import 'package:shop/route/screen_export.dart';

import '../../../services/auth_service.dart';
import '../../../services/favoris_service.dart';

import '../../favoris/views/login_pop_up.dart';

import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';


class ProductDetailsScreen extends StatefulWidget {
   ProductDetailsScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final AuthService _auth = AuthService();

  final FavoritesService _favoritesService = FavoritesService();
  bool isLoading = true;
  bool isLoggedIn = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      isLoggedIn = await _auth.isLoggedIn();
      if (isLoggedIn) {
        final user = await _auth.getUserId();
       isFavorite = await _favoritesService.isFavorite(user!, widget.product.id);
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error checking auth status: $e');
    }
  }

  Future<void> addToFavorites() async {

    try {
      final userId = await _auth.getUserId();
      final response=await _favoritesService.addFavorite(userId as String, widget.product.id);
      print("response $response");
      setState(() {
        isFavorite=!isFavorite;
      });


        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opération réussie'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ));

    } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error occurred: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                isFavorite?

                IconButton(
                    onPressed: () {
                      print("testtiinggggg $isLoggedIn");
                      isLoggedIn?addToFavorites():_showDiscountModal();},

                    icon: Icon(Icons.favorite,
                      color: Colors.red,
                    )
                ):

                IconButton(
                  onPressed: ()  {isLoggedIn?addToFavorites():_showDiscountModal();},

                  icon: Icon(Icons.favorite_border_outlined,
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                )


                ,
              ],
            ),
            ProductImages(
              images: [widget.product.image, productDemoImg2, productDemoImg3],
            ),
            ProductInfo(
              brand: widget.product.brandName,
              title: widget.product.title,
              isAvailable: true,
              description: widget.product.description,
              rating: 4.4,
              numOfReviews: 126,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "Product Details",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.3,
                  numOfReviews: 128,
                  numOfFiveStar: 80,
                  numOfFourStar: 30,
                  numOfThreeStar: 5,
                  numOfTwoStar: 4,
                  numOfOneStar: 1,
                ),
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: index == 4 ? defaultPadding : 0),
                    child: ProductCard(
                      id: "1",
                      image: productDemoImg2,
                      title: "Sleeveless Tiered Dobby Swing Dress",
                      brandName: "LIPSY LONDON",
                      price: 24.65,
                      priceAfetDiscount: index.isEven ? 20.99 : null,
                      dicountpercent: index.isEven ? 25 : null,
                      press: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
