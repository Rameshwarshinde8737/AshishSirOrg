@isTest
private class ToolingAPITest {
  /*  private static final String NAMESPACE_PREFIX = 'leankor'; 
    private static final String SALESFORCE_API_VERSION = 'v55.0';
    private static final String queryString ='Select+Id,Name+From+CustomLabel+Where+Category+In + (LeankorBase,LeankorCalendar,Page.leankornav) +And+NamespacePrefix=\'' + NAMESPACE_PREFIX + '\'';
   
    private class ToolingMockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request){
            System.assertEquals('GET',request.getMethod());
			HttpResponse response = new HttpResponse();
            response.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            response.setHeader('Content-Type', 'application/json');
            response.setbody('{"size":433,"totalSize":433,"done":true,"queryLocator":null,"entityTypeName":"ExternalString","records":[{"attributes":{"type":"ExternalString","url":"/services/data/'+SALESFORCE_API_VERSION+'/tooling/sobjects/ExternalString/1010W000003H7APQA0"},"Id":"1010W000003H7APQA0","Name":"AccessBoardPermissionError"},{"attributes":{"type":&qu');
            response.SetStatusCode(200);
            return response;
        }
    }
    
	@isTest
    private static void quryTest() {
     	Test.setMock(HttpCalloutMock.class,new ToolingMockHttpResponse());
        Set<String> consumer = new Set<String>{'LeankorBase', 'Page.LeankorNav'};
        ToolingAPI tool = new ToolingAPI();
        HttpResponse response = tool.query('Select+Id,Name+From+CustomLabel+Where+Category+In + (LeankorBase,Page.leankornav) +And+NamespacePrefix=\'' + NAMESPACE_PREFIX + '\'');
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        String expectedValue = '{"size":433,"totalSize":433,"done":true,"queryLocator":null,"entityTypeName":"ExternalString","records":[{"attributes":{"type":"ExternalString","url":"/services/data/'+SALESFORCE_API_VERSION+'/tooling/sobjects/ExternalString/1010W000003H7APQA0"},"Id":"1010W000003H7APQA0","Name":"AccessBoardPermissionError"},{"attributes":{"type":&qu';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, response.getStatusCode());
    }
   
    @isTest
    private static void getDomainURLTest(){
        ToolingAPI tool = new ToolingAPI();
        String result = tool.getDomainURL();
        System.assertEquals(URL.getOrgDomainUrl().toExternalForm(), result);
    }
    
    @isTest
    private static void getNetworkUrlTest(){
        ToolingAPI tool = new ToolingAPI();
        String networkId = null;
        Boolean flag = true;
        //String base = tool.getNetworkUrl(networkId,URL.getSalesforceBaseUrl().toExternalForm());
        //System.assert(base != null);
        System.assertEquals(true, flag);
    }*/
 }