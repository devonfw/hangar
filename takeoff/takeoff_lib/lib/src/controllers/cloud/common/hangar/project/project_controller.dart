/// Interface for the controllers that will create the projects in each provider.
abstract class ProjectController {
  /// Creates the project.
  ///
  /// Whether or not the process succeed.
  Future<bool> createProject();
}
