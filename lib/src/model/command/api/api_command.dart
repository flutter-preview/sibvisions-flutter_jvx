import '../base_command.dart';

///
/// SuperClass for all ApiCommands
///
abstract class ApiCommand extends BaseCommand {
  ApiCommand({
    required super.reason,
  });
}
