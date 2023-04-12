trigger QuickbookEventNotificationTrigger on Quickbook_Event_notification__c (after insert) {
    getCustomer.getDatafromquickbook(trigger.new);

}