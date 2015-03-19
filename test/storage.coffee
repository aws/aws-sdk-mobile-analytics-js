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

describe 'AMA.Storage (In Memory)', ->
  it 'should set ascii', ->
    AMA.Storage.set('_test123', '_test123')
    expect(AMA.Storage.get('_test123')).to.equal('_test123')
  it 'should delete stored ascii', ->
    AMA.Storage.delete('_test123')
    expect(AMA.Storage.get('_test123')).to.equal()
    
describe 'AMA.Storage (LocalStorage)', ->
  it 'should set ascii', ->
    AMA.Storage.set('_test123', '_test123')
    expect(AMA.Storage.get('_test123')).to.equal('_test123')
  it 'should delete stored ascii', ->
    AMA.Storage.delete('_test123')
    expect(AMA.Storage.get('_test123')).to.equal()