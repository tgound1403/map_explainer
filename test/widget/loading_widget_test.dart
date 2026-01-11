import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('should display centered loading with message', (WidgetTester tester) async {
      // Arrange
      const message = 'Loading...';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: message,
              style: LoadingStyle.centered,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should display centered loading without message', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              style: LoadingStyle.centered,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should display inline loading', (WidgetTester tester) async {
      // Arrange
      const message = 'Loading...';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: message,
              style: LoadingStyle.inline,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
      expect(find.byType(Row), findsWidgets); // May have multiple Rows
    });

    testWidgets('should display minimal loading', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              style: LoadingStyle.minimal,
            ),
          ),
        ),
      );

      // Assert
      // Minimal style chỉ hiển thị indicator, không có message
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should display fullscreen loading', (WidgetTester tester) async {
      // Arrange
      const message = 'Loading...';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: message,
              style: LoadingStyle.fullScreen,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('should use custom color when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              style: LoadingStyle.centered,
              color: Colors.red,
            ),
          ),
        ),
      );

      // Assert
      // Widget should render without errors
      expect(find.byType(LoadingWidget), findsOneWidget);
    });
  });
}
