{pkgs, ...}: {
  meadow.person = {
    email = "gwen@omg.lol";
    name = "Gwenc'hlan Le Kerneau";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  news.display = "silent";
}
