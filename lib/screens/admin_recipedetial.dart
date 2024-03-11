import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartcook_cor/models/index.dart'; // Ensure this contains the Recipe model
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeDetailViewScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailViewScreen({Key? key, required this.recipe})
      : super(key: key);

  @override
  State<RecipeDetailViewScreen> createState() => _RecipeDetailViewScreenState();
}

class _RecipeDetailViewScreenState extends State<RecipeDetailViewScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(widget.recipe.youtubeLink) ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    _controller.addListener(() {
      if (_controller.value.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(widget.recipe.youtubeLink) ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title), // Display the recipe title
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                  widget.recipe.ingredients.join(', ')), // Display ingredients
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Cooking Style:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(widget.recipe.cookingStyle), // Display cooking style
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                int seekMillis = details.primaryDelta!.sign.toInt() *
                    10000; // 10 seconds per drag
                _controller.seekTo(_controller.value.position +
                    Duration(milliseconds: seekMillis));
              },
              onScaleUpdate: (ScaleUpdateDetails details) {
                // Implement pinch to zoom logic here
                // This might be complex as YoutubePlayer doesn't natively support pinch to zoom
              },
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
