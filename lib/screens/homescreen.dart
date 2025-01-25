import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picpixels/dio/dio_client.dart';
import 'package:picpixels/features/curated_pic/curated_pic_widget.dart';
import 'package:picpixels/features/curated_pic/curated_pics_bloc.dart';
import 'package:picpixels/features/search_query_images/search_images.dart';
import 'package:picpixels/main.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  SearchController searchController = SearchController();
  FocusNode searchFocusNode = FocusNode();
  bool isExtended = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  List<String> suggestions = [
    'Nature',
    'City',
    'People',
    'Ocean',
    'Mountains',
    'Street',
    'Animals',
    'Flowers',
    'Abstract',
    'Architecture',
    'Forest',
    'Wildlife',
    'Space',
    'Sunset',
    'Food',
    'Sports',
    'Travel',
    'Technology',
    'Vintage',
    'Art',
    'Music',
    'Landscapes',
    'Night Sky',
    'Vehicles',
    'Fashion'
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));

        },
        child: const Icon(Icons.search),
      ),
      body: BlocProvider(
        create: (context) => CuratedPicsBloc(dioClient: DioClient()),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              backgroundColor: Colors.transparent,
              expandedHeight: 150.0,
              floating: false,
              pinned: false,
              centerTitle: true,
              title: Hero(
                tag: 'appLogo',
                child: Material(
                  color: Colors.transparent,
                  child: Image.asset(
                    'assets/logo/736x744logo.png',
                    height: 40,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          fadeInCurve: Curves.easeIn,
                          fadeInDuration: const Duration(milliseconds: 800),
                          fadeOutCurve: Curves.easeOut,
                          imageUrl:
                          'https://firebasestorage.googleapis.com/v0/b/pix-app-8160e.firebasestorage.app/o/home.jpg?alt=media&token=c2dc4d08-3a3e-4035-94e0-5ba55cae65c9',
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: CuratedPicWidget(
                    key: ValueKey('curated_pics'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  bool get wantKeepAlive => true;
}

class ImageSearchDelegate extends SearchDelegate<String> {
  final List<String> predefinedTerms = [
    'Nature',
    'City',
    'People',
    'Ocean',
    'Mountains',
    'Street',
    'Animals',
    'Flowers',
    'Abstract',
    'Architecture',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // Clear button
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Close and return empty string
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = predefinedTerms.where((term) => term.toLowerCase().contains(query.toLowerCase())).toList();

    return results.isEmpty
        ? _noResultsFound(context) // Display no results UI
        : _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? predefinedTerms : predefinedTerms.where((term) => term.toLowerCase().contains(query.toLowerCase())).toList();

    return _buildSuggestionsList(suggestions);
  }

  // Function to build list of results
  Widget _buildResultsList(List<String> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildResultTile(result);
      },
    );
  }

  // Function to build result tiles
  Widget _buildResultTile(String result) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        title: Text(result),
        leading: Icon(Icons.search),
        onTap: () {},
      ),
    );
  }

  // Function to build suggestions list
  Widget _buildSuggestionsList(List<String> suggestions) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(Icons.lightbulb_outline),
          title: Text(suggestion),
          onTap: () {
            query = suggestion; // Update the query
            showResults(context); // Show results for the selected suggestion
          },
        );
      },
    );
  }

  // Function to handle no results found UI
  Widget _noResultsFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No results found for "$query"',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              query = ''; // Clear the query
              showSuggestions(context); // Show suggestions again
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: Colors.blue),
                Text(' Try again', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void showSuggestions(BuildContext context) {
    super.showSuggestions(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: buildSuggestions(context),
          );
        },
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: const Icon(Icons.search),
      ),
      onPressed: () async {
        _controller.forward(from: 0); // Trigger the animation
        showSearch(context: context, delegate: ImageSearchDelegate());
      },
    );
  }
}
