{ pkgs ? import <nixpkgs> {} }:

let
  azcopy = pkgs.stdenv.mkDerivation {
    pname = "azcopy";
    version = "10.13.0"; # Update to the latest version if needed
    src = pkgs.fetchurl {
      url = "https://github.com/Azure/azure-storage-azcopy/releases/download/v10.13.0/azcopy_linux_amd64_10.13.0.tar.gz"; # Correct URL
      sha256 = "0000000000000000000000000000000000000000000000000000"; # Placeholder hash
    };
    nativeBuildInputs = [ pkgs.stdenv ];
    installPhase = ''
      mkdir -p $out/bin
      cp ./azcopy $out/bin/
    '';
  };
in
pkgs.mkShell {
  buildInputs = [
    azcopy
    pkgs.azure-cli
  ];

  # Customize this message with commands or instructions
  shellHook = ''
    echo "Azure CLI and azcopy are installed. 
    Run 'az login' to configure your Azure account.
    Refer to the Azure CLI documentation for available commands."
  '';
}