trigger T_AI_Message on Message__c (after insert, before update) 
{
	for(Message__c message: Trigger.new)
	{
		C_MessageHandler handler = new C_MessageHandler(message);
		handler.processMessage();
	}
}