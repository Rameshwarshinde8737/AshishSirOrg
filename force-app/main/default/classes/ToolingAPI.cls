/*---------------------------------------------------------------------------------------
* Copyright 2012-2016 Leankor All rights reserved
Author     :    RBO
Company    :    Leankor
Description:    Implementation of Salesforce's Tooling API
Test Class  :   ToolingAPITest
---------------------------------------------------------------------------------------*/
public virtual class ToolingAPI {    
  /*  private final String ORG_DOMAIN_URL = getDomainURL();
    private final String SALESFORCE_API_VERSION = 'v55.0';

    public virtual HttpResponse executeAnonymous(String apexCode) {  
        //--- request Tooling API - executeAnonymous
        //--- https://{domain}.my.salesforce.com must be configured in Remote Site Settings
        String endPoint = ORG_DOMAIN_URL + '/services/data/' + SALESFORCE_API_VERSION + '/tooling/executeAnonymous/?anonymousBody=' + apexCode;
        HttpRequest request = setHttpRequest(endPoint);
        
        //--- At the end of each request, add the following code to send the request and retrieve the body of the response:
        HttpResponse response = setHttpResponse(request);        
        return response;
    }


    public virtual HttpResponse query(String queryString) {
        //--- Tooling API - query
        //--- https://{domain}.my.salesforce.com must be configured in Remote Site Settings
        String endPoint = ORG_DOMAIN_URL + '/services/data/' + SALESFORCE_API_VERSION + '/tooling/query/?q=' + queryString;
        HttpRequest request = setHttpRequest(endPoint);
                
        //--- At the end of each request, add the following code to send the request and retrieve the body of the response:
        HttpResponse response = setHttpResponse(request);
        return response;
    }


    //---Set up the connection to the org and the HTTP request type
    @TestVisible
    private HttpRequest setHttpRequest(string endPoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        return request;
    }


    //--- Send the request and retrieve the body of the response:
    @TestVisible
    private HttpResponse setHttpResponse(HttpRequest request) {
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }


    @TestVisible
    private String getDomainURL() {
        String networkId = Network.getNetworkId();
        return 
            String.isBlank(networkId)
            ? URL.getOrgDomainUrl().toExternalForm()
            : getNetworkUrl(networkId, URL.getSalesforceBaseUrl().toExternalForm());
    }


    @TestVisible
    private String getNetworkUrl(String networkId, String baseUrl) {
        for (sObject tempNetwork : Database.query('Select UrlPathPrefix From Network Where Id = :networkId')) {
            if (tempNetwork.get('UrlPathPrefix') != null) {            
                baseUrl = baseUrl + '/' + tempNetwork.get('UrlPathPrefix');
            }
        }
        return baseUrl;
    }*/
}