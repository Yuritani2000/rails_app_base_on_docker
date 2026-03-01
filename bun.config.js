import path from 'path';
import fs from 'fs';

const config = {
  sourcemap: "external",
  entrypoints: ["app/javascript/application.js"],
  outdir: path.join(process.cwd(), "app/assets/builds"),
};

const build = async (config) => {
  try {
    console.log("Build configuration:", config);
    const result = await Bun.build(config);

    if (!result.success) {
      console.error("Build failed with the following logs:");
      for (const message of result.logs) {
        console.error(message);
      }
      if (!process.argv.includes('--watch')) {
        process.exit(1);
      }
      return;
    } else {
      console.log("Build success");
    }
  } catch (error) {
    console.error("An unexpected error occurred during the build process:", error);
    if (!process.argv.includes('--watch')) {
      process.exit(1);
    }
  }
};

(async () => {
  await build(config);

  if (process.argv.includes('--watch')) {
    fs.watch(path.join(process.cwd(), "app/javascript"), { recursive: true }, (eventType, filename) => {
      console.log(`File changed: ${filename}. Rebuilding...`);
      build(config);
    });
  } else {
    process.exit(0);
  }
})();
