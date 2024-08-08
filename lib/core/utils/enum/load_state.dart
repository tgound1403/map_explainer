enum LoadState {
  initial,
  loading,
  success,
  failure,
}

extension EStatus on LoadState {
  bool get isInitial => this == LoadState.initial;
  bool get isLoading => this == LoadState.loading;
  bool get isSuccess => this == LoadState.success;
  bool get isFailure => this == LoadState.failure;

  bool get isWaitingForData => isInitial || isLoading;
}