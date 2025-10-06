{pkgs, ...}: let
  extensionIds = [
    "egnjhciaieeiiohknchakcodbpgjnchh" # tab wrangler
    "ekhagklcjbdpajgpjgmbionohlpdbjgc" # zotero connector
    "hkligngkgcpcolhcnkgccglchdafcnao" # web archives
    "khgocmkkpikpnmmkgmdnfckapcdkgfaf" # 1password Beta
    "gfbliohnnapiefjpjlpjnehglfpaknnc" # surfingkeys
    "egpjdkipkomnmjhjmdamaniclmdlobbo" # firenvim
  ];
in {
  programs.helium = {
    enable = true;
    # dictionaries = [pkgs.hunspellDictsChromium.en_GB];
    extensions = map (id: {inherit id;}) extensionIds;
  };
  imports = [./extension.nix];

  # home.file = pkgs.lib.optionalAttrs (pkgs.stdenv.isDarwin) builtins.listToAttrs (
  #   map (id: {
  #     name = "Library/Application Support/Google/Chrome/External Extensions/${id}.json";
  #     value = {
  #       text = builtins.toJSON {
  #         external_update_url = "https://clients2.google.com/service/update2/crx";
  #       };
  #     };
  #   }) extensionIds
  # );
}
