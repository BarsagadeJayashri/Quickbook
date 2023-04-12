public class createCustomerWebservice{
    //Customer record will be created when opportunity status is "Closed Won".
    public static void createCustomer(list<Account> accList){
        //get opportunity
        list<Account> accRecord =[Select Id,Name,Phone,Website,Fax,BillingCity,BillingStreet,BillingPostalCode,BillingCountry,ShippingCity,ShippingStreet,ShippingPostalCode,ShippingCountry From Account where Id In: accList];
        
        Map<String, Object> requestBody = new Map<String, Object>();
        if(!accRecord.isEmpty()){
            requestBody.put('FullyQualifiedName', accRecord[0].Name);
            Map<String, Object> primaryEmailAddr = new Map<String, Object>();
            primaryEmailAddr.put('Address', '');
            requestBody.put('PrimaryEmailAddr', primaryEmailAddr);
            requestBody.put('DisplayName', accRecord[0].Name);
            requestBody.put('Suffix', '');
            requestBody.put('Title', '');
            requestBody.put('MiddleName', '');
            requestBody.put('Notes', '');
            requestBody.put('FamilyName', '');
            Map<String, Object> primaryPhone = new Map<String, Object>();
            primaryPhone.put('FreeFormNumber',accRecord[0].Phone);
            requestBody.put('PrimaryPhone', primaryPhone);
            requestBody.put('CompanyName', accRecord[0].Name);
            Map<String, Object> billAddr = new Map<String, Object>();
            billAddr.put('CountrySubDivisionCode', '');
            billAddr.put('City', accRecord[0].BillingCity);
            billAddr.put('PostalCode', accRecord[0].BillingPostalCode);
            billAddr.put('Line1', accRecord[0].BillingStreet);
            billAddr.put('Country', accRecord[0].BillingCountry);
            requestBody.put('BillAddr', billAddr);
            Map<String, Object> shippingAddr = new Map<String, Object>();
            shippingAddr.put('CountrySubDivisionCode', '');
            shippingAddr.put('City', accRecord[0].ShippingCity);
            shippingAddr.put('PostalCode', accRecord[0].ShippingPostalCode);
            shippingAddr.put('Line1', accRecord[0].ShippingStreet);
            shippingAddr.put('Country', accRecord[0].ShippingCountry);
            requestBody.put('ShipAddr', shippingAddr);
            requestBody.put('GivenName', '');
            Map<String, Object> fax = new Map<String, Object>();
            fax.put('FreeFormNumber',accRecord[0].Fax);
            requestBody.put('Fax', fax);
            Map<String, Object> webAddr = new Map<String, Object>();
            string website = accRecord[0].Website;
            if(website.startsWith('https://')){
                webAddr.put('URI',website);
            }
            else{
            webAddr.put('URI','https://'+website);
            }
            requestBody.put('WebAddr', webAddr);
            string jsonString = JSON.serializePretty(requestBody); 
            system.debug(jsonString);
            insertOnQuickBook(jsonString, accRecord[0].Id);
        }
        
    }
    @future(callout =true)
    public static void insertOnQuickBook(String jsonData,string recId){
        HttpRequest req = new HttpRequest();
        string  endPointURL = 'callout:QuickbookNamedCredential/v3/company/9130355912005176/customer?minorversion=65';
        req.setEndpoint(endPointURL);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json'); 
        req.setHeader('Content-Length', '512');
        req.setBody(jsonData);
        //req.setTimeout(12000);
        system.debug('--req--'+req);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        //Response Handle
        system.debug(response.getStatusCode());
        if(response.getStatusCode() == 200 ){
            system.debug('-Response--'+response.getBody());
            system.debug('--deserialize'+JSON.deserializeUntyped(response.getBody()));
            Map<String, Object> deserializeResponseBody = new Map<String, Object>();
            deserializeResponseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('serializeResponseBody>>'+JSON.serializePretty(deserializeResponseBody));
            Map<String, Object> customerData = (Map<String, Object>) deserializeResponseBody.get('Customer');
string idValue = (string) customerData.get('Id');
System.debug('Id value: ' + idValue);
            Account objAcc= [select Id,Quickbook_Customer_Id__c from Account where Id=:recId];
            objAcc.Quickbook_Customer_Id__c=idValue;
            database.update(objAcc);
        }
    }
}