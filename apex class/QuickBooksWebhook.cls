@RestResource(urlMapping='/QuickBooksWebhook/*')
global class QuickBooksWebhook  {
    
   @HttpPost
    global static void CreateRocord() {

        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        

// Parse the JSON body
Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

// Extract the name and operation values
List<Object> eventNotifications = (List<Object>) requestBodyMap.get('eventNotifications');
Map<String, Object> eventNotification = (Map<String, Object>) eventNotifications[0];
Map<String, Object> dataChangeEvent = (Map<String, Object>) eventNotification.get('dataChangeEvent');
List<Object> entities = (List<Object>) dataChangeEvent.get('entities');
Map<String, Object> entity = (Map<String, Object>) entities[0];
String name = (String) entity.get('name');
String id = (String) entity.get('id');
String operation = (String) entity.get('operation');

        Quickbook_Event_notification__c obj = new Quickbook_Event_notification__c();
        obj.Id__c=id;
        obj.Name__c=name;
        obj.Operation__c=operation;
		database.insert(obj);
    }


}