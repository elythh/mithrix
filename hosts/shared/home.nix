{pkgs, ...}: {
  tarow.person = {
    email = "gwen@omg.lol";
    name = "Gwenc'hlan Le Kerneau";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
  news.display = "silent";
}
