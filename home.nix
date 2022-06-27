{lib, config, pkgs, ... }:

{


  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jhilker";
  home.homeDirectory = "/home/jhilker";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    alacritty
    firefox
    gcalcli
    pass
    rofi-pass
    rofi
    (python310.withPackages(p: with p; [
      numpy
      pandas
      ]))
  ];
  
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.zsh = {
    enable = true;
    enableSyntaxHighlighting = true;
    enableAutosuggestions = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      line_break = {
        disabled = true;
      };
    };
  };
  
  programs.git = {
    enable = true;
    userName = "Jacob Hilker";
    userEmail = "jacob.hilker2@gmail.com";
    signing = {
      signByDefault = true;
      key = "jacob.hilker2@gmail.com";
    };
  };

  programs.gpg = {
    enable = true;
  };


}
