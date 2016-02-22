/*
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
*/

var AMA = global.AMA;
AMA.Storage = require('./StorageClients/LocalStorage.js');
AMA.StorageKeys = require('./StorageClients/StorageKeys.js');
AMA.Util = require('./MobileAnalyticsUtilities.js');
/**
 * @name AMA.Session
 * @namespace AMA.Session
 * @constructor
 * @param {Object=}     [options=] - A configuration map for the Session
 * @param {string=}     [options.sessionId=Utilities.GUID()]- A sessionId for session.
 * @param {string=}     [options.appId=new Date().toISOString()] - The start Timestamp (default now).
 * @param {number=}     [options.sessionLength=600000] - Length of session in Milliseconds (default 10 minutes).
 * @param {AMA.Session.ExpirationCallback=}   [options.expirationCallback] - Callback Function for when a session expires
 * @param {AMA.Client.Logger=} [options.logger=] - Object containing javascript style logger functions (passing console
 *                                                 will output to browser dev consoles)
 */
/**
 * @callback AMA.Session.ExpirationCallback
 * @param {AMA.Session} session
 * @returns {boolean|int} - Returns either true to extend the session by the sessionLength or an int with the number of
 *                          seconds to extend the session.  All other values will clear the session from storage.
 */
AMA.Session = (function () {
    'use strict';
    /**
     * @lends AMA.Session
     */
    var Session = function (options) {
        this.options = options || {};
        this.options.logger = this.options.logger || {};
        this.logger = {
            log: this.options.logger.log || AMA.Util.NOP,
            info: this.options.logger.info || AMA.Util.NOP,
            warn: this.options.logger.warn || AMA.Util.NOP,
            error: this.options.logger.error || AMA.Util.NOP
        };
        this.logger.log = this.logger.log.bind(this.options.logger);
        this.logger.info = this.logger.info.bind(this.options.logger);
        this.logger.warn = this.logger.warn.bind(this.options.logger);
        this.logger.error = this.logger.error.bind(this.options.logger);
        this.logger.log('[Function:(AWS.MobileAnalyticsClient)Session Constructor]' +
            (options ? '\noptions:' + JSON.stringify(options) : ''));
        this.options.expirationCallback = this.options.expirationCallback || AMA.Util.NOP;
        this.id = this.options.sessionId || AMA.Util.GUID();
        this.sessionLength = this.options.sessionLength || 600000; //Default session length is 10 minutes
        //Suffix the AMA.Storage Keys with Session Id to ensure proper scope
        this.StorageKeys = {
            'SESSION_ID': AMA.StorageKeys.SESSION_ID + this.id,
            'SESSION_EXPIRATION': AMA.StorageKeys.SESSION_EXPIRATION + this.id,
            'SESSION_START_TIMESTAMP': AMA.StorageKeys.SESSION_START_TIMESTAMP + this.id
        };
        this.startTimestamp = this.options.startTime ||
            this.options.storage.get(this.StorageKeys.SESSION_START_TIMESTAMP) ||
            new Date().toISOString();
        this.expirationDate = parseInt(this.options.storage.get(this.StorageKeys.SESSION_EXPIRATION), 10);
        if (isNaN(this.expirationDate)) {
            this.expirationDate = (new Date().getTime() + this.sessionLength);
        }
        this.options.storage.set(this.StorageKeys.SESSION_ID, this.id);
        this.options.storage.set(this.StorageKeys.SESSION_EXPIRATION, this.expirationDate);
        this.options.storage.set(this.StorageKeys.SESSION_START_TIMESTAMP, this.startTimestamp);
        this.sessionTimeoutReference = setTimeout(this.expireSession.bind(this), this.sessionLength);
    };

    /**
     * Expire session and clear session
     * @param {expirationCallback=} Callback function to call when sessions expire
     */
    Session.prototype.expireSession = function (expirationCallback) {
        this.logger.log('[Function:(Session).expireSession]');
        expirationCallback = expirationCallback || this.options.expirationCallback;
        var shouldExtend = expirationCallback(this);
        if (typeof shouldExtend === 'boolean' && shouldExtend) {
            shouldExtend = this.options.sessionLength;
        }
        if (typeof shouldExtend === 'number') {
            this.extendSession(shouldExtend);
        } else {
            this.clearSession();
        }
    };

    /**
     * Clear session from storage system
     */
    Session.prototype.clearSession = function () {
        this.logger.log('[Function:(Session).clearSession]');
        clearTimeout(this.sessionTimeoutReference);
        this.options.storage.delete(this.StorageKeys.SESSION_ID);
        this.options.storage.delete(this.StorageKeys.SESSION_EXPIRATION);
        this.options.storage.delete(this.StorageKeys.SESSION_START_TIMESTAMP);
    };



    /**
     * Extend session by adding to the expiration timestamp
     * @param {int} [sessionExtensionLength=sessionLength] - The number of milliseconds to add to the expiration date
     *                                                       (session length by default).
     */
    Session.prototype.extendSession = function (sessionExtensionLength) {
        this.logger.log('[Function:(Session).extendSession]' +
                        (sessionExtensionLength ? '\nsessionExtensionLength:' + sessionExtensionLength : ''));
        sessionExtensionLength = sessionExtensionLength || this.sessionLength;
        this.setSessionTimeout(this.expirationDate + parseInt(sessionExtensionLength, 10));
    };

    /**
     * @param {string} [stopDate=now] - The ISO Date String to set the stopTimestamp to (now for default).
     */
    Session.prototype.stopSession = function (stopDate) {
        this.logger.log('[Function:(Session).stopSession]' +  (stopDate ? '\nstopDate:' + stopDate : ''));
        this.stopTimestamp = stopDate || new Date().toISOString();
    };

    /**
     * Reset session timeout to expire in a given number of seconds
     * @param {int} [milliseconds=sessionLength] - The number of milliseconds until the session should expire (from now). 
     */
    Session.prototype.resetSessionTimeout = function (milliseconds) {
        this.logger.log('[Function:(Session).resetSessionTimeout]' +
                        (milliseconds ? '\nmilliseconds:' + milliseconds : ''));
        milliseconds = milliseconds || this.sessionLength;
        this.setSessionTimeout(new Date().getTime() + milliseconds);
    };

    /**
     * Setter for the session timeout
     * @param {int} timeout - epoch timestamp
     */
    Session.prototype.setSessionTimeout = function (timeout) {
        this.logger.log('[Function:(Session).setSessionTimeout]' +  (timeout ? '\ntimeout:' + timeout : ''));
        clearTimeout(this.sessionTimeoutReference);
        this.expirationDate = timeout;
        this.options.storage.set(this.StorageKeys.SESSION_EXPIRATION, this.expirationDate);
        this.sessionTimeoutReference = setTimeout(this.expireSession.bind(this),
            this.expirationDate - (new Date()).getTime());
    };
    return Session;
}());

module.exports = AMA.Session;
