{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "devops-takehome-test";
  buildInputs = with pkgs; [
    kind
    k9s
    kubectl
  ];
}
