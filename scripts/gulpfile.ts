import * as gulp from "gulp";
import * as gulp_debug from "gulp-debug";
import * as eclint from "eclint";
import * as reporter from "gulp-reporter";
import * as fs from "fs";
import * as find_up from "find-up";
import * as path from "path";
import * as through from "through2";
import * as PluginError from "plugin-error";
import * as VinylFile from "vinyl";
import * as yargs from "yargs";
import * as shelljs from "shelljs";

const PLUGIN_NAME = "ClrSeed";
const repo_ignore = [
  "!./.hg/**", // Ignoring mercurial repo DB
  "!./.git/**", // Ignoring git repo DB
  "!./modules/**", // Ignoring git-submodules
  "!./**/node_modules/**"]; // Ignoring any node_modules

function createPluginError(err: Error | string, options?: PluginError.Options): PluginError {
  return new PluginError(PLUGIN_NAME, err, options);
}

function get_all_git_repo_files(path: string): Set<string> {
  let command = `git -c core.quotePath=false -C "${path}" ls-files -o -c -m  --exclude-standard`;
  var result = shelljs.exec(command,
    {
      env: { "LC_LOCAL": "C.UTF-8" },
      silent: true, encoding: 'utf8'
    });

  let exitCode = (<any>result).code;
  if (exitCode != 0) {
    console.log(result.stderr);
    console.log("Error executing command: ", command);
    console.log("Exit code: ", exitCode);
    throw "Error executing 'git ls-files'";
  }

  var filesSet = new Set<string>();
  for (let relativeFilePath of (<string>result.stdout).split("\n")) {
    if (relativeFilePath != '') {
      filesSet.add(relativeFilePath)
    }
  }

  return filesSet;
}

function get_all_hg_repo_files(path: string): Set<string> {

  let command = `hg status -m -a -c -u -n --encoding utf8 --cwd "${path}"`

  var result = shelljs.exec(command, { silent: true, encoding: 'utf8' });

  let exitCode = (<any>result).code;
  if (exitCode != 0) {
    console.log(result.stderr);
    console.log("Error executing command: ", command);
    console.log("Exit code: ", exitCode);
    throw "Error executing 'hg status'";
  }

  var filesSet = new Set<string>();
  for (let relativeFilePath of (<string>result.stdout).split("\n")) {
    if (relativeFilePath != '') {
      filesSet.add(relativeFilePath.replace(/\\/g, "/"))
    }
  }

  return filesSet;
}

function get_repo_files(repo_root: string): Set<string> {
  if (fs.existsSync(path.join(repo_root, ".git"))) {
    return get_all_git_repo_files(repo_root);
  } else {
    return get_all_hg_repo_files(repo_root);
  }
}

function run_eclint(mode: "check" | "fix") {
  var repoRoot = path.dirname(find_up.sync([".git", ".hg"], { cwd: __dirname }));

  let repo_files = get_repo_files(repoRoot);

  process.chdir(repoRoot);
  var baseProcessing = gulp.src(
    ["**"].concat(repo_ignore)
    , {
      read: false,
      removeBOM: false,
      dot: true
    })
    .pipe(
      through.obj((file: VinylFile, _enc: string, done: Done) => {
        let relative_path = file.path.substr(repoRoot.length + 1, file.path.length - repoRoot.length - 1);
        relative_path = relative_path.replace(/\\/g, "/");
        if (relative_path != '' && repo_files.has(relative_path)) {
          // Read out only non-ignored files
          fs.readFile(file.path, (err, data) => {
            file.contents = data;
            done(err, file);
          })
        }
        else {
          done(null, null);
        }
      }))
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
  let repoRoot = path.dirname(find_up.sync([".git", ".hg"], { cwd: __dirname }));

  let repo_files = get_repo_files(repoRoot);

  let srcArgs = yargs.argv["src"];
  let src: Array<string>;

  //get_all_hg_repo_files(repoRoot);
  if (!srcArgs) {
    src = ["**"];
  }
  else if (typeof srcArgs === "string") {
    src = [srcArgs]
  }
  else {
    src = <Array<string>>srcArgs;
  }

  return gulp.src(
    src.concat(repo_ignore),
    {
      read: false,
      dot: true,
      nodir: !!yargs.argv["nodir"],
      cwd: repoRoot
    })
    .pipe(
      through.obj((file: VinylFile, _enc: string, done: Done) => {
        let relative_path = file.path.substr(repoRoot.length + 1, file.path.length - repoRoot.length - 1);
        relative_path = relative_path.replace(/\\/g, "/");
        if (relative_path != '' && repo_files.has(relative_path)) {
          console.log(relative_path);
        }
        done(null, file)
      }));
  //.pipe(gulp_debug())
});
