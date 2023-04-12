trigger AccountTrigger on Account (after insert) {
	createCustomerWebservice.createCustomer(trigger.new);
}