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
AMA.Session = require('./MobileAnalyticsSession.js');
AMA.Client = require('./MobileAnalyticsClient.js');

/**
 * @typedef AMA.Manager.Options
 * @augments AMA.Client.Options
 * @property {AMA.Session.ExpirationCallback} [expirationCallback=] - Callback function to call when sessions expire
 */

/**
 * @name AMA.Manager
 * @namespace AMA.Manager
 * @constructor
 * @param {AMA.Client.Options|AMA.Client} options - A configuration map for the AMA.Client or an instantiated AMA.Client
 * @see AMA.Client
 */
AMA.Manager = (function () {
    'use strict';
    /**
     * @lends AMA.Manager
     */
    var Manager = function (options) {
        if (options instanceof AMA.Client) {
            this.client = options;
        } else {
            options._autoSubmitEvents = options.autoSubmitEvents;
            options.autoSubmitEvents = false;
            this.client = new AMA.Client(options);
            options.autoSubmitEvents = options._autoSubmitEvents !== false;
            delete options._autoSubmitEvents;
        }
        this.options = this.client.options;
        this.outputs = this.client.outputs;

        this.options.expirationCallback = this.options.expirationCallback || AMA.Util.NOP;
        function checkForStoredSessions(context) {
            context.client.storage.each(function (key) {
                if (key.indexOf(AMA.StorageKeys.SESSION_ID) === 0) {
                    context.outputs.session = new AMA.Session({
                        storage           : context.client.storage,
                        sessionId         : context.client.storage.get(key),
                        sessionLength     : context.options.sessionLength,
                        expirationCallback: function (session) {
                            var shouldExtend = context.options.expirationCallback(session);
                            if (shouldExtend === true || typeof shouldExtend === 'number') {
                                return shouldExtend;
                            }
                            context.stopSession();
                        }
                    });
                    if (new Date().getTime() > context.outputs.session.expirationDate) {
                        context.outputs.session.expireSession();
                        delete context.outputs.session;
                    }
                }
            });
        }

        checkForStoredSessions(this);
        if (!this.outputs.session) {
            this.startSession();
        }
        if (this.options.autoSubmitEvents) {
            this.client.submitEvents();
        }
    };

    /**
     * submitEvents
     * @param {Object} [options=] - options for submitting events
     * @param {Object} [options.clientContext=this.options.clientContext] - clientContext to submit with defaults to
     *                                                                      options.clientContext
     * @returns {Array} Array of batch indices that were submitted
     */
    Manager.prototype.submitEvents = function (options) {
        return this.client.submitEvents(options);
    };

    /**
     * Function to start a session
     * @returns {AMA.Client.Event} The start session event recorded
     */
    Manager.prototype.startSession = function () {
        this.client.logger.log('[Function:(AMA.Manager).startSession]');
        if (this.outputs.session) {
            //Clear Session
            this.outputs.session.clearSession();
        }
        this.outputs.session = new AMA.Session({
            storage: this.client.storage,
            logger: this.client.options.logger,
            sessionLength: this.options.sessionLength,
            expirationCallback: function (session) {
                var shouldExtend = this.options.expirationCallback(session);
                if (shouldExtend === true || typeof shouldExtend === 'number') {
                    return shouldExtend;
                }
                this.stopSession();
            }.bind(this)
        });
        return this.recordEvent('_session.start');
    };

    /**
     * Function to extend the current session.
     * @param {int} [milliseconds=options.sessionLength] - Milliseconds to extend the session by, will default
     *                                                     to another session length
     * @returns {int} The Session expiration (in Milliseconds)
     */
    Manager.prototype.extendSession = function (milliseconds) {
        return this.outputs.session.extendSession(milliseconds || this.options.sessionLength);
    };

    /**
     * Function to stop the current session
     * @returns {AMA.Client.Event} The stop session event recorded
     */
    Manager.prototype.stopSession = function () {
        this.client.logger.log('[Function:(AMA.Manager).stopSession]');
        this.outputs.session.stopSession();
        this.outputs.session.expireSession(AMA.Util.NOP);
        return this.recordEvent('_session.stop');
    };

    /**
     * Function to stop the current session and start a new one
     * @returns {AMA.Session} The new Session Object for the SessionManager
     */
    Manager.prototype.renewSession = function () {
        this.stopSession();
        this.startSession();
        return this.outputs.session;
    };

    /**
     * Function that constructs a Mobile Analytics Event
     * @param {string} eventType - Custom Event Type to be displayed in Console
     * @param {AMA.Client.Attributes} [attributes=] - Map of String attributes
     * @param {AMA.Client.Metrics} [metrics=] - Map of numeric values
     * @returns {AMA.Client.Event}
     */
    Manager.prototype.createEvent = function (eventType, attributes, metrics) {
        return this.client.createEvent(eventType, this.outputs.session, attributes, metrics);
    };

    /**
     * Function to record a custom event
     * @param eventType - Custom event type name
     * @param {AMA.Client.Attributes} [attributes=] - Custom attributes
     * @param {AMA.Client.Metrics} [metrics=] - Custom metrics
     * @returns {AMA.Client.Event} The event that was recorded
     */
    Manager.prototype.recordEvent = function (eventType, attributes, metrics) {
        return this.client.recordEvent(eventType, this.outputs.session, attributes, metrics);
    };

    /**
     * Function to record a monetization event
     * @param {Object} monetizationDetails - Details about Monetization Event
     * @param {string} monetizationDetails.currency - ISO Currency of event
     * @param {string} monetizationDetails.productId - Product Id of monetization event
     * @param {number} monetizationDetails.quantity - Quantity of product in transaction
     * @param {string|number} monetizationDetails.price - Price of product either ISO formatted string, or number
     *                                                    with associated ISO Currency
     * @param {AMA.Client.Attributes} [attributes=] - Custom attributes
     * @param {AMA.Client.Metrics} [metrics=] - Custom metrics
     * @returns {AMA.Client.Event} The event that was recorded
     */
    Manager.prototype.recordMonetizationEvent = function (monetizationDetails, attributes, metrics) {
        return this.client.recordMonetizationEvent(this.outputs.session, monetizationDetails, attributes, metrics);
    };
    return Manager;
}());

module.exports = AMA.Manager;
