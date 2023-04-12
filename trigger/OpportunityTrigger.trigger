trigger OpportunityTrigger on Opportunity (after insert,after update) {
    
    //createCustomerWebservice.createCustomer(trigger.new);
    QuickbookInvoiceIntegration.createInvoiceBody(trigger.new);
}