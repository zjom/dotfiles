# The values that more than one program needs. A composite or a host can
# override a value, and then all leaves in that evaluation use the new value.
{ ... }:
{
  graph.base =
    { lib, ... }:
    let
      color =
        default:
        lib.mkOption {
          type = lib.types.str;
          inherit default;
          description = "A colour of the Vague scheme, as a hex value without the leading `#`.";
        };
    in
    {
      options.settings.flakeDir = lib.mkOption {
        type = lib.types.str;
        default = "dotfiles";
        description = "The checkout of this repository, relative to the home directory.";
      };

      options.settings.searchIgnores = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = ''
          The directories that are never useful to search, walk or list. fd,
          ripgrep and the walker of fzf skip these directories.
        '';
        default = [
          ".git"
          ".jj"
          "node_modules"
          ".venv"
          "venv"
          ".DS_Store"
        ];
      };

      # Neovim uses the upstream vague.nvim plugin
      # (features/editor/nvim/lua/plugins/init.lua). Thus, a change to another
      # scheme also changes that file.
      options.settings.colors = {
        bg = color "141415";
        inactiveBg = color "1c1c24";
        line = color "252530";
        visual = color "333738";
        fg = color "cdcdcd";
        floatBorder = color "878787";
        comment = color "606079";
        keyword = color "6e94b2";
        func = color "c48282";
        string = color "e8b589";
        plus = color "7fa563";
        error = color "d8647e";
        warning = color "f3be7c";
        purple = color "bb9dbd";
        cyan = color "aeaed1";
        brightRed = color "e08398";
        brightGreen = color "99b782";
        brightYellow = color "f5cb96";
        brightBlue = color "8ba9c1";
        brightPurple = color "c9b1ca";
        brightCyan = color "bebeda";
        brightWhite = color "d7d7d7";
      };
    };
}
