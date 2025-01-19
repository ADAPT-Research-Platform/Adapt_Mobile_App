import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

class StarSlider extends StatefulWidget {
  final int sliderLength; // Maximum value for the slider
  final ValueChanged<int> onChanged;

  const StarSlider({Key? key, this.sliderLength = 10, required this.onChanged}) : super(key: key); // Default max value is 10

  @override
  _StarSliderState createState() => _StarSliderState();
}

class _StarSliderState extends State<StarSlider> {
  int _sliderValue = 0; // Initial value set to 0

  @override
  Widget build(BuildContext context) {
    // Get the device width
    double deviceWidth = MediaQuery.of(context).size.width;

    // Calculate the maximum size for each star. Adjust padding value accordingly
    double starSize = (deviceWidth - 24 - 24 - 16 - 16) / widget.sliderLength;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child:
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            // Calculate the slider value based on drag position
            RenderBox box = context.findRenderObject() as RenderBox;
            double localX = box.globalToLocal(details.globalPosition).dx;
            double width = box.size.width;
            double value = (localX / width) * widget.sliderLength;

            setState(() {
              _sliderValue = value.clamp(0, widget.sliderLength).roundToDouble().toInt(); // Ensure discrete values
            });

            widget.onChanged(_sliderValue);
          },
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                color: Colors.transparent, // Background color for the slider
                height: 30,
                width: double.infinity,
              ),
              // Custom star icons over the line
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(widget.sliderLength, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < _sliderValue ? AppColors.primaryYellow : AppColors.darkGrey,
                    size: starSize.clamp(0, 30),
                  );
                }),
              ),
            ],
          ),
        ),
    );
  }
}
