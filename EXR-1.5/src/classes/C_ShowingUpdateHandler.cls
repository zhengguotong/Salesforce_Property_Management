public abstract with sharing class C_ShowingUpdateHandler 
{
	protected Showing__c showing;
	protected String propertyAddress;
	protected List<Lead> leads;
	protected List<Event> event;
	
	public C_ShowingUpdateHandler(Showing__c showing)
	{
		this.showing = showing;
		getPropertyAddress();
		setLeads();
		setEvent();
	}
	
	/**
	Get all leads which were informed 
	about this showing time before
	**/
	protected void setLeads()
	{
		leads = [Select Name, Email, MobilePhone 
		         From Lead 
		         Where showing__c = :showing.id
		         ];
	}
	
	/**
	get Event which is related to this showing 
	**/
	protected void setEvent()
	{
		event = [Select StartDateTime, EndDateTime 
		         From Event 
		         Where WhatId = :showing.id];
	}
		
	
	/**
        get property Address
    **/
    protected void getPropertyAddress()
    {
    	Property__c property = [Select p.Id, p.Unit_Number__c,
    	                               p.Building_Name__c,
    	                               p.Street_Number__c,
    	                               p.Suburn__c,
    	                               p.State__c,
    	                               p.Post_Code__c
    	                        From Property__c p 
    	                        Where p.Id = :showing.Property__c
    	                        Limit 1];
    	propertyAddress = C_Utility.propertyAddress(property);
    }
    
    
    /**
     send email and sms to customer, 
     who was infomed about this 
     showing time before, abou the 
     updates of this showing 
    **/
    public void informUpdates()
    {
    	 if (leads.size() > 0 )
    	 {
    	 	 List<Messaging.SingleEmailMessage> massEmails = new List<Messaging.SingleEmailMessage>();
    	 	 
    	 	 //iterates through the leads list which was informed about this 
	         //showing time, if this lead email address is null, then inform 
	         //showing update by email, if this lead mobik phone is not null
	         //also inform them by sending a sms
	    	 for(Lead lead: leads)
	    	 {
	    	 	if(lead.Email != null)
	    	 	{
	    	 		massEmails.add(getEmail(new String[] {lead.Email}));
	    	 	}
	    	 	
	    	 	if(lead.MobilePhone != null)
	    	 	{
	    	 		C_SMS.sendSms(lead.MobilePhone, lead.name, getSmsBody());
	    	 	}
	    	 } 
	    	 
	    	 if(massEmails.size() > 0)
	    	 {
	    	 	   C_Email.sendMassEmail(massEmails);  
	    	 }
    	 }
    	 logActivity();
    	 updateEvent();
    }
    
    /**
         get single showing email 
    **/
    protected  Messaging.SingleEmailMessage getEmail(String[] toAddresses)
    {
    	Messaging.SingleEmailMessage mail = 
                            new Messaging.SingleEmailMessage();
                            
       mail.setToAddresses(toAddresses);
       mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
       mail.setSubject('Re:' + propertyAddress + ' open inspection');
       mail.setHtmlBody(getEmailBody());
       
       return mail;
    }
    
    public void updateProperty(String showingTime)
    {
    	Property__c property = [Select H_Inspection_Time__c 
    							From Property__c 
    							Where Id = :showing.Property__c
    							limit 1];
    	property.H_Inspection_Time__c = showingTime;
    	update property;
    }
    
	protected abstract String getEmailBody();
	protected abstract String getSmsBody();
	protected abstract void updateEvent();
	protected abstract void logActivity();
	protected abstract String getDescription();
}