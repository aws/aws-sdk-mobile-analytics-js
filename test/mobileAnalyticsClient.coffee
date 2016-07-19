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
lastError = null
lastLog = null
clientConfig = {
  appTitle : '活跃的应用 (Active App)',
  appId : 'e123411e2fe34eaf9ba257bbd94b44af',
  appPackageName : 'com.amazonAMA..console',
  appVersionName : '',
  appVersionCode : '',
  locale : '<locale>',
  platform: 'android',
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

emptyAppIDClientConfig = {
  platform: 'myplatform',
  logger: {
    log: ->
      lastLog = arguments
    error: ->
      lastError = arguments
  }
}

emptyPlatformClientConfig = {
  appId : 'testID1',
  logger: {
    log: ->
      lastLog = arguments
    error: ->
      lastError = arguments
  }
}

validClientConfig = {
  appId : 'testID2',
  platform: 'android'
}

autoSubmitClientConfig = {
  appId : 'testID3',
  platform: 'ios',
  autoSubmitEvents: false
}

mobileAnalyticsClient = null

describe 'AMA.Client', ->
  describe 'Initialize Client', ->
    before ->
      mobileAnalyticsClient = new AMA.Client(clientConfig)
    it 'should not be initialized', ->
      expect(mobileAnalyticsClient).not.to.be.null
      expect(mobileAnalyticsClient).not.to.be.undefined
    it 'should be an instance of AMA.Client', ->
      expect(mobileAnalyticsClient).to.be.an.instanceOf(AMA.Client)
    it 'should have a not null client id', ->
      expect(mobileAnalyticsClient.options.clientContext.client.client_id).not.to.be.null
      expect(mobileAnalyticsClient.options.clientContext.client.client_id).not.to.be.undefined
  describe 'Initialize Client with incorrect parameters', ->
    it 'should throw no appId error', ->
      mobileAnalyticsClient = new AMA.Client(emptyAppIDClientConfig)
      expect(lastError[0]).to.eql('AMA.Client must be initialized with an appId')
    it 'should throw no platform error', ->
      mobileAnalyticsClient = new AMA.Client(emptyPlatformClientConfig)
      expect(lastError[0]).to.eql('AMA.Client must be initialized with a platform')
  describe 'Initialize Client with correct parameters', ->
    before ->
      mobileAnalyticsClient = new AMA.Client(validClientConfig)
    it 'should be an instance of AMA.Client', ->
      expect(mobileAnalyticsClient).to.be.an.instanceOf(AMA.Client)
    it 'should have correct appId', ->
      expect(mobileAnalyticsClient.options.appId).to.eql('testID2')
    it 'should have correct platform', ->
      expect(mobileAnalyticsClient.options.platform).to.eql('android')
  describe 'Initialize Client with autoSubmit set to false', ->
    before ->
      mobileAnalyticsClient = new AMA.Client(autoSubmitClientConfig)
    it 'should be an instance of AMA.Client', ->
      expect(mobileAnalyticsClient).to.be.an.instanceOf(AMA.Client)
    it 'should have correct appId', ->
      expect(mobileAnalyticsClient.options.appId).to.eql('testID3')
    it 'should have correct platform', ->
      expect(mobileAnalyticsClient.options.platform).to.eql('ios')
    it 'should have autoSubmit set to false', ->
      expect(mobileAnalyticsClient.options.autoSubmitEvents).to.be.false
  describe 'Clear a batch', ->
    before ->
      mobileAnalyticsClient = new AMA.Client(clientConfig)
      mobileAnalyticsClient.outputs.batchIndex.push('clearABatch')
      mobileAnalyticsClient.outputs.batches['clearABatch'] = 'test'
      mobileAnalyticsClient.clearBatchById('clearABatch')
    it 'should clear batch', ->
      expect(mobileAnalyticsClient.outputs.batches['clearABatch']).to.be.undefined
    it 'should clear batchIndex', ->
      expect(mobileAnalyticsClient.outputs.batchIndex.length).to.eql(0)
  describe 'Client ID', ->
    it 'should have same clientId when init-d repeatedly', ->
      expect(new AMA.Client(clientConfig).options.clientContext.client.client_id).to.eql(new AMA.Client(clientConfig).options.clientContext.client.client_id)