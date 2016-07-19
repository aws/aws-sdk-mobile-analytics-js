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
    var LocalStorageClient = function (appId) {
        this.storageKey = 'AWSMobileAnalyticsStorage-' + appId;
        global[this.storageKey] = global[this.storageKey] || {};
        this.cache = global[this.storageKey];
        this.cache.id = this.cache.id || AMA.Util.GUID();
        this.logger = {
            log: AMA.Util.NOP,
            info: AMA.Util.NOP,
            warn: AMA.Util.NOP,
            error: AMA.Util.NOP
        };
        this.reload();
    };
    // Safari, in Private Browsing Mode, looks like it supports localStorage but all calls to setItem
    // throw QuotaExceededError. We're going to detect this and just silently drop any calls to setItem
    // to avoid the entire page breaking, without having to do a check at each usage of Storage.
    /*global Storage*/
    if (typeof localStorage === 'object' && Storage === 'object') {
        try {
            localStorage.setItem('TestLocalStorage', 1);
            localStorage.removeItem('TestLocalStorage');
        } catch (e) {
            Storage.prototype._setItem = Storage.prototype.setItem;
            Storage.prototype.setItem = AMA.Util.NOP;
            console.warn('Your web browser does not support storing settings locally. In Safari, the most common cause of this is using "Private Browsing Mode". Some settings may not save or some features may not work properly for you.');
        }
    }

    LocalStorageClient.prototype.type = 'LOCAL_STORAGE';
    LocalStorageClient.prototype.get = function (key) {
        return this.cache[key];
    };
    LocalStorageClient.prototype.set = function (key, value) {
        this.cache[key] = value;
        return this.saveToLocalStorage();
    };
    LocalStorageClient.prototype.delete = function (key) {
        delete this.cache[key];
        this.saveToLocalStorage();
    };
    LocalStorageClient.prototype.each = function (callback) {
        var key;
        for (key in this.cache) {
            if (this.cache.hasOwnProperty(key)) {
                callback(key, this.cache[key]);
            }
        }
    };
    LocalStorageClient.prototype.saveToLocalStorage = function saveToLocalStorage() {
        if (this.supportsLocalStorage()) {
            try {
                this.logger.log('[Function:(AWS.MobileAnalyticsClient.Storage).saveToLocalStorage]');
                window.localStorage.setItem(this.storageKey, JSON.stringify(this.cache));
                this.logger.log('LocalStorage Cache: ' + JSON.stringify(this.cache));
            } catch (saveToLocalStorageError) {
                this.logger.log('Error saving to LocalStorage: ' + JSON.stringify(saveToLocalStorageError));
            }
        } else {
            this.logger.log('LocalStorage is not available');
        }
    };
    LocalStorageClient.prototype.reload = function loadLocalStorage() {
        if (this.supportsLocalStorage()) {
            var storedCache;
            try {
                this.logger.log('[Function:(AWS.MobileAnalyticsClient.Storage).loadLocalStorage]');
                storedCache = window.localStorage.getItem(this.storageKey);
                this.logger.log('LocalStorage Cache: ' + storedCache);
                if (storedCache) {
                    //Try to parse, if corrupt delete
                    try {
                        this.cache = JSON.parse(storedCache);
                    } catch (parseJSONError) {
                        //Corrupted stored cache, delete it
                        this.clearLocalStorage();
                    }
                }
            } catch (loadLocalStorageError) {
                this.logger.log('Error loading LocalStorage: ' + JSON.stringify(loadLocalStorageError));
                this.clearLocalStorage();
            }
        } else {
            this.logger.log('LocalStorage is not available');
        }
    };
    LocalStorageClient.prototype.setLogger = function (logFunction) {
        this.logger = logFunction;
    };
    LocalStorageClient.prototype.supportsLocalStorage = function supportsLocalStorage() {
        try {
            return window && window.localStorage;
        } catch (supportsLocalStorageError) {
            return false;
        }
    };
    LocalStorageClient.prototype.clearLocalStorage = function clearLocalStorage() {
        this.cache = {};
        if (this.supportsLocalStorage()) {
            try {
                this.logger.log('[Function:(AWS.MobileAnalyticsClient.Storage).clearLocalStorage]');
                window.localStorage.removeItem(this.storageKey);
                //Clear Cache
                global[this.storageKey] = {};
            } catch (clearLocalStorageError) {
                this.logger.log('Error clearing LocalStorage: ' + JSON.stringify(clearLocalStorageError));
            }
        } else {
            this.logger.log('LocalStorage is not available');
        }
    };
    return LocalStorageClient;
}());

module.exports = AMA.Storage;
