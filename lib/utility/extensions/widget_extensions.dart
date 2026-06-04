import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

import '../../ui/color.dart';




extension WidgetExtension on Widget {
  Widget addShimmer({bool block = false}){
    return Shimmer.fromColors(
      baseColor: shimmerColor,
      highlightColor: shimmerHighlightColor,
      child: block ? Container(
        decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: this),
      ) : this ,
    );
  }
  //
  // Widget required(){
  //   return Row(
  //     children: [
  //       this,
  //       SizedBox(width: spacing3,),
  //       Text("*",style: sRegular.copyWith(color: secondaryColor),)
  //     ],
  //   );
  // }
}