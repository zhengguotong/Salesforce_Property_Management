/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class C_Email_Processing implements Messaging.InboundEmailHandler { 
   
    public final static String TENENT_APPLICATION_FORM = 'Tenant Application Form';
    public final static String VACATE_FORM = 'Send Vacate Form To Tenant';
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                  Messaging.InboundEnvelope env)
    {

        // Create an inboundEmailResult object for returning 
        // the result of the Force.com Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
       
        try { 
                //if the email is from domain then create or update new lead on saleforce
                if (email.fromAddress.contains('enquiries@domain.com.au'))
                {
                    //check if the email address is existing in the lead 
                    Integer leadNumber = [SELECT count() FROM Lead WHERE Email = :email.replyTo];
                
                    //if the lead do not exist on the system 
                    //then create new lead on the saleforce
                    if(leadNumber == 0)
                    {
                       Lead lead = new Lead();
                       createLead(email,lead);
                       insert lead;
                    }
                    else 
                    {
                        Lead lead =[Select Property_Address__c, Type__c,LastName, LeadSource,
                                           Description, Email,Company,Status, Create_Date__c 
                                           From Lead 
                                           Where Email = :email.replyTo
                                           Limit 1];
                        createLead(email, lead);
                        update lead;
                    }
                } 
                 
               else if(email.subject.toLowerCase().equals('tenant application') ) 
                {
                     EmailTemplate template = [SELECT id From EmailTemplate Where name = :TENENT_APPLICATION_FORM];
                     C_Email.sendTempleteEmail(getContact(email), template.id);
                } 
                else if(email.subject.equals('Notice to Vacate')){
                     EmailTemplate template = [SELECT id From EmailTemplate Where name = :VACATE_FORM];
                     C_Email.sendTempleteEmail(getContact(email), template.id);
                }/*else if(email.subject.toLowerCase().equals('repairs request') ){
                	//emailToCase(email);
                }*/
                /*testing
                else 
                {
                	Lead lead = new Lead();
                	lead.LastName = email.fromName;
                	lead.Company = 'email address';
                	lead.Description = email.plainTextBody;
                	insert lead;
                }*/
            }
            catch(Exception e)
            {
                System.debug(e);
            }
        // Set the result to true, no need to send an email back to the user
        // with an error message
      result.success = true;
        
      // Return the result for the Force.com Email Service
      return result;
  }
    
    /**
        create new lead 
    **/
    private void createLead(Messaging.inboundEmail email, Lead newlead)
    {
            
        string subject = email.subject;
            
        if (subject.contains('domain.com.au'))
        {   
            String propertAddress = subject.substring(15);
            //handle rental email 
            if(!propertAddress.contains('Contact: Excelsior Team'))
            {
                 newLead.Property_Address__c = propertAddress;
                 newLead.LastName = email.fromName;
                 newLead.Type__c = C_Constant.RENTING;
            }
            else if (propertAddress.contains('User inquiry from domain.com.au'))
            {
                newLead.Description = email.htmlBody;
            }
            else
            {
               List<String>  subjects= propertAddress.split('\\(');
               
                newLead.Property_Address__c = subjects.get(0);
                newLead.LastName = subject;
                newLead.Type__c = C_Constant.BUYING;
            }
           
        }
        else 
        {
            List<String> subjects = subject.split('\\ - ');
            if(subjects.size() == 2)
            {
                newLead.Property_Address__c = subjects.get(0);
                newLead.LastName = subjects.get(1);
                newLead.Type__c = C_Constant.RENTING;
            }
        }
            
        newLead.Email= email.replyTo;
        newlead.Company = 'Residential'; 
        newLead.Create_Date__c = datetime.now(); 
        newLead.LeadSource = 'Email';
        
    }
    
    private String getContact(Messaging.inboundEmail email)
    {   
        String emailAddress = email.replyTo; 
        
        //check if this email address already exist on the saleforce 
        List<Contact> contacts = [Select id,Email From Contact Where Email = :emailAddress limit 1];
        
        //if there is a contact on the salefoce 
        //then retunr the first one 
        if (contacts.size() == 1)
        {
           return contacts.get(0).id; 
        }
        //if there is not an contact on the saleforce 
        //then create new contact and add this contact
        //to saleforce then return this contact 
        else 
        {
            Contact newContact = new Contact();
            newContact.LastName = email.fromName;
            newContact.Email = emailAddress;
            insert newContact;
            
            return newContact.id;
        }
    }
    
    /*private void emailToCase(Messaging.inboundEmail email){
    	List<Tenant__c> tenant = [Select id, Email__c 
    	                    From Tenant__c
    	                    Where Email__c = :email.replyTo 
    	                   ];
    	                   
        if(tenant.size() > 0)
        {
        	//Case repair = new Case();
        	//repair.Type = 'Repair';
        	//repair.Tenant__c = tenant[0].Id;
        	//repair.Description = email.plainTextBody;
        	
        	//insert repair;
        }
    }*/
    
    static testMethod void handleInboundEmailTest() 
    {
	
	  // Create a new email and envelope object
	   Messaging.InboundEmail email = new Messaging.InboundEmail();
	   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	
	   // Create the plainTextBody and fromAddres for the test
		email.plainTextBody = 'Here is my plainText body of the email';
		email.fromAddress ='dev@exr.com.au';
	
	    C_Email_Processing testEmail = new C_Email_Processing();
	    testEmail.handleInboundEmail(email, env);
	} 
	
	static testMethod void createLead()
	{
			
	// Create a new email and envelope object
	   Messaging.InboundEmail email = new Messaging.InboundEmail();
	   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	
	 // Create the plainTextBody and fromAddres for the test
		email.htmlBody = 'Here is my plainText body of the email';
		email.fromAddress ='dev@exr.com.au';
		email.subject = 'domain.com.au Testing Address';
		email.replyTo = 'dev@exr.com.au';
		
		//create a Lead object 
		Lead newLead = new Lead();
		
	
		
		 C_Email_Processing testEmail = new C_Email_Processing();
		 testEmail.createLead(email, newlead);
	}
	
	static testMethod void getContactTest()
	{
		// Create a new email and envelope object
	   Messaging.InboundEmail email = new Messaging.InboundEmail();
	   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	
	 // Create the plainTextBody and fromAddres for the test
		email.htmlBody = 'Here is my plainText body of the email';
		email.fromAddress ='dev@exr.com.au';
		email.subject = 'domain.com.au Testing Address';
		email.replyTo = 'dev@exr.com.au';
		email.fromName = 'Testing';
		
		C_Email_Processing testEmail = new C_Email_Processing();
		testEmail.getContact(email);	
	}
}