import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picpixels/features/curated_pic/curated_pics_bloc.dart';
import 'package:picpixels/features/curated_pic/curated_pics_event.dart';
import 'package:picpixels/features/curated_pic/curated_pics_state.dart';
import 'package:picpixels/features/img/img.dart';
import 'package:picpixels/model/image_src.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:picpixels/screens/img_view_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CuratedPicWidget extends StatefulWidget {
  const CuratedPicWidget({super.key});

  @override
  State<CuratedPicWidget> createState() => _CuratedPicWidgetState();
}

class _CuratedPicWidgetState extends State<CuratedPicWidget> {
  @override
  void initState() {
    super.initState();
    context.read<CuratedPicsBloc>().add(FetchCuratedPics(page: 1, perPage: 10));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CuratedPicsBloc, CuratedPicsState>(
      builder: (context, state) {
        if (state is CuratedPicsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CuratedPicsLoaded) {
          List<ImageSrc> images = state.pictures;

          return Skeletonizer(
            enabled: state is CuratedPicsLoading,
            child: MasonryGridView.builder(
              shrinkWrap: true,
              addAutomaticKeepAlives: true,
              physics: const BouncingScrollPhysics(), // Disables inner scrolling.

              addRepaintBoundaries: true,
              key: const PageStorageKey('curated_pics'),
              gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              itemBuilder: (context, index) {
                return AnimatedImageTile(
                  index: index,
                  image: images[index],
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ImgViewScreen(imageSrc: images[index]),
                    ));
                  },
                );
              },
              itemCount: images.length,
            ),
          );
        } else if (state is CuratedPicsError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class AnimatedImageTile extends StatefulWidget {
  final dynamic image; // Replace `dynamic` with your image model type
  final VoidCallback onTap;
  final int index;

  const AnimatedImageTile({
    Key? key,
    required this.image,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedImageTile> createState() => _AnimatedImageTileState();
}

class _AnimatedImageTileState extends State<AnimatedImageTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start animation when the widget is built
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageSize _getSizeForIndex(int index) {
      final sizes = [
        ImageSize.large,
        ImageSize.medium,
        ImageSize.portrait,
        ImageSize.landscape,
      ];
      return sizes[index % sizes.length];
    }

    return FadeTransition(
      opacity: _opacityAnimation,
      child: InkWell(
        onTap: widget.onTap,
        child: ImageWidget(
          size: _getSizeForIndex(widget.index),
          key: ValueKey(widget.image.id),
          src: widget.image,
        ),
      ),
    );
  }
}
