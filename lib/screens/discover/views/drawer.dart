import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchTerm);
  }

  @override
  void didUpdateWidget(FilterDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchTerm != _searchController.text) {
      _searchController.text = widget.searchTerm;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            focusNode: widget.searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Rechercher des produits...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            onChanged: widget.onSearchChanged,
                          ),
                          if (widget.searchSuggestions.isNotEmpty)
                            Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final suggestion
                                    in widget.searchSuggestions)
                                      ListTile(
                                        title: Text(suggestion),
                                        onTap: () {
                                          widget.onSuggestionSelected(suggestion);
                                          widget.searchFocusNode.unfocus();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Catégories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 12),
                      ...widget.categories.map((category) => CheckboxListTile(
                        title: Text(
                          '${category['name'] ?? 'Unknown Category'} (${category['count'] ?? 0})',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: category['checked'] ?? false,
                        onChanged: (value) =>
                            widget.onCategoryChanged(category['id'], value!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      )),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                              ),
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
