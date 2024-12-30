import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'command_processor.dart';
import 'nlp_service.dart';

final serviceLocator = ProviderContainer();

void setupServices() {
  // Core Services
  serviceLocator.read(apiServiceProvider);
  serviceLocator.read(commandProcessorProvider);
  serviceLocator.read(nlpServiceProvider);
}
