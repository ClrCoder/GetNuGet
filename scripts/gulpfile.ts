import * as gulp from "gulp";
import * as gulp_debug from "gulp-debug";
import * as eclint from "eclint";
import * as exclude_gitignore from "gulp-exclude-gitignore";
import * as reporter from "gulp-reporter";
import * as fs from "fs";
import * as find_up from "find-up";
import * as path from "path";
import * as through from "through2";
import * as PluginError from "plugin-error";
import * as VinylFile from "vinyl";
import * as yargs from "yargs";

const PLUGIN_NAME = "ClrSeed";
const repo_ignore = [
  "!./.hg/**", // Ignoring mercurial repo DB
  "!./.git/**", // Ignoring git repo DB
  "!./modules/**", // Ignoring git-submodules
  "!./**/node_modules/**"]; // Ignoring any node_modules

function createPluginError(err: Error | string, options?: PluginError.Options): PluginError {
  return new PluginError(PLUGIN_NAME, err, options);
}

function run_eclint(mode: "check" | "fix") {
  var repoRoot = path.dirname(find_up.sync([".git", ".hg"], { cwd: __dirname }));
  process.chdir(repoRoot);
  var baseProcessing = gulp.src(
    ["**"].concat(repo_ignore)
    , {
      removeBOM: false,
      dot: true
    })
    .pipe(exclude_gitignore())
    //.pipe(gulp_debug())
    .pipe(mode == "check" ?
      eclint.check() :
      eclint.fix());
  if (mode == "check") {
    return baseProcessing.pipe(reporter());
  }
  else {
    return baseProcessing
      .pipe(
        through.obj((file: VinylFile, _enc: string, done: Done) => {
          fs.readFile(file.path, (err, data) => {
            try {
              if (err == null) {
                var modifiedBuffer = <Buffer>file.contents;

                // This is workaround for bug https://github.com/jedmao/eclint/issues/154
                // ------------------------------------------------------------------------
                // if modified buffer ends with 'lf'
                if ((modifiedBuffer.length > 1
                  && modifiedBuffer[modifiedBuffer.length - 2] != 0x0D
                  && modifiedBuffer[modifiedBuffer.length - 1] == 0x0A)
                  || (modifiedBuffer.length == 1
                    && modifiedBuffer[modifiedBuffer.length - 1] == 0x0A)) {

                  // Checking that modified buffer contains 'crlf'
                  var contains_crlf = false;
                  var contains_lf = false;
                  for (var i = 0; i < modifiedBuffer.length - 1; i++) {
                    if (modifiedBuffer[i + 1] == 0x0A) {
                      if (modifiedBuffer[i] == 0x0D) {
                        contains_crlf = true;
                      }
                      else {
                        contains_lf = true;
                      }
                    }
                  }

                  if (contains_crlf || !contains_lf) {
                    // Fixing last lf to crlf
                    modifiedBuffer[modifiedBuffer.length - 1] = 0x0D;
                    modifiedBuffer = Buffer.concat([modifiedBuffer, Buffer.from([0x0A])])
                  }
                }

                if (modifiedBuffer.compare(data) == 0) {
                  done(null, file);
                }
                else {
                  // Overwriting file only if it has been fixed.
                  fs.writeFile(file.path, modifiedBuffer, (err) => {
                    if (err == null) {
                      console.log(`File updated: ${file.path}`);
                    }
                    done(null, file)
                  });
                }
              }
              else {
                done(null, file);
              }
            }
            catch{
              done(null, file);
              return;
            }
          }
          )
        }));
  }
}

gulp.task("eclint-check", function () {
  return run_eclint("check");
});

gulp.task("eclint-fix", function () {
  return run_eclint("fix");
});


type Done = (err?: Error, file?: VinylFile) => void;

gulp.task("repo-search", function () {
  var repoRoot = path.dirname(find_up.sync([".git", ".hg"], { cwd: __dirname }));
  process.chdir(repoRoot);
  var srcArgs = yargs.argv["src"];
  var src: Array<string>;

  if (!srcArgs) {
    src = ["**"];
  }
  else if (typeof srcArgs === "string") {
    src = [srcArgs];
  }
  else {
    src = <Array<string>>srcArgs;
  }

  return gulp.src(
    src.concat(repo_ignore),
    {
      read: false,
      dot: true,
      nodir: !!yargs.argv["nodir"]
    })
    .pipe(exclude_gitignore())
    .pipe(
      through.obj((file: VinylFile, _enc: string, done: Done) => {
        console.log(file.path);
        done(null, file)
      }));
  //.pipe(gulp_debug())
});
