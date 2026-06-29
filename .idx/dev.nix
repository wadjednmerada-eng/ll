{ pkgs, ... }: {
  channel = "stable-24.11";

  packages = [
    pkgs.nodejs_20
    pkgs.coreutils
  ];

  env = {
    NODE_ENV = "development";
    PORT = "5173";
    BASE_PATH = "/";
  };

  idx = {
    extensions = [
      "dbaeumer.vscode-eslint"
      "esbenp.prettier-vscode"
      "bradlc.vscode-tailwindcss"
    ];

    workspace = {
      onCreate = {
        install = "npm install -g pnpm@10 && pnpm install";
      };

      onStart = {
        api = "cd artifacts/api-server && pnpm run dev";
        web = "cd artifacts/sheikh-dhaki && pnpm run dev";
      };
    };

    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "pnpm"
            "--filter"
            "@workspace/sheikh-dhaki"
            "run"
            "dev"
            "--"
            "--port"
            "5173"
            "--host"
            "0.0.0.0"
          ];
          manager = "web";
          env = {
            PORT = "5173";
            BASE_PATH = "/";
          };
        };
      };
    };
  };
}
