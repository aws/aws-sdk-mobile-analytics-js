/*
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
*/

var AMA = global.AMA;

AMA.Util = (function () {
    'use strict';
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    function utf8ByteLength(str) {
        if (typeof str !== 'string') {
            str = JSON.stringify(str);
        }
        var s = str.length, i, code;
        for (i = str.length - 1; i >= 0; i -= 1) {
            code = str.charCodeAt(i);
            if (code > 0x7f && code <= 0x7ff) {
                s += 1;
            } else if (code > 0x7ff && code <= 0xffff) {
                s += 2;
            }
            if (code >= 0xDC00 && code <= 0xDFFF) { /*trail surrogate*/
                i -= 1;
            }
        }
        return s;
    }
    function guid() {
        return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
    }
    function mergeObjects(override, initial) {
        Object.keys(initial).forEach(function (key) {
            if (initial.hasOwnProperty(key)) {
                override[key] = override[key] || initial[key];
            }
        });
        return override;
    }
    function copy(original, extension) {
        return mergeObjects(JSON.parse(JSON.stringify(original)), extension || {});
    }
    function NOP() {
        return undefined;
    }

    function timestamp() {
        return new Date().getTime();
    }
    return {
        copy: copy,
        GUID: guid,
        getRequestBodySize: utf8ByteLength,
        mergeObjects: mergeObjects,
        NOP: NOP,
        timestamp: timestamp
    };
}());

module.exports = AMA.Util;
