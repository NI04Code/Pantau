import 'package:flutter/material.dart';

enum SortingOption { Populer, Terbaru }
class CommentSortingToggle extends StatefulWidget {
  final SortingOption selectedOption;
  final Function(SortingOption) onOptionChanged;

  CommentSortingToggle({
    required this.selectedOption,
    required this.onOptionChanged,
  });

  @override
  _CommentSortingToggleState createState() => _CommentSortingToggleState();
}
class _CommentSortingToggleState extends State<CommentSortingToggle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => widget.onOptionChanged(SortingOption.Populer),
          child: Container(

            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: widget.selectedOption == SortingOption.Populer
                ? Colors.blue
                : Colors.transparent,
            child: Text(
              'Popular',
              style: TextStyle(
                color: widget.selectedOption == SortingOption.Populer
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => widget.onOptionChanged(SortingOption.Terbaru),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: widget.selectedOption == SortingOption.Terbaru
                ? Colors.blue
                : Colors.transparent,
            child: Text(
              'Terbaru',
              style: TextStyle(
                color: widget.selectedOption == SortingOption.Terbaru
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}