'use strict';

const gulp = require('gulp');
const minify = require('gulp-clean-css');
const sass = require('gulp-sass');

gulp.task('scss', function() {
  return gulp.src('src/scss/*.scss')
  .pipe(sass())
  .pipe(gulp.dest('src/css'))
  .pipe(minify())
  .pipe(gulp.dest('src/css.minified'));
});
gulp.start('scss');
