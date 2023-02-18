import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageScroller extends StatefulWidget {
  dynamic productDocs;
  ImageScroller(this.productDocs);
  @override
  _ImageScrollerState createState() => _ImageScrollerState();
}

class _ImageScrollerState extends State<ImageScroller> {
  int activeIndex = 0;
  Widget buildImage(String urlImage, int index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 12),
        color: Colors.grey,
        child: CachedNetworkImage(
          imageUrl: urlImage,
          progressIndicatorBuilder: (context, url, progress) => Center(
              child: CircularProgressIndicator(
            value: progress.progress,
          )),
          fit: BoxFit.fitHeight,
        ),
      );
  Widget buildIndicator(int listCount) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: listCount,
        effect: JumpingDotEffect(
          verticalOffset: 10.0,
          // dotWidth: 20,
          // dotHeight: 20,
        ),
      );
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider.builder(
            options: CarouselOptions(
              height: 400,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              onPageChanged: (i, reason) => setState(() {
                activeIndex = i;
              }),
            ),
            itemCount: widget.productDocs['imageUrl'].length,
            itemBuilder: (context, index, realIndex) {
              final urlImage = widget.productDocs['imageUrl'][index];
              // print(urlImage);
              return buildImage(urlImage, index);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          buildIndicator(widget.productDocs['imageUrl'].length),
        ],
      ),
    );
  }
}
