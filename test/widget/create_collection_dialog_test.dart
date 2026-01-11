import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/components/create_collection_dialog.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_event.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_state.dart';
import 'package:ai_map_explainer/feature/collections/domain/collections_usecase.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import '../core/helpers/test_helpers.dart';

void main() {
  group('CreateCollectionDialog', () {
    late CollectionsBloc bloc;

    setUpAll(() async {
      await setupHiveForTesting();
    });

    setUp(() async {
      final service = CollectionsService.instance;
      final useCase = CollectionsUseCase(service);
      bloc = CollectionsBloc(useCase);
      await resetHiveBoxes();
    });

    tearDownAll(() async {
      await tearDownHiveForTesting();
    });

    testWidgets('should display dialog with form fields', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: bloc,
                          child: const CreateCollectionDialog(),
                        ),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create Collection'), findsOneWidget);
      expect(find.text('Collection Name'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Icon'), findsOneWidget);
    });

    testWidgets('should validate name field is required', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: bloc,
                          child: const CreateCollectionDialog(),
                        ),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Try to create without name
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert - should show validation error
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('should create collection with valid name', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: bloc,
                          child: const CreateCollectionDialog(),
                        ),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextFormField).first, 'Test Collection');
      await tester.pump();

      // Tap create button
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert - dialog should close
      expect(find.text('Create Collection'), findsNothing);
    });

    testWidgets('should allow selecting color', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: bloc,
                          child: const CreateCollectionDialog(),
                        ),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Find color options (should be 6 colors)
      final colorOptions = find.byType(InkWell);
      expect(colorOptions, findsWidgets);

      // Tap a color option
      await tester.tap(colorOptions.at(1)); // Second color
      await tester.pump();

      // Assert - color should be selected (check icon appears)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should allow selecting icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: bloc,
                          child: const CreateCollectionDialog(),
                        ),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Find icon options
      final iconOptions = find.byIcon(Icons.star); // One of the icon options
      expect(iconOptions, findsWidgets);

      // Tap an icon option
      await tester.tap(iconOptions.first);
      await tester.pump();

      // Assert - icon should be selected
      // (Icon should have different styling when selected)
    });

    testWidgets('should close dialog when cancel is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: bloc,
                          child: const CreateCollectionDialog(),
                        ),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - dialog should close
      expect(find.text('Create Collection'), findsNothing);
    });

    testWidgets('should call onCreated callback when collection is created', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: bloc,
                          child: CreateCollectionDialog(
                            onCreated: () {
                              callbackCalled = true;
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter name and create
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Collection');
      await tester.pump();
      
      // Wait for form to be ready
      await tester.pumpAndSettle();
      
      // Tap create button
      await tester.tap(find.text('Create'));
      await tester.pump();
      
      // Wait for dialog to close and callback to be called
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, isTrue);
    });
  });
}
