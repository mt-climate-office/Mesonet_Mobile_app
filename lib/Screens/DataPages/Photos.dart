// ignore: file_names
import 'package:flutter/material.dart';

class PhotoPage extends StatefulWidget {
  final String id;
  const PhotoPage({super.key, required this.id});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: PageScrollPhysics(),
      shrinkWrap: true,
      children: [
        Image.network(
            'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/n/?force=True',
            ),
        Image.network(
          'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/w/?force=True',
          errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
          return Image.network(
            'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/ns/?force=True',
          );
        }
        ),
        Image.network(
            'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/s/?force=True',
            ),
        Image.network(
          'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/e/?force=True',
          errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
          return Image.network(
            'https://mesonet.climate.umt.edu/api/v2/photos/${widget.id}/ss/?force=True',
          );
        }
        ),
      ],
    );
  }
}
