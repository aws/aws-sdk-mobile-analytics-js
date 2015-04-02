/*
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
*/

var AMA = global.AMA;
AMA.Util = require('../MobileAnalyticsUtilities.js');

AMA.Storage = (function () {
    'use strict';
    var storageKey = 'AWSMobileAnalyticsStorage',
        cache = {},
        logger = {
            log: AMA.Util.NOP,
            info: AMA.Util.NOP,
            warn: AMA.Util.NOP,
            error: AMA.Util.NOP
        };
    function supportsLocalStorage() {
        try {
            return window && window.localStorage;
        } catch (supportsLocalStorageError) {
            return false;
        }
    }

    function clearLocalStorage() {
        cache = {};
        if (supportsLocalStorage()) {
            try {
                logger.log('[Function:(AWS.MobileAnalyticsClient.Storage).clearLocalStorage]');
                window.localStorage.removeItem(storageKey);
            } catch (clearLocalStorageError) {
                logger.log('Error clearing LocalStorage: ' + JSON.stringify(clearLocalStorageError));
            }
        } else {
            logger.log('LocalStorage is not available');
        }
    }

    function loadLocalStorage() {
        if (supportsLocalStorage()) {
            var storedCache;
            try {
                logger.log('[Function:(AWS.MobileAnalyticsClient.Storage).loadLocalStorage]');
                storedCache = window.localStorage.getItem(storageKey);
                logger.log('LocalStorage Cache: ' + storedCache);
                if (storedCache) {
                    //Try to parse, if corrupt delete
                    try {
                        cache = JSON.parse(storedCache);
                    } catch (parseJSONError) {
                        //Corrupted stored cache, delete it
                        clearLocalStorage();
                    }
                }
            } catch (loadLocalStorageError) {
                logger.log('Error loading LocalStorage: ' + JSON.stringify(loadLocalStorageError));
                clearLocalStorage();
            }
        } else {
            logger.log('LocalStorage is not available');
        }
    }

    function saveToLocalStorage() {
        if (supportsLocalStorage()) {
            try {
                logger.log('[Function:(AWS.MobileAnalyticsClient.Storage).saveToLocalStorage]');
                window.localStorage.setItem(storageKey, JSON.stringify(cache));
                logger.log('LocalStorage Cache: ' + JSON.stringify(cache));
            } catch (saveToLocalStorageError) {
                logger.log('Error saving to LocalStorage: ' + JSON.stringify(saveToLocalStorageError));
            }
        } else {
            logger.log('LocalStorage is not available');
        }
    }

    loadLocalStorage();

    return {
        type: 'LOCAL_STORAGE',
        id: AMA.Util.GUID(),
        get: function (key) {
            return cache[key];
        },
        set: function (key, value) {
            cache[key] = value;
            saveToLocalStorage();
        },
        delete: function (key) {
            delete cache[key];
            saveToLocalStorage();
        },
        each: function (callback) {
            var key;
            for (key in cache) {
                if (cache.hasOwnProperty(key)) {
                    callback(key, cache[key]);
                }
            }
        },
        reload: loadLocalStorage,
        setLogger: function (logFunction) {
            logger = logFunction;
        },
        supportsLocalStorage: supportsLocalStorage,
        clearLocalStorage: clearLocalStorage
    };
}());

module.exports = AMA.Storage;
