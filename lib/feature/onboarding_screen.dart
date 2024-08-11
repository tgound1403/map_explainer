import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<PageViewModel>? lsPageViewModel = [
    PageViewModel(
        title: "",
        bodyWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(64),
              Image.asset('./assets/ho-chi-minh.png'),
              const Gap(16),
              const Text("Chủ tịch Hồ Chí Minh",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70)),
              const Gap(16),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Text(
                  "\"Dân ta phải biết sử ta, cho tường gốc tích nước nhà Việt Nam\"",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        decoration: const PageDecoration(pageColor: Colors.blueGrey)),
    PageViewModel(
      title: "",
        bodyWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(148),
              Image.asset('./assets/vietnam.png'),
              const Gap(16),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Text(
                  "\"Dòng máu Lạc Hồng, nghìn năm còn chảy.\"",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        decoration: const PageDecoration(pageColor: Colors.blueGrey)),
    PageViewModel(
      title: "",
        bodyWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(148),
              Image.asset('./assets/idea-3d.png'),
              const Gap(16),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Text(
                  "\"Tìm hiểu lịch sử từ những con đường bạn đi hằng ngày.\"",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        decoration: const PageDecoration(pageColor: Colors.blueGrey)),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Colors.blueGrey,
      pages: lsPageViewModel,
      showSkipButton: true,
      skip: const Text("Bỏ qua"),
      next: const Text("Tiếp theo"),
      done: const Text("Bắt đầu thôi"),
      onDone: () {
        Routes.router.navigateTo(context, RoutePath.home);
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Colors.blueGrey.shade200,
        color: Colors.blueGrey.shade400,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
      baseBtnStyle: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    );
  }
}
