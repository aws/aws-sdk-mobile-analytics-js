module.exports = function (grunt) {
    grunt.config('jshint', {
        sdk: {
            src: ['*.js', 'lib/**/*.js']
        },
        options: {
            jshintrc: true
        }
    });
};
