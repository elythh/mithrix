{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.vscode;
in {
  options.tarow.vscode = {
    enable = lib.options.mkEnableOption "VSCode";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode.enable = true;
    programs.vscode.package = pkgs.vscode;
    programs.vscode.enableUpdateCheck = false;
    # Enable basic, shared settings here. Each module can add module-specific VSCode settings.
    programs.vscode.userSettings = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";

      "terminal.integrated.defaultProfile.linux" = "fish";

      "terminal.integrated.commandsToSkipShell" = [
        "-workbench.action.terminal.focusFind"
      ];
      "remote.SSH.useLocalServer" = false;
      "remote.SSH.remotePlatform" = {
        "ntasler" = "linux";
        "ntasler.de" = "linux";
      };

      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.organizeImports" = "explicit";
      };
      "editor.linkedEditing" = true;
      "editor.fontLigatures" = true;

      "update.mode" = "none";
      # "workbench.sideBar.location" = "right";
    };

    programs.vscode.keybindings = [
      {
        "key" = "ctrl+e";
        "command" = "terminal.focus";
      }
    ];
  };
}
