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
AMA = helpers.AMA
expiration = null
session = null
storage = new AMA.Storage('AppID')

describe 'AMA.Session', ->
  describe 'Initialize Session (Default Values)', ->
    before ->
      session = new AMA.Session({storage: storage})
    it 'should be initialized', ->
      expect(session).not.to.be.null
      expect(session).not.to.be.undefined
    it 'should have scoped sessionId storage key', ->
      expect(session.StorageKeys.SESSION_ID).to.not.eql('MobileAnalyticsSessionId')
      expect(session.StorageKeys.SESSION_ID).to.have.string('MobileAnalyticsSessionId')
      expect(session.StorageKeys.SESSION_ID).to.have.string(session.id)
    it 'should have scoped sessionExpiration storage key', ->
      expect(session.StorageKeys.SESSION_EXPIRATION).to.not.eql('MobileAnalyticsSessionExpiration')
      expect(session.StorageKeys.SESSION_EXPIRATION).to.have.string('MobileAnalyticsSessionExpiration')
      expect(session.StorageKeys.SESSION_EXPIRATION).to.have.string(session.id)
    it 'should persist session id', ->
      expect(storage.get(session.StorageKeys.SESSION_ID)).not.to.be.null
      expect(storage.get(session.StorageKeys.SESSION_ID)).to.eql(session.id)
    it 'should persist expiration', ->
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).not.to.be.null
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.eql(session.expirationDate)
    it 'should have a number expiration', ->
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.be.a('number')
      expect(session.expirationDate).to.be.a('number')
    it 'should have an integer expiration', ->
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION) % 1).to.eql(0)
      expect(session.expirationDate % 1).to.eql(0)
  describe 'Clear Session', ->
    before ->
      session = new AMA.Session({storage: storage})
      session.expireSession()
    it 'should clear session id', ->
      expect(storage.get(session.StorageKeys.SESSION_ID)).to.be.undefined
    it 'should clear session expiration', ->
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.be.undefined
  ###
    Needs duplicate session/expiration definitions due to Storage getting reloaded in another file.
  ###
  describe 'Extend Session (Default Values)', ->
    before ->
      session = new AMA.Session({storage: storage})
      expiration = session.expirationDate
      session.extendSession()
    it 'should not be original expiration date', ->
      expect(expiration).to.not.eql(session.expirationDate)
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.not.eql(expiration)
    it 'should persist new expiration date', ->
      session = new AMA.Session({storage: storage})
      expiration = session.expirationDate
      session.extendSession()
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.eql(session.expirationDate)
    it 'should be 30min later', ->
      expect(session.expirationDate).to.eql(expiration + session.sessionLength)
  describe 'Extend Session (1 min later)', ->
    before ->
      session = new AMA.Session({storage: storage})
      expiration = session.expirationDate
      session.extendSession(60000)
    it 'should not be original expiration date', ->
      expect(expiration).to.not.eql(session.expirationDate)
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.not.eql(expiration)
    it 'should persist new expiration date', ->
      session = new AMA.Session({storage: storage})
      expiration = session.expirationDate
      session.extendSession(60000)
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.eql(session.expirationDate)
    it 'should be 60 sec later', ->
      expect(session.expirationDate).to.eql(expiration + 60000)
  describe 'Reset Session Timeout (1 min from now)', ->
    beforeEach ->
      session = new AMA.Session({storage: storage})
      expiration = session.expirationDate
      session.resetSessionTimeout(60000)
    it 'should not be original expiration date', ->
      expect(expiration).to.not.eql(session.expirationDate)
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.not.eql(expiration)
    it 'should persist new expiration date', ->
      expect(storage.get(session.StorageKeys.SESSION_EXPIRATION)).to.eql(session.expirationDate)
