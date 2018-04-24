module.exports = function (grunt) {
    grunt.config('mocha', {
        'client-side': {
            src: ['build/test/browser/**/*.html'],
            dest: 'build/reports/client-side-tests.xml',
            options: {
                logErrors: true,
                reporter: 'XUnit',
                run: true,
                timeout: 10000,
                log: true
            }
        }
    });
};
