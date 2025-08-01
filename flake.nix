{
  description = "software needed for elixir";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; };

  outputs = { self, nixpkgs }:
    let
      name = builtins.replaceStrings [ "-" ] [ "_" ] "astrozop-service";
      version = "1.1.0";

      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system:
          function {
            pkgs = nixpkgs.legacyPackages.${system};
            system = system;
          });
    in {
      devShells = forAllSystems ({ pkgs, system }: {
        default = pkgs.mkShell {
          inherit name;
          buildInputs = with pkgs; [ elixir_1_18 mix2nix ];
        };

        ci = pkgs.mkShell {
          inherit name;
          buildInputs = with pkgs; [ skopeo gzip ];
        };
      });

      packages = forAllSystems ({ pkgs, system }:
        let
          beamPackages = pkgs.beamPackages;
          entrypointSh = pkgs.writeShellScript "entrypoint" ''
            /bin/${name} eval "AstrozopService.Release.migrate"
            /bin/${name} start
          '';
          defaultDockerContents = (with pkgs; [ coreutils bash curl ]);
          baseConfigMixRelease = {
            pname = name;
            inherit version;
            src = ./.;
            removeCookie = false;
            mixNixDeps = with pkgs;
              import ./deps.nix {
                inherit lib beamPackages;
                overrides = (self: super: {
                  gzp_common_ex = beamPackages.buildMix {
                    name = "gzp_common_ex";
                    version = "0.2.0";

                    src = fetchTree {
                      type = "github";
                      owner = "gamezop";
                      repo = "gzp-common-ex";
                      rev = "3158cc55fc782e05062954605f92280959ab9c87";
                    };

                    beamDeps = lib.attrsets.attrValues super;
                  };
                });
              };
          };
          baseConfigDocker = {
            inherit name;
            maxLayers = 10;
            tag = "local";

            config.Cmd = [ "./${entrypointSh}" ];
          };
        in {
          svc = beamPackages.mixRelease baseConfigMixRelease;

          svc-dev = beamPackages.mixRelease
            (baseConfigMixRelease // { mixEnv = "dev"; });

          docker = pkgs.dockerTools.streamLayeredImage (baseConfigDocker // {
            contents = defaultDockerContents ++ [ self.packages.${system}.svc ];
          });

          docker-dev = pkgs.dockerTools.streamLayeredImage (baseConfigDocker
            // {
              contents = defaultDockerContents
                ++ [ self.packages.${system}.svc-dev ];
            });

          ci = self.devShells.${system}.ci;
        });

      apps = forAllSystems ({ pkgs, system }: {
        docker = {
          type = "app";
          program = "${self.packages.${system}.docker}";
        };

        docker-dev = {
          type = "app";
          program = "${self.packages.${system}.docker-dev}";
        };
      });
    };
}
