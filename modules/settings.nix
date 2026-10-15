# Values more than one program needs, as `settings.*` options every node can
# read. Leaves read them; a composite or a host can override a value and every
# leaf in that evaluation follows. Each value is its own option with a default,
# so overriding one does not drop the rest (spec rules 15-17).
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
      # The vague colour scheme, as hex without the leading `#`, so it can be
      # used by programs that want either form.
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
