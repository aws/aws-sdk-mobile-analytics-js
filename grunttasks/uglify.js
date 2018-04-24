module.exports = function (grunt) {
    grunt.config('uglify', {
        test: {
            files: {
                'build/test/browser/ama-sdk.min.js': 'build/test/browser/ama-sdk.js',
            }
        },
        dist: {
            files: {
                'dist/aws-sdk-mobile-analytics.min.js': 'dist/aws-sdk-mobile-analytics.js'
            }
        }
    });
};
