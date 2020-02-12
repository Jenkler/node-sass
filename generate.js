'use strict';

const gulp = require('gulp');
const minify = require('gulp-clean-css');
const sass = require('gulp-sass');

gulp.task('scss', function() {
  console.log('Creating files');
  return gulp.src('src/scss/*.scss')
  .pipe(sass())
  .pipe(gulp.dest('src/css'))
  .pipe(minify())
  .pipe(gulp.dest('src/css.minified'));
});
gulp.series('scss')();
