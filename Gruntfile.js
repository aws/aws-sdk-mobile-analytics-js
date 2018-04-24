/*
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
*/

module.exports = function (grunt) {
    'use strict';

    require('load-grunt-tasks')(grunt);
    grunt.loadTasks('grunttasks');

    // server-side tests
    grunt.registerTask('test-nodejs', ['blanket', 'copy:test-setup', 'mochaTest']);
    // client-side tests
    grunt.registerTask('test-phantomjs', ['copy:test-setup', 'copy:browserify-test-setup', 'copy:browserify-dist-setup', 'browserify:test', 'uglify:test', 'mocha']);

    // test, dist and release
    grunt.registerTask('test', ['jshint', 'test-nodejs', 'test-phantomjs']);
    grunt.registerTask('dist', ['copy:browserify-dist-setup', 'browserify:dist', 'uglify:dist']);
    grunt.registerTask('release', ['test', 'dist', 'clean']);
};