/*
  Copyright 2014-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
  Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with
  the License. A copy of the License is located at http://aws.amazon.com/apache2.0/
  or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
  and limitations under the License.
*/

var AMA = global.AMA;

AMA.StorageKeys = {
    'CLIENT_ID': 'AWSMobileAnalyticsClientId',
    'GLOBAL_ATTRIBUTES': 'AWSMobileAnalyticsGlobalAttributes',
    'GLOBAL_METRICS': 'AWSMobileAnalyticsGlobalMetrics',
    'SESSION_ID': 'MobileAnalyticsSessionId',
    'SESSION_EXPIRATION': 'MobileAnalyticsSessionExpiration',
    'SESSION_START_TIMESTAMP': 'MobileAnalyticsSessionStartTimeStamp'
};

module.exports = AMA.StorageKeys;
