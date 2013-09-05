trigger T_AI_Showing on Showing__c (after insert) 
{
	for(Showing__c showing: Trigger.new)
    {
    	C_ShowingEventHandler handler = new C_ShowingEventHandler(showing);
    	
    	//if showing status is equal informing then
    	//get lead list and inform them showing time
    	if(showing.Status__c == C_Constant.INFORMING)
    	{
	    	handler.createShowingEvent();
	    	handler.informShowingTime();
    	}
    	//if showing status is equal to call then
    	//get call list
    	handler.createCallList();
    }
}