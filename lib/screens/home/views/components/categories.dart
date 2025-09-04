import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../../../services/categorie_service.dart';
import '../../../../models/Category.dart'; 

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  bool isLoading = true;
  int selectedIndex = -1;
  List<Category> categories = [];
  final CategoriesService _categoriesService = CategoriesService();

  Future<void> fetchData() async {
    try {
      final response = await _categoriesService.fetchCategories();
      print("categories $response");

      setState(() {
        categories = response
            .map<Category>((item) => Category.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(
                  categories.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? defaultPadding : defaultPadding / 2,
                      right: index == categories.length - 1
                          ? defaultPadding
                          : 0,
                    ),
                    child: CategoryBtn(
                      categoryName: categories[index].name,
                      isActive: index == selectedIndex,
                      press: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        // Tu peux rediriger vers une autre page ici si tu veux
                        // Navigator.pushNamed(context, '/someRoute', arguments: categories[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.categoryName,
    required this.isActive,
    required this.press,
  });

  final String categoryName;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Theme.of(context).dividerColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Center(
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
      ),
    );
  }
}
