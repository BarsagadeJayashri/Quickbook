public class QuickbookInvoiceIntegration {
    public static string oppName{get;set;}
    public static date oppCloseDate{get;set;}
    public static string oppAmount{get;set;}
    public static string oppAccName{get;set;}
    public static void createInvoiceBody(list<Opportunity> opportunityList){
        Opportunity opportunityObj = [SELECT Id, AccountId, Amount, CloseDate, Name,Account.Name FROM Opportunity WHERE Id IN: opportunityList];
        oppName=opportunityObj.Name;
        oppCloseDate=opportunityObj.CloseDate;
        oppAmount=opportunityObj.Amount.toplainstring();
        oppAccName=opportunityObj.Account.Name;
        createInvoice(oppName,oppAccName,oppAmount,oppCloseDate);
    }
    
    @future(callout=true)
    public static void createInvoice(string Name,string accName,string amount,date closeDate){
        system.debug(accName);
        String InvoiceQuery='select%20*%20from%20Item%20where%20Name=\'Services\'';
        String InvoiceBaseUrl = 'callout:QuickbookNamedCredential/v3/company/9130355912005176/query?query='+InvoiceQuery+'&minorversion=4';
        
        // Send a GET request to the API to retrieve the list of items
        Http httpInvoice = new Http();
        HttpRequest requestInvoice = new HttpRequest();
        requestInvoice.setMethod('GET');
        requestInvoice.setEndpoint(InvoiceBaseUrl);
        requestInvoice.setHeader('Accept', 'application/json');
        //req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        HttpResponse responseInvoice = httpInvoice.send(requestInvoice);
        system.debug('########'+responseInvoice.getBody());
        
        String InvoiceResponseBody = responseInvoice.getBody();
        
        // parse the JSON string
        Map<String, Object> InvoiceResponseMap = (Map<String, Object>) JSON.deserializeUntyped(InvoiceResponseBody);
        Map<String, Object> InvoiceQueryResponse = (Map<String, Object>) InvoiceResponseMap.get('QueryResponse');
        List<Object> inoviceItems = (List<Object>) InvoiceQueryResponse.get('Item');
        Map<String, Object> invoiceItem = (Map<String, Object>) inoviceItems.get(0);
        string invoiceId = (String) invoiceItem.get('Id');
        system.debug('******'+invoiceId);
        
        String CustomerQuery='select%20*%20from%20Customer%20Where%20DisplayName=\''+EncodingUtil.urlEncode(accName,'UTF-8').replaceAll('\\+','%20')+'\'';
        String CustomerBaseUrl = 'callout:QuickbookNamedCredential/v3/company/9130355912005176/query?query='+CustomerQuery+'&minorversion=65';
        
        // Send a GET request to the API to retrieve the list of items
        Http httpCustomer = new Http();
        HttpRequest customerRequest = new HttpRequest();
        customerRequest.setMethod('GET');
        customerRequest.setEndpoint(CustomerBaseUrl);
        customerRequest.setHeader('Accept', 'application/json');
        //req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        HttpResponse customerResponse = httpCustomer.send(customerRequest);
        system.debug('########'+customerResponse.getBody());
        
        String customerResponseBody = customerResponse.getBody();
        
        // parse the JSON string
        Map<String, Object> CustomerResponseMap = (Map<String, Object>) JSON.deserializeUntyped(customerResponseBody);
        Map<String, Object> customerQueryResponse = (Map<String, Object>) CustomerResponseMap.get('QueryResponse');
        List<Object> customerItems = (List<Object>) customerQueryResponse.get('Customer');
        Map<String, Object> customerItem = (Map<String, Object>) customerItems.get(0);
        string customerId = (String) customerItem.get('Id');
        system.debug('******'+Customerid);
        
        
        // Build the request body
        Map<String, Object> body = new Map<String, Object>();
        List<Map<String, Object>> lines = new List<Map<String, Object>>();
        Map<String, Object> line = new Map<String, Object>();
        line.put('DetailType', 'SalesItemLineDetail');
        line.put('Amount', amount);
        Map<String, Object> salesItemLineDetail = new Map<String, Object>();
        Map<String, Object> itemRef = new Map<String, Object>();
        itemRef.put('name', 'Services');
        itemRef.put('value',invoiceId);
        salesItemLineDetail.put('ItemRef', itemRef);
        line.put('SalesItemLineDetail', salesItemLineDetail);
        lines.add(line);
        body.put('Line', lines);
        Map<String, Object> customerRef = new Map<String, Object>();
        customerRef.put('value', customerId);
        customerRef.put('name', accName);
        body.put('CustomerRef', customerRef);
        integer day=closeDate.day();
        integer month=closeDate.month();
        integer year=closeDate.year();
        body.put('TxnDate', year+'/'+month+'/'+day);
        
        string jsonString = JSON.serializePretty(body); 
        system.debug(jsonString);
        
        // Authenticate with QuickBooks
        //String accessToken = QuickBooksAuthHelper.getAccessToken();
        
        // Create the invoice in QuickBooks
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:QuickbookNamedCredential/v3/company/9130355912005176/invoice?minorversion=65');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        req.setBody(jsonString);
        // Send the request
        HttpResponse res = h.send(req);
        System.debug(res.getBody());
    }
    
}