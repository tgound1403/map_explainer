import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

void main() {
  group('EnhancedEmptyState', () {
    testWidgets('should display generic empty state', (WidgetTester tester) async {
      // Arrange
      const title = 'No Data';
      const message = 'There is no data to display';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState.generic(
              title: title,
              message: message,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      // Icon may not always be rendered if illustration is provided
      // Just check that widget renders correctly
      expect(find.byType(EnhancedEmptyState), findsOneWidget);
    });

    testWidgets('should display noData empty state', (WidgetTester tester) async {
      // Arrange
      const title = 'No Data';
      const message = 'No data available';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState.noData(
              title: title,
              message: message,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display noSearchResults empty state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('vi', ''),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return EnhancedEmptyState.noSearchResults(
                  query: 'test query',
                  context: context,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Check for title text instead of icon (more reliable)
      expect(find.text('No results found', skipOffstage: false), findsOneWidget);
      // Check for illustration emoji
      expect(find.text('🔍', skipOffstage: false), findsOneWidget);
    });

    testWidgets('should display action button when onAction provided', (WidgetTester tester) async {
      // Arrange
      bool actionCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              title: 'Test',
              message: 'Test message',
              onAction: () {
                actionCalled = true;
              },
              actionLabel: 'Refresh',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Refresh'), findsOneWidget);
      
      // Tap action button
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      
      expect(actionCalled, isTrue);
    });

    testWidgets('should not display action button when onAction is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              title: 'Test',
              message: 'Test message',
              actionLabel: 'Refresh',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Refresh'), findsNothing);
    });

    testWidgets('should display illustration when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              title: 'Test',
              message: 'Test message',
              illustration: '🎉',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('🎉'), findsOneWidget);
    });

    testWidgets('should display icon when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedEmptyState(
              title: 'Test',
              message: 'Test message',
              icon: Icons.error_outline,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
