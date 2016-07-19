###
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
###

helpers = require('./helpers')
AMA = helpers.AMA
mobileAnalyticsClient = null
lastError = null
lastLog = null
testAppId = 'e123411e2fe34eaf9ba257bbd94b44af'
localStorage = new AMA.Storage(testAppId)


appStorageKey = 'AWSMobileAnalyticsStorage'
clientId1 = 'v0.9.0'
clientId2 = 'v0.9.1'

v090Data =
  AWSMobileAnalyticsClientId: clientId1
v091Data =
  AWSMobileAnalyticsClientId: clientId2

try
  window = window
catch 
  window = false

describe 'Migration SDK v0.9.0 to v0.9.1', ->
  try
    if (window && window.localStorage)
      describe 'Has v0.9.0 clientID and no v0.9.1 clientId', ->
        before ->
          clearStorage()
          window.localStorage.setItem(appStorageKey, JSON.stringify(v090Data))
          mobileAnalyticsClient = new AMA.Client(createConfig())
        it 'should use clientId from global scope', ->
          expect(mobileAnalyticsClient.options.clientContext.client.client_id).to.eql(clientId1)
        it 'should not have migration clientId', ->
          expect(mobileAnalyticsClient.options.globalAttributes.migrationId).to.be.undefined
      describe 'Has different v0.9.0 clientID and v0.9.1 clientId', ->
        before ->
          window.localStorage.set(appStorageKey, JSON.stringify(v090Data))
          localStorage.set(AMA.StorageKeys.CLIENT_ID, clientId2)
          mobileAnalyticsClient = new AMA.Client(createConfig())
        it 'should use clientId from global scope', ->
          expect(mobileAnalyticsClient.options.clientContext.client.client_id).to.eql(clientId1)
        it 'should have migration clientId', ->
          expect(mobileAnalyticsClient.options.globalAttributes.migrationId).to.eql(clientId2)
      describe 'Has only v0.9.1 clientId', ->
        before ->
          window.localStorage.setItem(appStorageKey, JSON.stringify(v091Data))
          mobileAnalyticsClient = new AMA.Client(createConfig())
        it 'should use clientId from global scope', ->
          expect(mobileAnalyticsClient.options.clientContext.client.client_id).to.eql(clientId2)
        it 'should not have migration clientId', ->
          expect(mobileAnalyticsClient.options.globalAttributes.migrationId).to.be.undefined
  catch
    console.log('Migration coffeescripts not running, window is undefined')

clearStorage = ->
  localStorage.clearLocalStorage()
  window.localStorage.removeItem(appStorageKey);
  window.localStorage.removeItem(AMA.StorageKeys.CLIENT_ID);

#Need to create a config for each test, because the act of creating a Mobile Analytics Client modifies the config that is passed to it
createConfig = ->
  return{
    appTitle : '活跃的应用 (Active App)',
    appId : testAppId,
    appPackageName : 'com.amazonAMA..console',
    appVersionName : '',
    appVersionCode : '',
    locale : '<locale>',
    platform: 'android',
    storage: localStorage,
    globalAttributes: {
      context: 'node'
    },
    logger: {
      log: ->
        lastLog = arguments
      error: ->
        lastError = arguments
    }
  }