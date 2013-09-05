trigger T_BU_Showing on Showing__c (before update)
{
	for(Showing__c showing: Trigger.new)
	{
		if(showing.Status__c == C_Constant.CANCELLED)
		{
			C_CancelShowingHandler handler = new C_CancelShowingHandler(showing);
			handler.informUpdates();  
			handler.updateProperty(null);
		}
		else if (showing.Status__c == C_Constant.CHANGE_TIME)
		{
			C_ChangeShowingHandler handler = new C_ChangeShowingHandler(showing);
			handler.informUpdates();	
			handler.updateProperty(showing.Start_Date_Time__c.format('E dd/MM/yyyy hh:mm a'));
		}
		else if (showing.Status__c == C_Constant.COMPLETED)
		{
			C_MassTenantApplicationForm applicationForm = new C_MassTenantApplicationForm(showing);
			applicationForm.complete();  
			
			Property__c property = [Select H_Inspection_Time__c 
    							From Property__c 
    							Where Id = :showing.Property__c
    							limit 1];
	    	property.H_Inspection_Time__c = null;
	    	update property;
		}
	}
}