public class getCustomer {
    
    public static void getDatafromquickbook(list<Quickbook_Event_notification__c> custrec){
        string recId;
        string operation;
        for(Quickbook_Event_notification__c objrec: custrec){
            recId = objrec.Id__c;
            operation=objrec.Operation__c;
            break;
        }
        getData(operation,recId);
    }
    
    @future(callout=true)
    public static void getData(string oper,string quickId){
        Account objAcc;
        if(oper != 'Create'){
        objAcc=[select Id, Quickbook_Customer_Id__c from Account where Quickbook_Customer_Id__c=:quickId];
        }
        String CustomerQuery='select%20*%20from%20Customer%20where%20Id=\''+quickId+'\'';
        String CustomerBaseUrl = 'callout:QuickbookNamedCredential/v3/company/9130355912005176/query?query='+CustomerQuery+'&minorversion=65';
        Http httpCustomer = new Http();
        HttpRequest requestCustomer = new HttpRequest();
        requestCustomer.setMethod('GET');
        requestCustomer.setEndpoint(CustomerBaseUrl);
        requestCustomer.setHeader('Accept', 'application/json');
        //req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        HttpResponse responseCustomer = httpCustomer.send(requestCustomer);
        system.debug('########'+JSON.serializePretty(responseCustomer.getBody()));
        
        Map<String, Object> ResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseCustomer.getBody());
        map<string,object> queryresponseMap = (Map<String, Object>) ResponseMap.get('QueryResponse');
        List<Object> customerList = (List<Object>) queryresponseMap.get('Customer');
        
        for (Object customerObj : customerList) {
            Map<String, Object> customerMap = (Map<String, Object>) customerObj;
            String customerId =null;
            String fullyQualifiedName = null;
            if(customerMap!=null){
             customerId = (String) customerMap.get('Id');
             fullyQualifiedName = (String) customerMap.get('FullyQualifiedName');
            }
            
            Map<String, Object> billingAddrMap = (Map<String, Object>) customerMap.get('BillAddr');
            String billingStreet = null;
            String billingCity = null;
            String billingState = null;
            String billingPostalCode = null;
            if(billingAddrMap!= null){
                billingStreet = (String) billingAddrMap.get('Line1');
                billingCity = (String) billingAddrMap.get('City');
                billingState = (String) billingAddrMap.get('CountrySubDivisionCode');
                billingPostalCode = (String) billingAddrMap.get('PostalCode');
            }
            
            Map<String, Object> shippingAddrMap = (Map<String, Object>) customerMap.get('ShipAddr');
            String shippingStreet = null;
            String shippingCity = null;
            String shippingState = null;
            String shippingPostalCode = null;
            if(shippingAddrMap!=null){
                shippingStreet = (String) shippingAddrMap.get('Line1');
                shippingCity = (String) shippingAddrMap.get('City');
                shippingState = (String) shippingAddrMap.get('CountrySubDivisionCode');
                shippingPostalCode = (String) shippingAddrMap.get('PostalCode');
            }
            Map<String, Object> primaryPhoneMap = (Map<String, Object>) customerMap.get('PrimaryPhone');
            String phone = null;
            if(primaryPhoneMap!=null){
                phone = (String) primaryPhoneMap.get('FreeFormNumber');
            }
            Map<String, Object> mobilePhoneMap = (Map<String, Object>) customerMap.get('Mobile');
            String mobilePhone =null;
            if(mobilePhoneMap!=null){            
                 mobilePhone = (String) mobilePhoneMap.get('FreeFormNumber');
            }
            Map<String, Object> faxMap = (Map<String, Object>) customerMap.get('Fax');
            String fax = null;
            if(faxMap!=null){
             fax = (String) faxMap.get('FreeFormNumber');
            }
            //do something with the customer data here
            // for example, create an Account record and populate its fields with the customer data
            Account account = new Account();
            if(objAcc.Id != null){
            account.Id=objAcc.Id;
            }
            account.Name = fullyQualifiedName;
            account.BillingStreet = billingStreet;
            account.BillingCity = billingCity;
            account.BillingState = billingState;
            account.BillingPostalCode = billingPostalCode;
            account.ShippingStreet = shippingStreet;
            account.ShippingCity = shippingCity;
            account.ShippingState = shippingState;
            account.ShippingPostalCode = shippingPostalCode;
            account.Phone = phone;
            account.Fax = fax;
            
            // insert the account record
            upsert account;
        }
    }
}