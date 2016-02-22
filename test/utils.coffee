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
a =
b =
describe 'AMA.Util', ->
  describe 'GUID', ->
    it 'should not be equal', ->
      expect(AMA.Util.GUID()).to.not.eql(AMA.Util.GUID())
  describe 'mergeObjects', ->
    beforeEach ->
      a = {a: 1, b:2}
      b = {b:1, c:3}
    it 'should merge with overlapping keys', ->
      expect(AMA.Util.mergeObjects(a, b)).to.eql({a:1, b:2, c:3})
    it 'should mutate original', ->
      expect(AMA.Util.mergeObjects(a, b)).to.equal(a)
  describe 'utf8ByteLength', ->
    it 'should test char codes > 127', ->
      expect(AMA.Util.getRequestBodySize('©‰')).to.eql(5)
    it 'should test trail surrogate', ->
      expect(AMA.Util.getRequestBodySize('𝌆')).to.eql(4)
  describe 'copy', ->
    beforeEach ->
      a = {a: 1, b:2}
      b = {c: 3}
    it 'should copy with new keys', ->
      expect(AMA.Util.copy(a, b)).to.eql({a:1, b:2, c:3})
    it 'should not mutate original', ->
      expect(AMA.Util.copy(a, b)).to.not.equal(a)