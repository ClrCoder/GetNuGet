import * as gulp from "gulp";
import * as gulp_debug from "gulp-debug";
import * as eclint from "eclint";
import * as exclude_gitignore from "gulp-exclude-gitignore";
import * as reporter from "gulp-reporter";
import * as find_up from "find-up";
import * as path from "path";

var repoRoot = path.dirname(find_up.sync([".git", ".hg"], { cwd: __dirname }));
gulp.task("eclint-check", function () {
  process.chdir(repoRoot);
  return gulp.src([
    "**", "!./**/node_modules/**"
  ])
    .pipe(exclude_gitignore())
    //.pipe(gulp_debug())
    .pipe(eclint.check())
    .pipe(reporter());
});