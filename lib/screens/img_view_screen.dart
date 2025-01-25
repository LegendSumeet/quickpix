import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picpixels/features/img/img.dart';
import 'package:picpixels/model/image_src.dart';
import 'package:picpixels/screens/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ImgViewScreen extends StatefulWidget {
  final ImageSrc imageSrc;
  const ImgViewScreen({super.key, required this.imageSrc});

  @override
  State<ImgViewScreen> createState() => _ImgViewScreenState();
}

class _ImgViewScreenState extends State<ImgViewScreen> {
  ImageSize size = ImageSize.portrait;
  final List<Map<String, dynamic>> chipData = [
    {'label': 'original', 'size': ImageSize.original},
    {'label': 'large2x', 'size': ImageSize.large2x},
    {'label': 'large', 'size': ImageSize.large},
    {'label': 'portrait', 'size': ImageSize.portrait},
    {'label': 'landscape', 'size': ImageSize.landscape},
    {'label': 'small', 'size': ImageSize.small},
    {'label': 'medium', 'size': ImageSize.medium},
    {'label': 'tiny', 'size': ImageSize.tiny},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 8.0, // Space between chips
            runSpacing: 4.0, // Space between rows of chips
            children: chipData.map<Widget>((chip) {
              return ChoiceChip(
                label: Text(
                  chip['label'],
                  style: TextStyle(fontSize: 14), // Custom font size
                ),
                selected: size == chip['size'],
                tooltip: 'Select size: ${chip['label']}', // Accessibility improvement
                onSelected: (isSelected) {
                  if (isSelected) {
                    setState(() {
                      size = chip['size'];
                    });
                  }
                },
              );
            }).toList(),
          ),
        )
      ],
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add consistent padding to the page
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Widget
              InkWell(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhotoViewWidget(url: getImageUrl(widget.imageSrc.src, size))));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12), // Add rounded corners for modern feel
                  child: ImageWidget(src: widget.imageSrc, size: size),
                ),
              ),
              const SizedBox(height: 16), // Add spacing between the image and text

              // Image Description
              Text(
                widget.imageSrc.alt.isNotEmpty ? widget.imageSrc.alt : 'No description available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, // Make the text slightly bolder for emphasis
                    ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),

              // Photographer Details Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Photographer Icon
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    radius: 16,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Photographer Label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photographer',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.imageSrc.photographer,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),

                  // Open Photographer URL Button
                  FilledButton.icon(
                    onPressed: () async {
                      final photographerUrl = widget.imageSrc.photographerUrl;
                      if (Uri.tryParse(photographerUrl)?.isAbsolute == true) {
                        await launchUrl(
                          Uri.parse(photographerUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invalid photographer URL'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.open_in_new, size: 16),
                    label: Text('View Profile'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
