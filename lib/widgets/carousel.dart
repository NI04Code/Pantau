import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/widgets/postcard_widget.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sizer/sizer.dart';
import 'package:pantau/models/kasus.dart';

class CarouselWithIndicator extends StatefulWidget{
 const  CarouselWithIndicator({super.key, required this.trendings, required this.toMapKejahatan});
 final List<PostinganKasus> trendings;
 final void Function(PlaceLocation) toMapKejahatan;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CarouselWithIndicatorState();
  }
}
class _CarouselWithIndicatorState extends State<CarouselWithIndicator>{
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    final carouselItems = widget.trendings.map((kasus){
      return Container(
          width: double.infinity,child: PostCard(toMapKejahatan: widget.toMapKejahatan, kasus: kasus, asPost: false));
    }).toList();
    // TODO: implement build
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          items: carouselItems,
          options: CarouselOptions(
            viewportFraction: 1,
            aspectRatio: 4/3,
            //height: 3/4 * MediaQuery.of(context).size.width,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        SizedBox(height: 12,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: carouselItems.map((item) {
            int index = carouselItems.indexOf(item);
            return Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Colors.blue : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}



