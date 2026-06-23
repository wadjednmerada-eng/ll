{ pkgs, ... }: {
  channel = "stable-24.11";

  packages = [
    pkgs.nodejs_22
  ];

  env = {
    NODE_ENV = "development";
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
        api    = "cd artifacts/api-server && pnpm run dev";
        web    = "cd artifacts/sheikh-dhaki && pnpm run dev";
      };
    };

    previews = {
      enable = true;
      previews = {
        web = {
          command = ["pnpm" "--filter" "@workspace/sheikh-dhaki" "run" "dev" "--" "--port" "$PORT" "--host" "0.0.0.0"];
          manager = "web";
        };
      };
    };
  };
}
