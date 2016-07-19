###
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
###

helpers = require('./helpers')
AWS = helpers.AWS
AWS.VERSION = 'AWS_VERSION'
AMA = helpers.AMA
mobileAnalyticsClient = null
lastLog = null
lastError = null
lastWarn = null
lastClientContext = null
monetizationEvent = null
m1 = null
m2 = null
m1_2 = null
batchIds = null
submissions = 0
expectedSubmissions = 0
countSubmissionCallback = (err, results) ->
  if (!err)
    console.log(submissions++, err, results)
#  expect(submissions).to.eql(expectedSubmissions)

logMessage = (message) ->
  lastLog = arguments
  #console.log(JSON.stringify(message))

errorMessage = (message) ->
  lastError = arguments
  #console.error(JSON.stringify(message))

warnMessage = (message) ->
  lastWarn = arguments
#  console.log(JSON.stringify(message))

clientConfig = {
  appTitle : 'appTitle',
  appId : 'appId',
  appPackageName : 'appPackageName',
  appVersionName : 'appVersionName',
  appVersionCode : 'appVersionCode',
  locale : 'locale',
  platform: 'platform',
  model:"model",
  make:"make",
  platformVersion:"platformVersion",
  globalAttributes: {
    context: 'node'
  },
  logger: {
    log: logMessage
    error: errorMessage,
    warn: warnMessage,
    info: logMessage
  }
}
s = new AMA.Storage('appId')
s.clearLocalStorage()

createErrorResponse = (code, message) ->
  message = message || ''
  if code
    {
    "code": code,
    "message": message,
    "time":"2015-02-26T19:43:20.424Z",
    "statusCode":400,
    "retryable":false,
    "retryDelay":30
    }
  else
    null
currentError = null
lastEventRequest = null
AWS.MobileAnalytics = (options) ->
  this.putEvents = (eventRequest, callbackFunc) ->
    #console.log('submitting' + currentError)
    lastEventRequest = eventRequest
    callbackFunc(currentError, null)
  this

testBatchNotDeleted = (errorType) ->
  describe 'Test Response Code Handling (' + errorType + ')', ->
    beforeEach ->
      mobileAnalyticsClient = new AMA.Client(clientConfig)
      currentError = createErrorResponse(errorType)
      mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
    it 'should not delete the batchIndex', ->
      mobileAnalyticsClient.recordEvent('should not delete batchIndex ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices = mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(1)
      expect(mobileAnalyticsClient.outputs.batchIndex.indexOf(indices[0])).to.eql(0)
    it 'should not delete the batch', ->
      mobileAnalyticsClient.recordEvent('should not delete batchIndex other ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices = mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(2)
      expect(mobileAnalyticsClient.outputs.batches[indices[0]]).not.to.be.undefined
    it 'should not delete the batch index from storage', ->
      mobileAnalyticsClient.recordEvent('should not delete batchIndex other ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices = mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(3)
      expect(mobileAnalyticsClient.storage.get(mobileAnalyticsClient.StorageKeys.BATCH_INDEX).indexOf(indices[0])).to.eql(0)
    it 'should not delete the batch from storage', ->
      mobileAnalyticsClient.recordEvent('should not delete batchIndex other ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices = mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(4)
      expect(mobileAnalyticsClient.storage.get(mobileAnalyticsClient.StorageKeys.BATCHES)[indices[0]]).not.to.be.undefined
      

testBatchDeleted = (errorType) ->
  describe 'Test Response Code Handling (' + errorType + ')', ->
    beforeEach ->
      mobileAnalyticsClient = new AMA.Client(clientConfig)
      currentError = createErrorResponse(errorType)
      mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
    it 'should delete the batchIndex', ->
      mobileAnalyticsClient.recordEvent('should delete batchIndex ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices = mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(1)
      expect(mobileAnalyticsClient.outputs.batchIndex.indexOf(indices[0])).to.eql(-1)
    it 'should delete the batch', ->
      mobileAnalyticsClient.recordEvent('should delete batch ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices=mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(1)
      expect(mobileAnalyticsClient.outputs.batches[indices[0]]).to.be.undefined
    it 'should delete the batch index from storage', ->
      mobileAnalyticsClient.recordEvent('should delete index storage ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices=mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(1)
      expect(mobileAnalyticsClient.storage.get(mobileAnalyticsClient.StorageKeys.BATCH_INDEX).indexOf(indices[0])).to.eql(-1)
    it 'should delete the batch from storage', ->
      mobileAnalyticsClient.recordEvent('should delete batch storage ' + errorType, {testAttribute: 'invalid'}, {testMetric: 100})
      indices=mobileAnalyticsClient.submitEvents()
      expect(indices.length).to.eql(1)
      expect(mobileAnalyticsClient.storage.get(mobileAnalyticsClient.StorageKeys.BATCHES)[indices[0]]).to.be.undefined
  
  
describe 'AMA.Manager', ->
  describe 'Initialize Client with Options', ->
    before ->
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
    it 'should be initialized', ->
      expect(mobileAnalyticsClient).not.to.be.null
      expect(mobileAnalyticsClient).not.to.be.undefined
    it 'should be an instance of AMA.Client', ->
      expect(mobileAnalyticsClient).to.be.an.instanceOf(AMA.Manager)
  describe 'Initalize Client with client', ->
    before ->
      subclient = new AMA.Client(clientConfig)
      mobileAnalyticsClient = new AMA.Manager(subclient)
    it 'should be initialized', ->
      expect(mobileAnalyticsClient).not.to.be.null
      expect(mobileAnalyticsClient).not.to.be.undefined
    it 'should be an instance of AMA.Client', ->
      expect(mobileAnalyticsClient).to.be.an.instanceOf(AMA.Manager)
  describe 'Renewing Session', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.renewSession()
    it 'should increase event count', ->
#      expect(mobileAnalyticsClient.outputs.events.length).to.eql(2)
    it 'should have a new session id', ->
      expect(mobileAnalyticsClient.outputs.events[0].eventType).to.eql('_session.stop')
      expect(mobileAnalyticsClient.outputs.events[1].eventType).to.eql('_session.start')
      expect(mobileAnalyticsClient.outputs.events[0].session.id).not.to.eql(mobileAnalyticsClient.outputs.events[1].session.id)
  describe 'Client Context Values', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      lastClientContext = JSON.parse(lastEventRequest.clientContext)
    it 'should have appTitle', ->
      expect(lastClientContext.client.app_title).to.eql('appTitle')
    it 'should have appPackageName', ->
      expect(lastClientContext.client.app_package_name).to.eql('appPackageName')
    it 'should have appVersionName', ->
      expect(lastClientContext.client.app_version_name).to.eql('appVersionName')
    it 'should have appVersionCode', ->
      expect(lastClientContext.client.app_version_code).to.eql('appVersionCode')
    it 'should have platform', ->
      expect(lastClientContext.env.platform).to.eql('platform')
    it 'should have model', ->
      expect(lastClientContext.env.model).to.eql('model')
    it 'should have make', ->
      expect(lastClientContext.env.make).to.eql('make')
    it 'should have platform_version', ->
      expect(lastClientContext.env.platform_version).to.eql('platformVersion')
    it 'should have locale', ->
      expect(lastClientContext.env.locale).to.eql('locale')
    it 'should have appId', ->
      expect(lastClientContext.services.mobile_analytics.app_id).to.eql('appId')
    it 'should have sdk', ->
      expect(lastClientContext.services.mobile_analytics.sdk_name).to.eql('aws-sdk-mobile-analytics-js')
    it 'should have sdk version', ->
      expect(lastClientContext.services.mobile_analytics.sdk_version).to.eql('0.9.2:AWS_VERSION')
  describe 'Record Monetization Event (Currency Specified)', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
      monetizationEvent = mobileAnalyticsClient.recordMonetizationEvent({
        'currency': 'USD',
        'productId': 'MyFirstProduct',
        'quantity': 1,
        'price': 4.99
      })
    it 'should return a monetization event object', ->
       expect(monetizationEvent).to.not.be.undefined
    it 'should increase event count', ->
#      expect(mobileAnalyticsClient.outputs.events.length).to.eql(1)
    it 'should specify a currency (USD)', ->
      expect(mobileAnalyticsClient.outputs.events[0].attributes._currency).to.eql('USD')
    it 'should specify a product id', ->
      expect(mobileAnalyticsClient.outputs.events[0].attributes._product_id).to.eql('MyFirstProduct')
    it 'should cost 4.99', ->
      expect(mobileAnalyticsClient.outputs.events[0].metrics._item_price).to.eql(4.99)
    it 'should have a quantity of 1', ->
      expect(mobileAnalyticsClient.outputs.events[0].metrics._quantity).to.eql(1)
  describe 'Record Monetization Event (Currency Formatted)', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.recordMonetizationEvent({'productId': 'MyFirstProduct','quantity': 1,'price': '$4.99'})
    it 'should increase event count', ->
#      expect(mobileAnalyticsClient.outputs.events.length).to.eql(1)
    it 'should specify a product id', ->
      expect(mobileAnalyticsClient.outputs.events[0].attributes._product_id).to.eql('MyFirstProduct')
    it 'should cost $4.99', ->
      expect(mobileAnalyticsClient.outputs.events[0].attributes._item_price_formatted).to.eql('$4.99')
    it 'should have a quantity of 1', ->
      expect(mobileAnalyticsClient.outputs.events[0].metrics._quantity).to.eql(1)
  describe 'Record invalid Metric Event', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
    it 'should not record an Event', ->
      mobileAnalyticsClient.recordEvent('invalidMetricEvent', {testAttribute: 'test'},{testMetric: 'invalid'})
      expect(mobileAnalyticsClient.outputs.events.length).to.eql(0)
  describe 'Record a numeric attribute', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.recordEvent('numericAttributeEvent', {testAttribute: 100},{testMetric: 100})
    it 'should specify a product id', ->
      expect(mobileAnalyticsClient.outputs.events[0].eventType).to.eql('numericAttributeEvent')
  describe 'Validate Event Attribute Key Length', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.recordEvent('invalidEvent', {invalidAttributeKeyLongStringABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ: 100},{})
    it 'should return a null event', ->
      expect(mobileAnalyticsClient.outputs.events.length).to.be.eql(0)
  describe 'Validate Event Attribute Value Length', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.recordEvent('invalidEvent', {invalidAttributeValue:'00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'},{})
    it 'should return a null event', ->
      expect(mobileAnalyticsClient.outputs.events.length).to.be.eql(0)
  describe 'Validate Event Metric Key Length', ->
    before ->
      #Clear Events
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.recordEvent('invalidEvent', {},{invalidMetricKeyLongStringABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ:100})
    it 'should return a null event', ->
      expect(mobileAnalyticsClient.outputs.events.length).to.be.eql(0)
  describe 'Record an event with Unicode attribute / metric names', ->
    it 'should specify a product id', ->
      mobileAnalyticsClient = new AMA.Manager(clientConfig)
      currentError = null
      mobileAnalyticsClient.recordEvent('numericAttributeEvent', {'活跃': 'attribute'},{'的应用': 100})
      mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
      mobileAnalyticsClient.submitEvents()
      expect(mobileAnalyticsClient.outputs.events.length).to.eql(0)
      expect(mobileAnalyticsClient.outputs.batchIndex.length).to.eql(0)
      
  describe 'Large amount of events (greater than batchSize)', ->
    it 'should autosubmit', ->
      myConfig = JSON.parse(JSON.stringify(clientConfig))
      myConfig.batchSizeLimit = 3026
      mobileAnalyticsClient = new AMA.Manager(myConfig)
      currentError = null
      for x in [0..10]
        do (x) ->
          mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
          mobileAnalyticsClient.recordEvent('autoSubmitByBatch', {testAttribute: 'valid'}, {testMetric: 100})
      expect(mobileAnalyticsClient.outputs.events.length).to.eql(0)
      expect(mobileAnalyticsClient.outputs.batchIndex.length).to.eql(0)
  describe 'Test Response Code Handling', ->
    testBatchDeleted(null)
    testBatchDeleted('ValidationException')
    testBatchDeleted('SerializationException')
    testBatchDeleted('BadRequestException')
    testBatchNotDeleted('OtherException')

  describe 'Test Event Order (Retryable) Handling', ->
    batchSet1 = []
    batchSet2 = []
    batchSet3 = []
    batchSet4 = []
    beforeEach ->
      mobileAnalyticsClient = new AMA.Client(clientConfig)
      mobileAnalyticsClient.storage.delete(mobileAnalyticsClient.StorageKeys.BATCHES)
      mobileAnalyticsClient.storage.delete(mobileAnalyticsClient.StorageKeys.BATCH_INDEX)
      mobileAnalyticsClient = new AMA.Client(clientConfig)
      currentError = createErrorResponse('OtherException')
      mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
      mobileAnalyticsClient.recordEvent('orderEvent0', {testAttribute: 0})
      mobileAnalyticsClient.recordEvent('orderEvent1', {testAttribute: 1})
      batchSet1 = mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
      mobileAnalyticsClient.recordEvent('orderEvent2', {testAttribute: 2})
      mobileAnalyticsClient.recordEvent('orderEvent3', {testAttribute: 3})
      batchSet2 = mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
      mobileAnalyticsClient.recordEvent('orderEvent4', {testAttribute: 4})
      mobileAnalyticsClient.recordEvent('orderEvent5', {testAttribute: 5})
      batchSet3 = mobileAnalyticsClient.submitEvents()
      mobileAnalyticsClient.outputs.lastSubmitTimestamp = 0
      mobileAnalyticsClient.recordEvent('orderEvent6', {testAttribute: 6})
      mobileAnalyticsClient.recordEvent('orderEvent7', {testAttribute: 7})
      batchSet4 = mobileAnalyticsClient.submitEvents()
    it 'should have 4 batches', ->
      expect(mobileAnalyticsClient.outputs.batchIndex.length).to.eql(4)
      expect(Object.keys(mobileAnalyticsClient.outputs.batches).length).to.eql(4)
    it 'should persist 4 batches', ->
      expect(mobileAnalyticsClient.storage.get(mobileAnalyticsClient.StorageKeys.BATCH_INDEX).length).to.eql(4)
      expect(Object.keys(mobileAnalyticsClient.storage.get(mobileAnalyticsClient.StorageKeys.BATCHES)).length).to.eql(4)
    it 'should have batches in same order as submissions', ->
      expect(mobileAnalyticsClient.outputs.batchIndex[0]).to.eql(batchSet1[0])
      expect(mobileAnalyticsClient.outputs.batchIndex[1]).to.eql(batchSet2[1])
      expect(mobileAnalyticsClient.outputs.batchIndex[2]).to.eql(batchSet3[2])
      expect(mobileAnalyticsClient.outputs.batchIndex[3]).to.eql(batchSet4[3])
    it 'should have events in the correct order in the batches', ->
      checkBatch = (batchId) ->
        batch = mobileAnalyticsClient.outputs.batches[batchId]
        console.log(JSON.stringify(batch))
        expect(parseInt(batch[0].eventType.replace('orderEvent', ''))).to.be.below(parseInt(batch[1].eventType.replace('orderEvent', '')))
      checkBatch batchId for batchId in mobileAnalyticsClient.outputs.batchIndex

  describe 'Multiple SDK Instances', ->
    before ->
      s1 = new AMA.Storage('id1')
      s1.clearLocalStorage()
      s2 = new AMA.Storage('id2')
      s2.clearLocalStorage()
      m1 = new AMA.Manager(AMA.Util.copy({appId: 'id1'}, clientConfig))
      m2 = new AMA.Manager(AMA.Util.copy({appId: 'id2'}, clientConfig))
      m1_2 = new AMA.Manager(AMA.Util.copy({appId: 'id1'}, clientConfig))
      m1.recordEvent('m1event1')
      m1.recordEvent('m1event2')
      m2.recordEvent('m2event1')
    it 'm1 should have only m1 events', ->
      expect(m1.client.storage.cache.AWSMobileAnalyticsEventStorage.length).to.eql(2);
      expect(m1.client.storage.cache.AWSMobileAnalyticsEventStorage[0].eventType).to.eql('m1event1');
      expect(m1.client.storage.cache.AWSMobileAnalyticsEventStorage[1].eventType).to.eql('m1event2');
    it 'm2 should have only m2 event', ->
      expect(m2.client.storage.cache.AWSMobileAnalyticsEventStorage.length).to.eql(1);
      expect(m2.client.storage.cache.AWSMobileAnalyticsEventStorage[0].eventType).to.eql('m2event1');
    it 'm1_2 should have same client id as m1', ->
      expect(m1.client.options.clientContext.client.client_id).to.eql(m1_2.client.options.clientContext.client.client_id)
  describe 'Throttling Interval Backoff', ->
    before ->
      s1 = new AMA.Storage('throttlingId')
      s1.clearLocalStorage()
      m1 = new AMA.Manager(AMA.Util.copy({
        appId: 'throttlingId',
        autoSubmitEvents: false
      }, clientConfig))
      currentError = createErrorResponse('OtherException')
      m1.outputs.lastSubmitTimestamp = 0
      lastWarn = undefined
      lastLog = undefined
      batchIds = m1.submitEvents()
      currentError = createErrorResponse('ThrottlingException')
      m1.recordEvent('custom_event')
      m1.outputs.lastSubmitTimestamp = 0
      lastWarn = undefined
      lastLog = undefined
      m1.submitEvents()
      expect(m1.outputs.isThrottled).to.eql(true);
      Math._random = Math.random
      Math.random = () -> 1
    after ->
      Math.random = Math._random
    it 'm1 should not submit if at 30s', ->
      m1.outputs.lastSubmitTimestamp = (new Date()).getTime() - (30 * 1000)
      expect(m1.outputs.isThrottled).to.eql(true);
      expect(Object.keys(m1.outputs.batchesInFlight).length).to.eql(0);
      expect(Object.keys(m1.outputs.batches).length).to.eql(2);
      tmp = m1.submitEvents()
      expect(tmp).to.eql([]);
    it 'm1 should submit if at 60s', ->
      m1.outputs.lastSubmitTimestamp = (new Date()).getTime() - (60 * 1001)
      currentError = null
      expect(m1.outputs.isThrottled).to.eql(true);
      expect(Object.keys(m1.outputs.batchesInFlight).length).to.eql(0);
      expect(Object.keys(m1.outputs.batches).length).to.eql(2);
      phoneHomeBatch = m1.submitEvents({submitCallback: countSubmissionCallback})
      console.log(lastWarn)
      expect(phoneHomeBatch.length).to.eql(1);
      expect(phoneHomeBatch).to.eql([batchIds[0]]);
      expect(submissions).to.eql(2)