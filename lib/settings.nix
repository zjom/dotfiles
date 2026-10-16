# The values that more than one program needs, as `settings.*` options. All
# nodes can read these options. The leaves read the options. A composite or a
# host can override a value, and then all leaves in that evaluation use the new
# value. Each value is a separate option with a default. Thus, an override of
# one value does not remove the other values (spec rules 15-17).
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
        };
    in
    {
      # The directories that are never useful to search, walk or list. fd,
      # ripgrep and the walker of fzf skip these directories.
      options.settings.searchIgnores = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ".git"
          ".jj"
          "node_modules"
          ".venv"
          "venv"
        ];
      };

      # The vague colour scheme, as hex values without the leading `#`. Programs
      # that need either form can use these values.
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
      };
    };
}
