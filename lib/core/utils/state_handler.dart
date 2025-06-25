import "dart:io";

import "package:cookethflow/core/utils/enums.dart";
import "package:flutter/material.dart";


class StateHandler extends ChangeNotifier {
  ProviderState state = ProviderState.inital;
  Failure errorMessage = Failure("");

  StateHandler([ProviderState? intialState])
      : state = intialState ?? ProviderState.inital;

  void handleLoading() {
    state = ProviderState.loading;
    errorMessage.clear();
    notifyListeners();
  }

  void handleEmpty() {
    state = ProviderState.empty;
    errorMessage.clear();
    notifyListeners();
  }

  void handleLoaded() {
    state = ProviderState.loaded;
    errorMessage.clear();
    notifyListeners();
  }

  void handleSuccess() {
    state = ProviderState.success;
    errorMessage.clear();
    notifyListeners();
  }

  void handleError(String msg) {
    state = ProviderState.error;
    errorMessage = Failure(msg);

    notifyListeners();
  }

  ///For handling errors
  Future<T?> asyncHandler<T>(
    Future<dynamic> task, {
    String socketError = "No Internet Connection",
    String formatError = "Format Exception while parsing data",
    String unknownError = "Something went Wrong",
    ProviderState? afterState,
  }) async {
    try {
      final T temp = await task as T;

      if (afterState != null) {
        state = afterState;
        notifyListeners();
      }

      return temp;
    } on SocketException catch (e) {
      debugPrint("SocketException: $e");

      handleError(socketError);
    } on FormatException catch (e) {
      debugPrint("FormatException : $e");

      handleError(formatError);
    } catch (e) {
      debugPrint("Unknown Error: $e");

      handleError(unknownError);
    }
    return null;
  }
}

class Failure {
  String message;

  String? code;

  Failure(this.message, [this.code]);

  void clear() {
    message = "";
    code = "";
  }
}