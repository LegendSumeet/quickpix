import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picpixels/model/image_src.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ImageWidget extends StatefulWidget {
  final ImageSrc src;
  final ImageSize size;

  const ImageWidget({super.key, required this.src, required this.size});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Define animations
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Hero(
      tag: getImageUrl(widget.src.src, widget.size),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return Skeletonizer(
                      enabled: true,
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Stack(
                          children: [
                            Container(
                              color: Colors.grey[300],
                            ),
                            AnimatedOpacity(
                              opacity: downloadProgress.progress == null ? 1.0 : 0.5,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  cacheKey: getCacheImageKey(widget.src.src, widget.size),
                  imageUrl: getImageUrl(widget.src.src, widget.size),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}


enum ImageSize {
  original,
  large2x,
  large,
  medium,
  small,
  portrait,
  landscape,
  tiny
}

extension ImageSizeExtension on ImageSize {
  String get value {
    switch (this) {
      case ImageSize.original:
        return 'original';
      case ImageSize.large2x:
        return 'large2x';
      case ImageSize.large:
        return 'large';
      case ImageSize.medium:
        return 'medium';
      case ImageSize.small:
        return 'small';
      case ImageSize.portrait:
        return 'portrait';
      case ImageSize.landscape:
        return 'landscape';
      case ImageSize.tiny:
        return 'tiny';
    }
  }
}

String getImageUrl(Src src, ImageSize size) {
  switch (size) {
    case ImageSize.original:
      return src.original;
    case ImageSize.large2x:
      return src.large2X;
    case ImageSize.large:
      return src.large;
    case ImageSize.medium:
      return src.medium;
    case ImageSize.small:
      return src.small;
    case ImageSize.portrait:
      return src.portrait;
    case ImageSize.landscape:
      return src.landscape;
    case ImageSize.tiny:
      return src.tiny;
  }
}

String getCacheImageKey(Src src, ImageSize size) {
  switch (size) {
    case ImageSize.original:
      return src.original;
    case ImageSize.large2x:
      return src.large2X;
    case ImageSize.large:
      return src.large;
    case ImageSize.medium:
      return src.medium;
    case ImageSize.small:
      return src.small;
    case ImageSize.portrait:
      return src.portrait;
    case ImageSize.landscape:
      return src.landscape;
    case ImageSize.tiny:
      return src.tiny;
  }
}
