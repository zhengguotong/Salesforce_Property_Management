trigger T_BU_Lead on Lead (before update) 
{
	for(Lead currentLead: Trigger.new) 
   {
        currentLead.Create_Date__c = datetime.now(); 
        //update currentLead;
        
        //if this lead not informed before
        if(currentLead.Status == C_Constant.OPEN)
        {
        	C_ShowingTimeHandler handler = new C_ShowingTimeHandler(currentLead);
        	handler.informTenant();    
        }  
   }         
}