public class createCustomerWebservice{
    //Customer record will be created when opportunity status is "Closed Won".
    public static void createCustomer(list<Opportunity> oppList){
        //get opportunity
        
        list<Opportunity> oppRecord =[SELECT AccountId,Amount,CampaignId,CloseDate,ContactId,CreatedById,CreatedDate,CurrentGenerators__c,
                                      DeliveryInstallationStatus__c,Description,ExpectedRevenue,Fiscal,FiscalQuarter,FiscalYear,ForecastCategory,
                                      ForecastCategoryName,HasOpenActivity,HasOpportunityLineItem,HasOverdueTask,Id,IsClosed,IsDeleted,IsPrivate,IsWon,
                                      LastActivityDate,LastAmountChangedHistoryId,LastCloseDateChangedHistoryId,LastModifiedById,LastModifiedDate,
                                      LastReferencedDate,LastStageChangeDate,LastViewedDate,LeadSource,MainCompetitors__c,Name,NextStep,OrderNumber__c,
                                      OwnerId,Pricebook2Id,Probability,PushCount,StageName,SystemModstamp,TotalOpportunityQuantity,TrackingNumber__c,
                                      Type,Account.Name,Account.BillingCity,Account.BillingCountry,Account.BillingPostalCode,Account.BillingState,
                                      Account.BillingStreet,Account.ShippingCity,Account.ShippingCountry,Account.ShippingPostalCode,Account.ShippingState,
                                      Account.ShippingStreet,Account.Phone,Account.Fax,Account.Website FROM Opportunity where Id =:oppList[0].Id and StageName=:'Closed Won'];
        
        Map<String, Object> requestBody = new Map<String, Object>();
        if(!oppRecord.isEmpty()){
            requestBody.put('FullyQualifiedName', oppRecord[0].Name);
            Map<String, Object> primaryEmailAddr = new Map<String, Object>();
            primaryEmailAddr.put('Address', '');
            requestBody.put('PrimaryEmailAddr', primaryEmailAddr);
            requestBody.put('DisplayName', oppRecord[0].Name);
            requestBody.put('Suffix', '');
            requestBody.put('Title', '');
            requestBody.put('MiddleName', '');
            requestBody.put('Notes', '');
            requestBody.put('FamilyName', '');
            Map<String, Object> primaryPhone = new Map<String, Object>();
            primaryPhone.put('FreeFormNumber',oppRecord[0].Account.Phone);
            requestBody.put('PrimaryPhone', primaryPhone);
            requestBody.put('CompanyName', oppRecord[0].Account.Name);
            Map<String, Object> billAddr = new Map<String, Object>();
            billAddr.put('CountrySubDivisionCode', '');
            billAddr.put('City', oppRecord[0].Account.BillingCity);
            billAddr.put('PostalCode', oppRecord[0].Account.BillingPostalCode);
            billAddr.put('Line1', oppRecord[0].Account.BillingStreet);
            billAddr.put('Country', oppRecord[0].Account.BillingCountry);
            requestBody.put('BillAddr', billAddr);
            Map<String, Object> shippingAddr = new Map<String, Object>();
            shippingAddr.put('CountrySubDivisionCode', '');
            shippingAddr.put('City', oppRecord[0].Account.ShippingCity);
            shippingAddr.put('PostalCode', oppRecord[0].Account.ShippingPostalCode);
            shippingAddr.put('Line1', oppRecord[0].Account.ShippingStreet);
            shippingAddr.put('Country', oppRecord[0].Account.ShippingCountry);
            requestBody.put('ShipAddr', shippingAddr);
            requestBody.put('GivenName', '');
            Map<String, Object> fax = new Map<String, Object>();
            fax.put('FreeFormNumber',oppRecord[0].Account.Fax);
            requestBody.put('Fax', fax);
            Map<String, Object> webAddr = new Map<String, Object>();
            string website = oppRecord[0].Account.Website;
            webAddr.put('URI','https://'+website);
            requestBody.put('WebAddr', webAddr);
            string jsonString = JSON.serializePretty(requestBody); 
            system.debug(jsonString);
            insertOnQuickBook(jsonString);
        }
        
    }
    @future(callout =true)
    public static void insertOnQuickBook(String jsonData){
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
            Map<String, Object> serializeResponseBody = new Map<String, Object>();
            serializeResponseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('serializeResponseBody>>'+JSON.serializePretty(serializeResponseBody));
        }
    }
}