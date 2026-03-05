import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestContext {
  String? token;
  String? factoryId;
}

final requestContextProvider = Provider<RequestContext>(
  (ref) => RequestContext(),
);
