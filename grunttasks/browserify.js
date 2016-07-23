module.exports = function (grunt) {
    grunt.config('browserify', {
        test: {
            files: {
                'build/test/browser/ama-sdk.js': 'build/dist/lib/ama.js',
                'build/test/browser/specs.js': ['build/test/**/*.coffee']
            },
            options: {
                transform: ['coffeeify'],
                browserifyOptions: {
                    extensions: ['.coffee']
                }
            }
        },
        dist: {
            files: {
                'dist/aws-sdk-mobile-analytics.js': 'build/dist/lib/ama.js'
            }
        }
    });
};
