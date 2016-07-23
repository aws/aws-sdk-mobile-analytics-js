module.exports = function (grunt) {
    grunt.config('copy', {
        'test-setup': {
            expand: true,
            cwd: 'test/',
            src: ['**'],
            dest: 'build/test/'
        },
        'browserify-test-setup': {
            src: 'build/test/helper.coffee',
            dest: 'build/test/helper.coffee',
            options: {
                // Remove 'aws-sdk' and 'aws-sdk-mobile-analytics' modules
                process: function (content) {
                    return content
                        .replace(/\s*aws\s*=\s*require\s*\(\s*'aws\-sdk'\s*\)\s*;/i, '')
                        .replace(/\s*ama\s*=\s*require\s*\(\s*'\.\.\/lib\/ama\.js'\s*\)\s*;/i, '', '');
                }
            }
        },
        'browserify-dist-setup': {
            expand: true,
            src: ['lib/**/*.js'],
            dest: 'build/dist/',
            options: {
                // Remove 'aws-sdk' module
                process: function (content) {
                    return content.replace(/\s*(var)?\s*aws\s*=\s*require\s*\(\s*'aws\-sdk'\s*\)\s*;/i, '');
                }
            }
        }
    });
};
