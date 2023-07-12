import 'package:flutter/material.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/widgets/tile_discussion.dart';
class SearchDiscussionScreen extends StatefulWidget {
  final String initialValue;
  final List<DiscussionThread> threads;
  final PostinganKasus kasus;
  const SearchDiscussionScreen({super.key, required this.initialValue, required this.threads, required this.kasus});
  @override
  _SearchDiscussionScreenState createState() => _SearchDiscussionScreenState();
}

class _SearchDiscussionScreenState extends State<SearchDiscussionScreen> {
  TextEditingController? _searchController;
  List<DiscussionThread>? searchFilter;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue);
    searchFilter = widget.threads.where((thread) =>
        thread.title.toLowerCase().contains(_searchController!.text.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController!.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      searchFilter =  widget.threads.where((thread) =>
          thread.title.toLowerCase().contains(_searchController!.text.trim().toLowerCase())).toList();
      // TODO: Lakukan pencarian diskusi berdasarkan _searchText
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        title: Text('Cari Diskusi', style:  TextStyle(color: Colors.black),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Diskusi...',
                      border:  OutlineInputBorder()
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _performSearch,
                  icon: Icon(Icons.search_rounded, color: Colors.blue,),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            child: Text(
              'Pencarian untuk: ${_searchController!.text}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(child: searchFilter!.isEmpty? Center(
            child: Text('Tidak ada yang relevan dengan pencarianmu', style: TextStyle(color: Colors.black),),
          ):ListView.builder(itemCount: searchFilter!.length, itemBuilder: (context, index){
            DiscussionThread thread = searchFilter![index];
            return CustomListTile(
                title: thread.title, username: thread.author,
                thumbnailUrls: thread.thumbnail, likeCount: thread.upvotes.length,
                downvoteCount: thread.downvotes.length, commentCount: thread.comments.length,
                postedAt: thread.postedAt, profilePictureurl: thread.profilePhoto, id: thread.id,
                threads: thread, post: widget.kasus);
          }))

        ],
      ),
    );
  }
}