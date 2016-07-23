module.exports = function (grunt) {
    grunt.config('blanket', {
        'test-setup': {
            src: ['lib/'],
            dest: 'build/lib/'
        }
    });
};
