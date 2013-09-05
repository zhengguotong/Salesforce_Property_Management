public class VF_PropertiesListingController
{
	public final static String RENT =  'For Rent';
	public final static String SALE = 'For Sale';
	public final static String SUBJECT = 'Customer wants to book an inspection';
	
	@remoteAction 
	public static List<Property__c> getPropertyList()
	{
		return [Select P.Picture_Id__c,p.Name, p.Weekly_Rentals__c, p.Suburn__c, p.Street_Number__c, 
		       p.Unit_Number__c,p.Property_Type__c,p.Furniture__c,p.Avalible_Time__c,p.Sale_Price__c,
		       p.State__c, p.Parking__c, p.Id, p.Bedroom__c, p.Bathroom__c,p.H_Inspection_Time__c,
		       p.Property_Status__c, p.Land_Area__c, p.Post_Code__c
		       From Property__c p
		       Where p.Property_Status__c != Null
		       limit 20];
	}
	
	@remoteAction
	public static void bookingInspection(String name, String email, String phone,
										String prefrenceTime, String message, String id)
	{
		createTask( message, 
				    createLead(name,email,phone,prefrenceTime,message,id)
				  );
	}
	
	public static List<Property__c> getLeaseDetails(String Id)
	{  
		return [Select P.Picture_Id__c,p.Name, p.Weekly_Rentals__c, p.Suburn__c, p.Street_Number__c, 
		       p.State__c, p.Parking__c, p.Id, p.Bedroom__c, p.Bathroom__c,   p.Property_Status__c,
		       p.Location__c
		       From Property__c p
		       Where p.Id = :Id ]; 
	}
	
	public static void createTask(String description,String id)
     {
     	Task task = new Task();
     	task.OwnerId = Userinfo.getUserId();
        task.Subject = SUBJECT;
        task.Description = description;  
        task.WhoId = id;
        task.Status = C_Constant.NOT_STARTED;
        
        insert task;
     }
	
	
	public static String createLead(String name, String email, String phone,
										String preferenceTime, String message, String id)
	{
		Lead lead = new Lead();
		
		lead.Company = name;
		lead.LastName = name;
		lead.Email = email;
		lead.MobilePhone = phone;
		lead.Description = message;
		lead.Preference_Inspection_Time__c = preferenceTime;
		
		if(id != null )
		{
			List<Property__c> properties = getLeaseDetails(id);
			
			if (properties != null && properties.size() > 0)
			{
				lead.Type__c = getLeadType(C_Utility.NVL(properties[0].Property_Status__c));
				lead.Bathroom__c = C_Utility.NVL(properties[0].Bathroom__c);
				lead.Bedroom__c = C_Utility.NVL(properties[0].Bedroom__c);
				lead.Parking__c = C_Utility.NVL(properties[0].Parking__c);
				lead.Location__c = C_Utility.NVL(properties[0].Location__c);
				lead.Property__c = id;
			}
		}
		
		insert lead;
		
		return lead.Id;
	}
	
	public static String getLeadType(String status)
	{
		if(status.equals(RENT))
			return C_Constant.RENTING;
		else
			return C_Constant.BUYING;
	}
	
	@isTest 
    public static void getPropertiesTest()
    {
    	Account owner = new Account();
		owner.Name = 'Test Owner';
		insert owner; 
		
		Property__c property1 = new Property__c();
		property1.Name = 'Testing Address1';
		property1.Property_Owner__c = owner.id;
		property1.Property_Status__c = 'For Rent';
		insert property1;
		
		Property__c property2 = new Property__c();
		property2.Name = 'Testing Address2';
		property2.Property_Owner__c = owner.id;
		property2.Property_Status__c = 'For Sale';
		insert property2;
		
		List<Property__c> properties = getLeaseDetails(property1.id);
		
		System.assertEquals(1, properties.size());
		System.assertEquals('Testing Address1', properties[0].Name);
		
		properties = getPropertyList();
		System.assertEquals(2, properties.size()); 
		System.assertEquals('Testing Address1', properties[0].Name);
		System.assertEquals('Testing Address2', properties[1].Name);
    }
	
	@isTest 
	public static void bookingInpectionTest()
	{
		Account owner = new Account();
		owner.Name = 'Test Owner';
		insert owner; 
		
		Property__c property = new Property__c();
		property.Name = 'Testing Address';
		property.Property_Owner__c = owner.id;
		insert property;
		
		createLead('Testing', 'dev@exr.com.au', '0405791234',
					'Monday', 'Testing', null);
					
		String testLead= createLead('Testing', 'dev@exr.com.au', '0405791234',
					'Monday', 'Testing', property.id);
	    
	    createTask('Testing', testLead);
	    
	    system.assertEquals(1, [select count() from Task]);
	    
	    //booking inspection Testing 
	   bookingInspection('Testing', 'dev@exr.com.au', '0412345678',
						 'Monday', 'Testing', property.id);
	}
	
	@isTest 
	public static void getLeadTypeTest()
	{
		System.assertEquals('Renting', getLeadType('For Rent'));
		System.assertEquals('Buying', getLeadType('For Sale'));
	}
	
	@isTest 
	public static void propertyTriggerTest()
	{
		Account owner = new Account();
		owner.Name = 'Test Owner';
		insert owner; 
		
		Property__c property = new Property__c();
		property.Name = 'Testing Address';
		property.Property_Owner__c = owner.id;
		insert property;
		
		Blob testBlob = Blob.valueof('Test paf');
		
		Attachment attachment = new Attachment();
    	attachment.Name = 'Test.pdf';
    	attachment.Body = testBlob;
    	attachment.ParentId = property.Id;
    	insert attachment;
    	
    	property.Property_Status__c = 'For Rent';
    	update property;
	}
}