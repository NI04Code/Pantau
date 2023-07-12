import 'package:flutter/material.dart';
class SearchBarWidget extends StatefulWidget {
  final void Function(String) onSearch;
  final String hintText;

  SearchBarWidget({required this.onSearch, required this.hintText});

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    String searchTerm = _searchController.text.trim();
    widget.onSearch(searchTerm);
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.blue,),
            onPressed: _handleSearch,
          ),
        ],
      ),
    );
  }
}