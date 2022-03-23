import 'package:flutter/material.dart' show Alignment, Color, LinearGradient;

const kHyppePrimary = Color(0xffAB22AF);

/// Light Mode
const kHyppeLightBackground = Color(0xffFDFDFD);
const kHyppeTextLightPrimary = Color(0xff3F3F3F);
const kHyppeLightSurface = Color(0xffF5F5F5);
const kHyppeLightSecondary = Color(0xff737373);
const kHyppeLightIcon = Color(0xff717171);
const kHyppeLightInactive1 = Color(0xffEDEDED);
const kHyppeLightInactive2 = Color(0xffE0E0E0);
const kHyppeLightButtonText = Color(0xffFFFFFF);
const kHyppeLightAds = Color(0xffFFBC20);
const kHyppeLightExtended1 = Color(0xff58125A);
const kHyppeLightExtended2 = Color(0xff6C166F);
const kHyppeLightExtended3 = Color(0xff961E9A);
const kHyppeLightExtended4 = Color(0xffC026C5);
const kHyppeLightWarning = Color(0xffE8B130);
const kHyppeLightDanger = Color(0xffC91D1D);
const kHyppeLightSuccess = Color(0xff237804);
const kHyppeLightInfo = Color(0xff0095F2);

/// Dark Mode
const kHyppeBackground = Color(0xff121212);

const kHyppeSurface = Color(0xff1D2124);
const kHyppeSecondary = Color(0xff707070);
const kHyppeTextPrimary = Color(0xffFFFFFF);


const kHyppeUploadIcon = Color(0xff822e6e);
const kHyppeSenderBubbleChat = Color(0xff5A1E4C);
const kHyppeBottomNavBarIcon = Color(0xffC1C1C1);

const kHyppeTextWarning = Color(0xfffa8c16);
const kHyppeDanger = Color(0xfff5222d);
const kHyppeTextSuccess = Color(0xff237804);
const kHyppeTextIcon = Color(0xff7d8389);
const kHyppeDividerColor = Color(0xff2c3236);

const kSkeletonHighlightColor = Color(0xffADADAD);
const kSkeletonBaseColor = Color(0xff878787);
const kSkeleton = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomLeft,
  colors: [
    kSkeletonHighlightColor,
    kSkeletonBaseColor,
  ],
);
