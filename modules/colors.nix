# The vague colour scheme, for the Home Manager modules not yet moved to nodes.
# by programs that want either form. A top-level value: modules read it as
# `config.colors` of the top-level configuration, not of the system or home.
{ lib, ... }:

{
  options.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
  };

  config.colors = {
    bg = "141415";
    inactiveBg = "1c1c24";
    line = "252530";
    visual = "333738";
    fg = "cdcdcd";
    floatBorder = "878787";
    comment = "606079";
    keyword = "6e94b2";
    func = "c48282";
    string = "e8b589";
    plus = "7fa563";
    error = "d8647e";
    warning = "f3be7c";
  };
}
