import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.errorBuilder,
    this.height,
    this.width,
    this.scale,
    this.imageBuilder,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final String imageUrl;
  final Color? color;
  final double? height;
  final double? scale;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? errorWidget;
  final PlaceholderWidgetBuilder? placeholder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageWidgetBuilder? imageBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: (){
        if(imageUrl.startsWith('http')) {
          if(imageUrl.contains('.svg')) {
            return SvgPicture.network(
              imageUrl,
              colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
              // color: color,
              alignment: alignment,
              height: height,
              width: width,
              fit: fit,
            );
          } else{
            return CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: placeholder,
              errorWidget: (context, url, error) {
                return errorWidget ?? Container();
              },
              color: color,
              cacheKey: imageUrl,
              alignment: alignment,
              height: height,
              width: width,
              fit: fit,
              imageBuilder: imageBuilder,
              maxHeightDiskCache: height != null ? Get.width.round() : null,
              maxWidthDiskCache: height != null ? Get.width.round() : null,
            );
          }
        } else if(imageUrl.startsWith('assets')) {
          if(imageUrl.endsWith('svg')) {
            return SvgPicture.asset(
              imageUrl,
              colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
              // color: color,
              alignment: alignment,
              height: height,
              width: width,
              fit: fit,
            );
          } else{
            return Image.asset(
              imageUrl,
              color: color,
              errorBuilder: errorBuilder,
              alignment: alignment,
              height: height,
              width: width,
              scale: scale,
              fit: fit,
            );
          }
        }
      }(),
    );
  }
}
