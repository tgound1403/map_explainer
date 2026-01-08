# BLoC State Management

Tài liệu về state management trong ứng dụng sử dụng BLoC pattern.

## Cấu trúc

### BLoCs
- **MapBloc**: Quản lý state cho Map View (location, markers, AI responses)
- **ChatBloc**: Quản lý state cho Chat View (messages, conversation)
- **AnalyzerBloc**: Quản lý state cho History View (chat history)
- **DetailBloc**: Quản lý state cho General/Detail View (related info)

### State Management Pattern

#### 1. BLoC Pattern với Freezed
Tất cả states và events đều sử dụng Freezed để tạo immutable classes:

```dart
@freezed
sealed class MapState with _$MapState {
  const factory MapState.initial(LoadState loadState) = _Initial;
  const factory MapState.currentLocationObtained({
    required Position position,
    required Placemark placemark,
    required LoadState loadState,
  }) = CurrentLocationObtained;
  // ...
}
```

#### 2. State Persistence
Sử dụng `StatePersistenceService` để persist state quan trọng:

```dart
// Save state
await StatePersistenceService.instance.saveState('map_state', state);

// Restore state
final savedState = await StatePersistenceService.instance.getState('map_state', fromJson);
```

#### 3. BLoC Observer
Custom `AppBlocObserver` để log state changes và errors:

```dart
Bloc.observer = AppBlocObserver();
```

## Best Practices

### 1. State Design
- ✅ Sử dụng sealed classes với Freezed cho type safety
- ✅ Tách biệt loading, success, error states
- ✅ Immutable states
- ✅ Clear state transitions

### 2. Event Design
- ✅ Mỗi event đại diện cho một user action
- ✅ Events nên là simple và focused
- ✅ Sử dụng Freezed cho immutable events

### 3. BLoC Implementation
- ✅ Mỗi BLoC chỉ quản lý state cho một feature
- ✅ Sử dụng UseCase để xử lý business logic
- ✅ Handle errors properly với Either pattern
- ✅ Emit loading states trước khi async operations

### 4. State Updates
- ✅ Chỉ emit state khi cần thiết
- ✅ Sử dụng `copyWith` hoặc Freezed để update state
- ✅ Tránh emit state trong loops
- ✅ Debounce rapid state updates nếu cần

### 5. Performance
- ✅ Sử dụng `BlocBuilder` với `buildWhen` để tránh rebuild không cần thiết
- ✅ Sử dụng `BlocSelector` cho selective rebuilds
- ✅ Cache expensive computations
- ✅ Dispose BLoCs properly

## State Persistence Strategy

### What to Persist
- ✅ User preferences (theme, locale)
- ✅ Last selected location (optional)
- ✅ Chat history (already in Firestore)
- ❌ Temporary UI states (không cần persist)

### When to Persist
- ✅ On state change cho important states
- ✅ On app pause/background
- ✅ On user action (save button, etc.)

### When to Restore
- ✅ On app start
- ✅ On feature initialization
- ✅ On user request (restore button)

## Error Handling

Tất cả BLoCs sử dụng `Either` pattern từ `dartz`:

```dart
final result = await useCase.doSomething();
result.fold(
  (error) => emit(State.error(message: error.message)),
  (data) => emit(State.success(data: data)),
);
```

## Testing

### Unit Tests
```dart
test('should emit loading then success when event is added', () {
  // Arrange
  when(mockUseCase.doSomething()).thenAnswer((_) async => Right(data));
  
  // Act
  bloc.add(Event.doSomething());
  
  // Assert
  expect(bloc.stream, emitsInOrder([
    State.loading(),
    State.success(data: data),
  ]));
});
```

### BLoC Test
Sử dụng `bloc_test` package để test BLoCs:

```dart
blocTest<MapBloc, MapState>(
  'emits [loading, success] when GetCurrentLocation is added',
  build: () => MapBloc(mockUseCase),
  act: (bloc) => bloc.add(const MapEvent.getCurrentLocation()),
  expect: () => [
    isA<MapState>().having((s) => s.loadState, 'loadState', LoadState.loading),
    isA<MapState>().having((s) => s.loadState, 'loadState', LoadState.success),
  ],
);
```
