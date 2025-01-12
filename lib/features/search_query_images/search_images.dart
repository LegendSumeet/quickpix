import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ImgViewScreen(imageSrc: images[index])));
                  },
                  child: ImageWidget(
                      size: ImageSize.portrait,
                      key: ValueKey(images[index].id),
                      src: images[index]),
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
