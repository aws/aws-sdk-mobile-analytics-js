module.exports = function (grunt) {
    var testSource = ['build/test/**/*.coffee'];
    var bootStrap = 'coffee-script/register';
    var mochaTestOptions = function(reporterName, outFile) {
        return {
            options: {
                reporter: reporterName,
                quiet: true,
                require: bootStrap,
                captureFile: outFile
            },
            src: testSource
        };
    };

    grunt.config('mochaTest', {
        'server-side': mochaTestOptions('xunit', 'build/reports/server-side-tests.xml'),
        'html-cov': mochaTestOptions('html-cov', 'build/reports/server-side-coverage.html'),
        'cobertura': mochaTestOptions('mocha-cobertura-reporter', 'build/reports/server-side-coverage.xml'),
        'travis-cov': {
            options: {
                reporter: 'travis-cov',
                require: bootStrap
            },
            src: testSource
        }
    });
};
