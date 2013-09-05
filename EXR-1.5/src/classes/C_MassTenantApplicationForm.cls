/**
	Send tenant Application Form to customer 
	who has shown up and has email address
**/
public with sharing class C_MassTenantApplicationForm
{ 
	public static String TEMPLATE_NAME = 'Tenant Application Form After inspection' ;
	private List<Lead> leads;
	private Showing__c showing;
	
	public C_MassTenantApplicationForm(Showing__c showing)
	{
		this.showing = showing;
		setLead();
	}
	
	public C_MassTenantApplicationForm()
	{
	}
	
	/**
	Select lead which is related to this showing,
	Email address is null and status is equal to 
	'Qualified'which means, this lead has shown up 
	on the this inspection
	**/
	private void setLead()
	{
		leads = [Select Name, Email, MobilePhone, Property__c, Status
		         From Lead 
		         Where showing__c = :showing.id
		         ];
	}
	
	/**
	if lead status is contacted, then change its status 
	to open, therefore, we can inform them showing time 
	next timem, if status is equal to qualified, then send 
	them tenant application form
	**/
	public void complete()
	{ 
		for(Lead lead: Leads)
		{
			if(showing.Type__c == C_Constant.SHOWING_RENTALS && lead.Status == C_Constant.QUALIFIED && lead.Email != null)
			{
				C_Email.sendTempleteEmail(lead.Id, getTemplateId(), lead.Property__c);
				C_Utility.logActivity(TEMPLATE_NAME, emailDescription(lead), showing.id);
			}	
			else if(lead.Status == C_Constant.CONTACTED)
			{
				lead.Status = C_Constant.OPEN;
				update lead;
			}	
			else 
			{
				system.debug('C_MassTenantApplicationForm:Doing Noting');
			}	
		}
	}

	private string getTemplateId()
	{
		 EmailTemplate emailTemplate = [SELECT id From EmailTemplate 
		                                Where name = :TEMPLATE_NAME
		                                Limit 1];
		 return emailTemplate.id;                              
	}	
	
	public List<Lead> getLeads()
	{
		return leads;
	}
	
	/**
	Log Tenant Application Form on the lead 
	activity history
	**/
	private String emailDescription(Lead lead)
	{
		return 'Send Excelsior Realty Tenant Application Form\n'
		       +'To: ' + lead.Email
		       +'\nTime: ' + DateTime.now().format('E dd/MM/yyyy hh:mm a');
	}
	
	@isTest 
	static void emailDescriptionTest()
	{
		//Create a lead object 
		Lead testLead = new Lead(Email = 'dev@exr.com.au');
		
		C_MassTenantApplicationForm  handler = new C_MassTenantApplicationForm();
		system.assertEquals(true,handler.emailDescription(testLead).contains('dev@exr.com.au'));
	}
	
	@isTest 
	static void getTemplateIdTest()
	{
		C_MassTenantApplicationForm  handler = new C_MassTenantApplicationForm();
		
		EmailTemplate testTemplate = [Select Name 
									  From EmailTemplate
									  Where Id = :handler.getTemplateId()];
									  
		system.assertEquals('Tenant Application Form After inspection', testTemplate.Name);						
	}
	
	@isTest 
	static void massTenantApplicationTest()
	{
		//create new property object 
   		 Property__c testProperty = new Property__c(Location__c = 'Western Suburb',
   		 										    BedRoom__c = '5',
   		 										    Bathroom__c= '5',
   		 										    Parking__c = '3',
                                                    Weekly_Rentals__c = 900,
                                                    Furniture__c = 'Unfurinished',
                                                    Sale_Price__c = 2000000.00,
                                                    Unit_Number__c = '98',
                                                    Building_Name__c = 'Testing Building Name',
                                                    Street_Number__c = '98',
                                                    Suburn__c = 'Testing Suburn',
                                                    State__c = 'Test State',
                                                    Post_Code__c = '5168');
        insert testProperty;
        
        //create new showing object 
        Showing__c testShowing = new Showing__c();
        testShowing.Start_Date_Time__c = DateTime.now().addDays(1);
        testShowing.End_Date_Time__c = DateTime.now().addDays(2);
        testShowing.Name = 'Testing';
        testShowing.Property__c = testProperty.id;
        testShowing.Status__c ='Informing';
        testShowing.Type__c = 'Rentals';
        insert testShowing;
        
        //create related leads 
        Lead testLead = new Lead(LastName = 'Testing',
        						Company = 'Testing', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id,
        						Status = 'Qualified'
        						);
        insert testLead;
        
         Lead testLead1 = new Lead(LastName = 'Testing1',
        						Company = 'Testing1', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id,
        						Status = 'Contacted'
        						);
        insert testLead1;
        
         Lead testLead2 = new Lead(LastName = 'Testing2',
        						Company = 'Testing2', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au',
        						Showing__c = testShowing.Id,
        						status = 'Open'
        						);
        insert testLead2;
        
        C_MassTenantApplicationForm handler = new C_MassTenantApplicationForm(testShowing);
        
        /** test setLead() **/ 
        handler.setLead(); 
        system.assertEquals(3, handler.getLeads().Size());
        
        /** test complete() **/
        handler.complete();
	}
}