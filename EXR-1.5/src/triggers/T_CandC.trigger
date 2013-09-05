trigger T_CandC on C_C__c (after insert) 
{
	for(C_C__c call: Trigger.new)
     {
         C_CandCHandler handler = new C_CandCHandler(call);
         
         if(call.Contact_Name__c != null)
         { 
            //if this call category is not lease and sales 
            //then create a new contact
            if(!handler.isLead())
            {
                handler.createContact();
            }
            else 
            {
            	handler.createLead();
            }
         }
         handler.createTask();
         
         handler.setPriority(); 
         //if this call's type is equal to repair
         //then create a new repair case is there is 
         //not outstanding repair case under this property 
         //or log a activity under its outstand repair case 
         handler.callToRepair(); 
         
         //if this call's Type is equal to bond
         //then log a acitivity under this property 
         //if there is a outstanding bond case for this 
         //property
         handler.callToBond();
         
         handler.callToCase();
     } 
}