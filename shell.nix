{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [ pkgs.azure-cli pkgs.azure-storage-azcopy ];
}
