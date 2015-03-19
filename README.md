# Amazon Mobile Analytics Client for JavaScript

**Developer Preview:** We welcome developer feedback on this project. You can reach us by creating an issue on the 
GitHub repository or posting to the Amazon Mobile Analytics forums:
* https://github.com/aws/aws-sdk-mobile-analytics-js
* https://forums.aws.amazon.com/forum.jspa?forumID=174

Introduction
============
The Mobile Analytics Client for JavaScript allows JavaScript enabled applications to create and submit events for analysis in the AWS Console and through Auto Export to S3 and Redshift. The library uses the browser's local storage API to create a local cache for the data, allowing your web application to batch and record events even when the app is offline.

## Setup

1. Download and include the AWS JavaScript SDK (minimum version 2.1.18):
  * http://aws.amazon.com/sdk-for-browser/

2. Download and include the Amazon Mobile Analytics Client for JavaScript:
  * [/dist/aws-sdk-mobile-analytics.min.js](https://raw.githubusercontent.com/aws/aws-sdk-mobile-analytics-js/master/dist/aws-sdk-mobile-analytics.min.js)

<pre class="prettyprint">
    &lt;script src="/js/aws-sdk.min.js"&gt;&lt;/script&gt;
    &lt;script src="/js/aws-sdk-mobile-analytics.min.js"&gt;&lt;/script&gt;
</pre>

## Usage

**Step 1.** Log in to the [Amazon Mobile Analytics management console](https://console.aws.amazon.com/mobileanalytics/home/?region=us-east-1) and create a new app. Be sure to note your App Id and Cognito Identity Pool Id.
* https://console.aws.amazon.com/mobileanalytics/home/?region=us-east-1

**Step 2.** Initialize the credentials provider using a Cognito Identity Pool ID. This is necessary for the AWS SDK to manage authentication to the Amazon Mobile Analytics REST API.

<pre class="prettyprint">
    AWS.config.region = 'us-east-1';
    AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: COGNITO_IDENTITY_POOL_ID   //Required e.g. 'us-east-1:12345678-c1ab-4122-913b-22d16971337b'
    });
</pre>

**Step 3.** Instantiate the Mobile Analytics Manager, including your App ID generated in Step 1, above. Session events will be automatically recorded and the client will batch and automatically submit events to Amazon Mobile Analytics every 10 seconds.

<pre class="prettyprint">
    var options = {
        appId : MOBILE_ANALYTICS_APP_ID   //Required e.g. 'c5d69c75a92646b8953126437d92c007'
    };
    mobileAnalyticsClient = new AMA.Manager(options);
</pre>

To manually force an event submission you can call:
<pre class="prettyprint">
    mobileAnalyticsClient.submitEvents();
</pre>

## Additional Options
### Custom Events
<a name="customevent"></a>
You can optionally add custom events to capture additional information you find valuable.

<pre class="prettyprint">
    mobileAnalyticsClient.recordEvent('CUSTOM EVENT NAME', {
            'ATTRIBUTE_1_NAME': 'ATTRIBUTE_1_VALUE',
            'ATTRIBUTE_2_NAME': 'ATTRIBUTE_2_VALUE'
            /* ... */
        }, {
            'METRIC_1_NAME': 1,
            'METRIC_2_NAME': 99.3
            /* ... */
        });
</pre>


### Session Settings
By default a session lasts 10 minutes. You can override this default setting when initializing the Mobile Analytics Manager by including "sessionLength" in the "options" object.

<pre class="prettyprint">
    var options = {
        appId : MOBILE_ANALYTICS_APP_ID, 
        sessionLength: 300000            //Session Length in milliseconds.  This will evaluate to 5min.
    };
    mobileAnalyticsClient = new AMA.Manager(options);
</pre>

A session's timeout can also be updated to allow for continuation of a session.

<pre class="prettyprint">
    //This will set the current session to expire in 5 seconds from now.
    mobileAnalyticsClient.resetSessionTimeout(5000); 
    
    //This will reset the current session's expiration time using the time specified during initialization. 
    //If the default setting was used (10 minutes) then the session will expire 10 minutes from now. 
    mobileAnalyticsClient.resetSessionTimeout();
</pre>

### Record Monetization Event
You can record monetization events to enable reports such as Average Revenue Per User (ARPU) and more.

<pre class="prettyprint">
    mobileAnalyticsClient.recordMonetizationEvent(
        {
            productId : PRODUCT_ID,   //Required e.g. 'My Example Product'
            price : PRICE,            //Required e.g. 1.99
            quantity : QUANTITY,      //Required e.g. 1
            currency : CURRENCY_CODE  //Optional ISO currency code e.g. 'USD'
        }, 
        {/* Custom Attributes */}, 
        {/* Custom Metrics */}
    );
</pre>

### Add App Details to Events
Additional app and environment details can be added to the "options" object when initializing the SDK. These details will be captured and applied to all events and can be useful if using Auto Export for custom analysis of your data.

<pre class="prettyprint">
    var options = {
        appId : MOBILE_ANALYTICS_APP_ID,       //Required e.g. 'c5d69c75a92646b8953126437d92c007'
        appTitle : APP_TITLE,                  //Optional e.g. 'Example App'
        appVersionName : APP_VERSION_NAME,     //Optional e.g. '1.4.1'
        appVersionCode : APP_VERSION_CODE,     //Optional e.g. '42'
        appPackageName : APP_PACKAGE_NAME,     //Optional e.g. 'com.amazon.example'
        make : DEVICE_MAKE,                    //Optional e.g. 'Amazon'
        model : DEVICE_MODEL,                  //Optional e.g. 'KFTT'
        platform : DEVICE_PLATFORM,            //Optional e.g. 'Android'
        platformVersion : DEVICE_PLATFORM_VER  //Optional e.g. '4.4'
    };
    mobileAnalyticsClient = new AMA.Manager(options);
</pre>

Please note, if device details are not specified Amazon Mobile Analytics will make best efforts to determine these values based on the User-Agent header value. It is always better to specify these values during initialization if they are available. 

### Further Documentation
Further documentation and advanced configurations can be found here:

https://aws.github.io/aws-sdk-mobile-analytics-js/doc/AMA.Manager.html

## Network Configuration
The Amazon Mobile Analytics JavaScript SDK will make requests to the following endpoints
* For Event Submission: "https://mobileanalytics.us-east-1.amazonaws.com"
* For Cognito Authentication: "https://cognito-identity.us-east-1.amazonaws.com"
** This endpoint may change based on which region your Identity Pool was created in.
 
For most frameworks you can whitelist both domains by whitelisting all AWS endpoints with "*.amazonaws.com".

## Change Log

**v0.9.0:**
* Initial release. Developer preview.
