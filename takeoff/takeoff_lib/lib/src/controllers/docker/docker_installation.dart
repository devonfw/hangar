// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Enum to distinguish between Docker installations
enum DockerInstallation { rancherDesktop, dockerDesktop, unix, unknown }

enum DockerCommand { nerdctl, docker, none }

class DockerType {
  DockerInstallation installation;
  DockerCommand command;

  DockerType({
    required this.installation,
    required this.command,
  });
}
