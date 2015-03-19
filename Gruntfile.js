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

    grunt.initConfig({
        jshint: {
            sdk: {
                src: ['*.js', 'lib/**/*.js']
            },
            options: {
                jshintrc: true
            }
        },

        blanket: {
            'test-setup': {
                src: ['lib/'],
                dest: 'build/lib/'
            }
        },

        copy: {
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
        },

        mochaTest: {
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
        },

        browserify: {
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
        },

        uglify: {
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
        },

        mocha: {
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
        },

        clean: {
            build: {
                src: ['build/**']
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-clean');

    grunt.loadNpmTasks('grunt-blanket');
    grunt.loadNpmTasks('grunt-mocha-test');

    grunt.loadNpmTasks('grunt-browserify');
    grunt.loadNpmTasks('grunt-mocha');

    grunt.registerTask('default', ['npm-install']);

    // server-side tests
    grunt.registerTask('test-nodejs', ['blanket', 'copy:test-setup', 'mochaTest']);
    // client-side tests
    grunt.registerTask('test-phantomjs', ['copy:test-setup', 'copy:browserify-test-setup', 'copy:browserify-dist-setup', 'browserify:test', 'uglify:test', 'mocha']);

    // test, dist and release
    grunt.registerTask('test', ['jshint', 'test-nodejs', 'test-phantomjs']);
    grunt.registerTask('dist', ['copy:browserify-dist-setup', 'browserify:dist', 'uglify:dist']);
    grunt.registerTask('release', ['test', 'dist', 'clean']);
};