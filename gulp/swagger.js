'use strict';

var path = require('path');
var gulp = require('gulp');
var conf = require('./conf');
var swagger = require('gulp-swagger');

var browserSync = require('browser-sync');

gulp.task('swagger', function() {
    return buildApi();
});

gulp.task('swagger-reload', function() {
    return buildApi()
        .pipe(browserSync.stream());
});

function buildApi() {
    return gulp.src('./src/assets/api/swagger.yaml')
        .pipe(swagger({
            filename: 'vaultApiFunc.js',
            codegen: {
                moduleName: 'vault',
                className: 'VaultApiFunc',
                type: 'angular',
                template: {
                    class: './src/assets/api/api-class.mustache'
                }
            }
        }))
        .pipe(gulp.dest(path.join(conf.paths.tmp, '/serve/app/api')))
}