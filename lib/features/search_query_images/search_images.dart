import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:picpixels/features/camera/camera.dart';
import 'package:picpixels/features/img/img.dart';
import 'package:picpixels/features/search_query_images/search_query_app_cubit.dart';
import 'package:picpixels/model/image_src.dart';
import 'package:picpixels/screens/img_view_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ImageSearchWidget extends StatefulWidget {
  final String query;
  const ImageSearchWidget({super.key, required this.query});

  @override
  State<ImageSearchWidget> createState() => _ImageSearchWidgetState();
}

class _ImageSearchWidgetState extends State<ImageSearchWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query),
      ),
      body: BlocProvider<SearchQueryAppCubit>(
        create: (context) => SearchQueryAppCubit(query: widget.query),
        child: const SearchResultsWidget(),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({super.key});

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SearchQueryAppCubit, SearchQueryAppState>(
      builder: (context, state) {
        if (state is SearchQueryAppInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SearchQueryAppLoaded) {
          List<ImageSrc> images = state.suggestions;
          return Skeletonizer(
            enabled: state is SearchQueryAppLoading,
            child: MasonryGridView.builder(
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              key: const PageStorageKey('search_pics'),
              gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImgViewScreen(imageSrc: images[index])));
                  },
                  child: ImageWidget(size: ImageSize.portrait, key: ValueKey(images[index].id), src: images[index]),
                );
              },
              itemCount: images.length,
            ),
          );
        } else if (state is SearchQueryAppError) {
          return Center(child: Text(state.error));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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

  List<String> searchResults = [];
  String query = '';

  void search(String query) {
    setState(() {
      this.query = query;
      searchResults = suggestions.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Text(
          "Tap the camera button to search for free stock images by capturing a photo of an object.",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraPage(),
            ),
          );
        },
        child: const Icon(Icons.camera),
      ),
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            autofocus: true,
            autofillHints: suggestions,
            onFieldSubmitted: (value) {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => ImageSearchWidget(
                   query: value,
                 ),
               ),
             );
            },
            onChanged: search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
              prefixIcon: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: query.isEmpty
            ? Center(
                child: Text(
                  'Search for something...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : searchResults.isEmpty
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageSearchWidget(
                              query: query,
                            ),
                          ),
                        );
                      },
                      child: Text('Search with "$query"'),
                    ),
                  )
                : ListView.builder(
                    key: ValueKey(query), // For AnimatedSwitcher to work
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.bounceIn,
                        child: ListTile(
                          title: Text(
                            searchResults[index],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageSearchWidget(
                                  query: searchResults[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
