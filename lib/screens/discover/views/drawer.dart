import 'package:flutter/material.dart';

/// Represents a node in the category tree.
class CategoryNode {
  final String name;
  final Map<String, CategoryNode> children;
  final Map<String, dynamic>? data;

  CategoryNode({
    required this.name,
    this.children = const {},
    this.data,
  });
}

class FilterDrawer extends StatefulWidget {
  final String searchTerm;
  final Function(String) onSearchChanged;
  final List<dynamic> categories;
  final Function(String, bool) onCategoryChanged;
  final VoidCallback onClearFilters;
  final List<String> searchSuggestions;
  final Function(String) onSuggestionSelected;
  final FocusNode searchFocusNode;

  const FilterDrawer({
    Key? key,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.categories,
    required this.onCategoryChanged,
    required this.onClearFilters,
    required this.searchSuggestions,
    required this.onSuggestionSelected,
    required this.searchFocusNode,
  }) : super(key: key);

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late TextEditingController _searchController;
  late Map<String, CategoryNode> categoryTree;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchTerm);
    categoryTree = buildCategoryTree(widget.categories);
  }

  @override
  void didUpdateWidget(FilterDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchTerm != _searchController.text) {
      _searchController.text = widget.searchTerm;
    }
    categoryTree = buildCategoryTree(widget.categories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds a hierarchical tree from the flat categories list.
  Map<String, CategoryNode> buildCategoryTree(List<dynamic> flatCategories) {
    final Map<String, CategoryNode> root = {};

    for (var cat in flatCategories) {
      final hierarchies = cat['hierarchies'];
      if (hierarchies == null) continue;

      // Convert to list of paths
      List<List<String>> paths = [];
      if (hierarchies is String) {
        paths = [hierarchies.split('/')];
      } else if (hierarchies is List) {
        paths = List<String>.from(hierarchies).map((e) => e.split('/')).toList();
      }

      for (var path in paths) {
        Map<String, CategoryNode> current = root;
        for (int i = 0; i < path.length; i++) {
          final segment = path[i];
          if (!current.containsKey(segment)) {
            current[segment] = CategoryNode(name: segment, children: {}, data: null);
          }
          if (i == path.length - 1) {
            // attach data only at the leaf node
            current[segment] = CategoryNode(
              name: segment,
              children: current[segment]!.children,
              data: cat,
            );
          }
          current = current[segment]!.children;
        }
      }
    }
    return root;
  }

  /// Recursively builds ExpansionTiles and checkboxes.
  Widget buildCategoryTiles(Map<String, CategoryNode> tree) {
    return Column(
      children: tree.entries.map((entry) {
        final node = entry.value;
        if (node.children.isNotEmpty) {
          return ExpansionTile(
            title: Text(node.name),
            children: [buildCategoryTiles(node.children)],
          );
        }
        if (node.data != null) {
          return CheckboxListTile(
            title: Text(
              '${node.name} (${node.data!['count'] ?? 0})',
              style: TextStyle(fontSize: 14),
            ),
            value: node.data!['checked'] ?? false,
            onChanged: (value) => widget.onCategoryChanged(node.data!['id'], value!),
            dense: true,
            contentPadding: EdgeInsets.only(left: 16),
          );
        }
        return SizedBox.shrink();
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: widget.searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Rechercher des catégories...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: widget.onSearchChanged,
                      ),
                      if (widget.searchSuggestions.isNotEmpty)
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            child: Column(
                              children: widget.searchSuggestions.map((suggestion) {
                                return ListTile(
                                  title: Text(suggestion),
                                  onTap: () {
                                    widget.onSuggestionSelected(suggestion);
                                    widget.searchFocusNode.unfocus();
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      Text('Catégories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                      SizedBox(height: 12),
                      buildCategoryTiles(categoryTree),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Filtrer'),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                widget.onClearFilters();
                                Navigator.pop(context);
                              },
                              child: Text('Annuler'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
