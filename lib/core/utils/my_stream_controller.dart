import 'dart:async';

class MyStreamController<T> {
  // ignore: close_sinks
  late StreamController<T> _controller;

  // ignore: cancel_subscriptions
  StreamSubscription? _streamSubscription;

  T? value;
  bool activeBroadcast = false;

  Stream<T> get stream => _controller.stream;

  StreamController<T> get controller => _controller;

  MyStreamController({
    T? defaultValue,
    bool activeBroadcast = false,
  }) {
    if (activeBroadcast) {
      _controller = StreamController<T>.broadcast();
    } else {
      _controller = StreamController<T>();
    }

    this.activeBroadcast = activeBroadcast;
    this.value = defaultValue;
  }

  void listenValueChange({
    void Function(T value)? func,
  }) {
    if (activeBroadcast) {
      _streamSubscription = _controller.stream.listen((value) {
        this.value = value;
        if (func != null) {
          func(value);
        }
      });
    }
  }

  void add(T t) {
    _controller.sink.add(t);
  }

  Future<void> close() async {
    if (_controller.isClosed) {
      return;
    }
    if (_streamSubscription != null) {
      await _streamSubscription!.cancel();
    }
    await _controller.close();
  }
}
