/*
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
*/

(function() {
    var counter = 0;
    var numbered;
    var source = document.getElementsByClassName('prettyprint source');

    if (source && source[0]) {
        source = source[0].getElementsByTagName('code')[0];

        numbered = source.innerHTML.split('\n');
        numbered = numbered.map(function(item) {
            counter++;
            return '<span id="line' + counter + '" class="line"></span>' + item;
        });

        source.innerHTML = numbered.join('\n');
    }
})();
