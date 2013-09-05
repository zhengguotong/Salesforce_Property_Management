public class VF_MobileHomeController 
{
	public final static String REPAIR_SUBJECT = 'Repair Case submittion Details';
	public final static String ACKNOWLEDGEMENT_SUBJECT ='Acknowledgement of tenant application';
	public final static String VACATE_FORM = 'Send Vacate Form To Tenant';
	public final static String BOOKING_SUBJECT = 'Customer wants to book an inspection';
	public final static String RENT =  'For Rent';
	public final static String SALE = 'For Sale';
	
	@RemoteAction 
	public static void contactUs(String replyTo, String subject, String message)
	{
		sendSingleEmail(replyTo, subject, message);
	} 
	
	/**send sigle email to rentals and dev  **/
	public static void sendSingleEmail(String replyTo, String subject, String message)
	{
		Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(C_Constant.RENTALS_EMAIL);
        mail.setReplyTo(replyTo);
        mail.setSubject(subject);
        mail.setPlainTextBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	}
	
	@remoteAction 
	public static String createRepairCase( String propertyAddress, String email,
										    String mobile, String description)
	{
		Case repair = new Case();
		repair.Type = C_Constant.REPAIR;
		repair.Subject = propertyAddress + ' repair requests';
		repair.H_Tenant_Email__c = email;
		repair.H_Tenant_Mobile__c = mobile;
		repair.Description = description;
		repair.Repair_Status__c = C_Constant.NEWCASE;
		insert repair;
		
		C_Utility.logActivity(REPAIR_SUBJECT, 
								caseDetail(propertyAddress,mobile,email,description), 
								repair.id);
		return repair.id;
	}

	public static String caseDetail(String propertyAddress,String bestContactNumber,
	                               String email, String description)
	{
		return 'Time Submit:'  + DateTime.now().format('E dd/MM/yyyy hh:mm a') 
		       +'\nProperty Address: '+ propertyAddress
		       +'\nBest Contact Number: ' + bestContactNumber
		       +'\nEmail:' + email
		       +'\nDescription:' + description;
	}
	
	@remoteAction 
	public static String addAttachment(String fileName, String body,
						String attachmentId, String caseId)
	{
		
		//If recordId is blank this is the first part of a multi piece upload
		if(attachmentId == '' ||  attachmentId == null)
		{
			 Attachment attachment = new Attachment();
			
	    	 attachment.Name = fileName;
	    	 attachment.Body = EncodingUtil.base64Decode(body);
	    	 attachment.ParentId = caseId;
	    	 insert attachment;
	         
	         return attachment.id;
		}
		else
		{
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId])
            {
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + body));
            }
            return attachmentId;
		}
	}
	
	@remoteAction 
	public static String createApplication(String property, String leaseTerm,
	                String commencementDate, String adults, string children)
	{
		Application__c application = new Application__c();
		application.Property_Address__c = property;
		application.Lease_Term__c = leaseTerm;
		application.Lease_commencement_Date__c = Date.parse(commencementDate);
		application.Number_of_Adults__c = Decimal.valueOf(adults);
		application.Number_of_Children__c = Decimal.valueOf(children);
		insert application;
		
		return application.Id;
	}
	
	public static Application__c getApplication(String appId)
	{
		return [
			    Select a.Work_No__c, a.Utility_Connection__c, a.Title__c,a.Sub_Total__c, 
			    a.State_of_Issue__c, a.Rental_Term__c, a.Rental_Bond__c, a.Relationship__c, 
			    a.Property_Rental__c, a.Property_Address__c, a.Perious_Stay_Length__c, 
			    a.Perious_Rentals__c, a.Perious_Reason_for_leaving__c, a.Perious_Bond_Why__c,
			    a.Perious_Bond_Full_returned__c, a.Perious_Agent__c, a.Perious_Agent_Phone__c,
			    a.Perious_Address__c,a.Occupation__c, a.Number_of_Children__c, 
			    a.Number_of_Adults__c, a.Net_Income__c, a.Mobile_Phone__c, 
			    a.Lease_commencement_Date__c, a.Lease_Term__c, a.Last_Name__c, a.Income_Term__c, 
			    a.Id, a.Home_Phone__c, a.First_Payment__c, a.First_Name__c, a.Employment_Occupation__c, 
			    a.Employment_Length__c, a.Employment_Address__c, a.Employer_Phone__c, a.Employer_Name__c, 
			    a.Emergency_Surname__c, a.Emergency_Phone_No__c, a.Emergency_First_Name__c,
			    a.Emergecy_Suburb__c, a.Emergecy_Postcode__c, a.Emergecy_Address__c, a.Email__c, 
			    a.Drivers_Licence_Number__c, a.Date_of_Birth__c, a.Current_Suburb__c, a.Current_Rental__c, 
			    a.Current_Reason_for_leaving__c, a.Current_Postcode__c, a.Current_Bond_full_returned__c, 
			    a.Current_Bond_Reason__c, a.Current_Agent_Phone__c, a.Current_Address_lived_Length__c,
			    a.Current_Address__c, a.Curent_Agent__c, a.Alternate_ID__c, a.Pets__c,a.Smoke__c,
			    a.Contact_Details5__c, a.Reference2_Phone__c
			    From Application__c a
		        Where a.Id = :appId
		        ];
	}
	
	@remoteAction 
	public static void updateApplication(String appId,String property, String leaseTerm,
	                String commencementDate, String adults, string children)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Property_Address__c = property;
			application.Lease_Term__c = leaseTerm;
			application.Lease_commencement_Date__c = Date.parse(commencementDate);
			application.Number_of_Adults__c = Decimal.valueOf(adults);
			application.Number_of_Children__c = Decimal.valueOf(children);
			update application;
    	}
    }
    
    @remoteAction 
    public static String updatePersonalDetails(String[] personalDetails,string appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Title__c = personalDetails[0];
    		application.First_Name__c = personalDetails[1];
    		application.Last_Name__c = personalDetails[2];
    		application.Date_of_Birth__c = date.parse(personalDetails[3]);
    		application.Drivers_Licence_Number__c = personalDetails[4];
    		application.State_of_Issue__c = personalDetails[5];
    		application.Alternate_ID__c = personalDetails[6];
    		application.Home_Phone__c = personalDetails[7];
    		application.Mobile_Phone__c = personalDetails[8];
    		application.Email__c = personalDetails[9];
    		application.Occupation__c = personalDetails[10];
    		application.Work_No__c = personalDetails[11];
    		application.Current_Address__c = personalDetails[12];
    		application.Current_Suburb__c = personalDetails[13];
    		application.Current_Postcode__c = personalDetails[14];
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
    public static String updateEmergencyContact(String[] contactDetails, String appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Emergency_First_Name__c = contactDetails[0];
    		application.Emergency_Surname__c = contactDetails[1];
    		application.Relationship__c = contactDetails[2];
    		application.Emergency_Phone_No__c = contactDetails[3];
    		application.Emergecy_Address__c = contactDetails[4];
    		application.Emergecy_Suburb__c = contactDetails[5];
    		application.Emergecy_Postcode__c = contactDetails[6];
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
    public static String updatePaymentDetails(String[] paymentDetails, String appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Property_Rental__c = parse(paymentDetails[0]);
    		application.Rental_Term__c = paymentDetails[1];
    		application.First_Payment__c = parse(paymentDetails[2]);
    		application.Rental_Bond__c = parse(paymentDetails[3]);
    		application.Sub_Total__c = parse(paymentDetails[4]);
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
    public static String  updateUtilityConnection(Boolean isChecked, String appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		
		    application.Utility_Connection__c = isChecked;
		    update application;
		    
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
    public static String updateApplicationHistory(String[] appDetails, Boolean isCBFReturned,  Boolean isPBFReturned, string appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Current_Address_lived_Length__c = appDetails[0];
    		application.Curent_Agent__c = appDetails[1];
    		application.Current_Agent_Phone__c = appDetails[2];
    		application.Current_Rental__c =parse(appDetails[3]);
    		application.Current_Reason_for_leaving__c = appDetails[4];
    		application.Current_Bond_full_returned__c= isCBFReturned;
    		application.Current_Bond_Reason__c = appDetails[5];
    		application.Perious_Address__c = appDetails[6];
    		application.Perious_Stay_Length__c = appDetails[7];
    		application.Perious_Agent__c = appDetails[8];
    		application.Perious_Agent_Phone__c = appDetails[9];
    		application.Perious_Rentals__c = parse(appDetails[10]);
    		application.Perious_Reason_for_leaving__c = appDetails[11];
    		application.Perious_Bond_Full_returned__c =  isPBFReturned;
    		application.Perious_Bond_Why__c = appDetails[12];
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
    public static String updateEmploymentDetails(String[] empDetails, string appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Employment_Occupation__c = empDetails[0];
    		application.Employer_Name__c = empDetails[1];
    		application.Employment_Address__c = empDetails[2];
    		application.Employer_Phone__c =empDetails[3];
    		application.Employment_Length__c = empDetails[4];
    		application.Net_Income__c = parse(empDetails[5]);
    		application.Income_Term__c = empDetails[6];
    		
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
     @remoteAction 
    public static String updateOtherInfor(String carReg, Boolean pets, 
                                          String petType,Boolean smoking,string appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Car_Registration__c = carReg;
    		application.Pets__c = pets;
    		application.Pet_Types__c = petType;
    		application.Smoke__c = smoking;
    		
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
    public static String updateOtherOccupier(String[] occupiers,string appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Occupier_Name1__c = occupiers[0];
    		application.Contact_Details1__c = occupiers[1];
    		application.Occupier_Name2__c = occupiers[2];
    		application.Contact_Details2__c = occupiers[3];
    		application.Occupier_Name3__c = occupiers[4];
    		application.Contact_Details3__c = occupiers[5];
    		application.Occupier_Name4__c = occupiers[6];
    		application.Contact_Details4__c = occupiers[7];
    		application.Occupier_Name5__c = occupiers[8];
    		application.Contact_Details5__c = occupiers[9];
    		
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
    public static String updateReferees(String[] referees,string appId)
    {
    	Application__c application = getApplication(appId);
    	
    	if(application != null)
    	{
    		application.Reference_Name1__c = referees[0];
    		application.Reference1_Occupation__c = referees[1];
    		application.Reference1_Relationship__c = referees[2];
    		application.Reference_Phone__c = referees[3];
    		application.Reference2_Name__c = referees[4];
    		application.Reference2_Occupation__c = referees[5];
    		application.Reference2_Relationship__c = referees[6];
    		application.Reference2_Phone__c = referees[7];
    		
			update application;
			
			appId = application.Id;
    	}
    	
    	return appId;
    }
    
    @remoteAction 
	public static String addDocument(String fileName, String body, 
						String attachmentId, String appId)
	{
		if(getApplication(appId) != null)
		{
			//If recordId is blank this is the first part of a multi piece upload
			if(attachmentId == '' ||  attachmentId == null)
			{
				 Attachment attachment = new Attachment();
				
		    	 attachment.Name = fileName;
		    	 attachment.Body = EncodingUtil.base64Decode(body);
		    	 attachment.ParentId = appId;
		    	 insert attachment;
		         
		         return attachment.id;
			}
			else
			{
	
	            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId])
	            {
	                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
	                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + body));
	            }
	            return attachmentId;
			}
		}	
		return null;
	}
    
    @remoteAction 
    public static void sendAcknowledgementEmail(String appId)
    {   
    	Application__c application = getApplication(appId);
    	              
    	if(application != null && application.Email__c != null)
    	{
    		C_Email.sendSignleEMail(new String[]{application.Email__c},
    		ACKNOWLEDGEMENT_SUBJECT, ackowledgementBody(appId));
    	}
    }
    
    public static Decimal parse(String value)
    {
	   try 
	   {
	   		return Decimal.valueOf(value);
	   }
	   catch (system.Typeexception e)
	   {
	   		return null;
	   }
    }
    
    public static String ackowledgementBody(String appId)
    {
    	return '<p>Dear customer,</p>'
    	       +'<p><h5>Your Reference Number:' + appId + '</h5></p>'
    	       +'<p>Thank for you to apply property from us. '
    	       +'You application has been submit to our '
    	       +'property management for action today. </p>'
    	       +'If you have any question regarding your application, '
    	       +'please write to us to rentals@exr.com.au with your reference '
    	       +'number and our property management team would look into the '
    	       +'details and should reply to you within 48 hours.'
    	       +'</br><p>Kind Regards,</br>Excelsior Realty Pty. Ltd.</p>'
               +'</br></br> <p><font color="red"> T</font>   + 61 2 9281 6777    <font color="red">F</font>   '
               + '+61 2 9281 2283   <font color="red">E </font>  rentals@exr.com.au</p>';   
    	       
    }
    
    @remoteAction 
    public static void noticeToVacate(String address, string name, string phone,
    								 String email,String vacatingDate, String detail)
    {
    	String description = 'Property Address: ' + address 
    						  +'\nTenant Name: ' + name 
    						  +'\nBest Contact Number: ' + phone 
    						  +'\nEmail: ' + email
    						  +'\nIntend Vacating Date: ' + vacatingDate
    						  +'\nDetails: ' + detail;
    	String subject = address + ' notice to vacate';
    						  
    	C_Utility.createTask(subject, description,
    						 createVacatingCase(subject, description),
    						 getOwnerId());
    						 
		 EmailTemplate template = [SELECT id From EmailTemplate Where name = :VACATE_FORM];
         C_Email.sendTempleteEmail(getContact(email, name, phone), template.id);
    }
    
    public static String createVacatingCase(String subject, String description)
    {
    	Case vacating = new Case();
    	vacating.Subject = subject;
    	vacating.Description = description;
		vacating.Type = C_Constant.VACATING;
		
		insert vacating;
		
		return vacating.Id;
    }
    
    public static String getOwnerId()
    {
    	//get acccount user infomation 
    	List<User> users = [Select Id from User 
    						Where UserName = 'accounts@exr.com.au'
    				        limit 1];
    	//if user fond then return this user id 
    	//else return current user id
		if(users.size() > 0)
		{
			return users[0].Id;
		}
		else 
		{
			return UserInfo.getUserId();
		}
		
    }
    
    public static String getContact(String email, String name, String phone)
    {   
        
        //check if this email address already exist on the saleforce 
        List<Contact> contacts = [Select id,Email From Contact Where Email = :email limit 1];
        
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
            newContact.LastName = name;
            newContact.Email = email;
            newContact.MobilePhone = phone;
            newContact.Type__c = C_Constant.TENANT;
            insert newContact;
            
            return newContact.id;
        }
    }
    
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
        task.Subject = BOOKING_SUBJECT;
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
		
		if(id != null)
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
	
	@isTest(seeAllData=true) 
	public static void sendSingleEmailTest()
	{
		sendSingleEmail('dev@exr.com.com', 'Testing', 'Testing');
		contactUs('dev@exr.com.com', 'Testing', 'Testing');
	}
	
	@isTest 
	public static void createRepairCaseTest()
	{
		String caseId = createRepairCase('Test address', 'dev@exr.com.au', '0412345678','Testing');
		
		system.assertNotEquals(null, caseId);
		system.assertEquals(1, [Select count() from Case]);
	}
	
	@isTest 
	public static void addAttachmentTest()
	{
		Case testCase = new Case(Subject = 'Testing');
		insert testCase;
		
		String testAttachmentId = addAttachment('test.pdf', 'Testing', '', testCase.Id);
		
		system.assertNotEquals(null, testAttachmentId);
		system.assertEquals(1, [Select count() from Attachment Where ParentId = :testCase.Id]);
		
		addAttachment('test.pdf', 'Testing', testAttachmentId, testCase.Id);
		system.assertNotEquals(null, testAttachmentId);
		system.assertEquals(1, [Select count() from Attachment Where ParentId = :testCase.Id]);
	}
	
	@isTest
	public static void tenantApplicationTesting()
	{
		//test createApplication 
		String appId = createApplication('Testing Property', 'Six Months', '06/06/2013', '2', '3');
		System.assertEquals(1, [Select count() FROM Application__c]);
		
		//test get application 
		System.assertNotEquals(null, getApplication(appId));
		
		//test updateApplication
	    updateApplication(appId,'Testing Property1', 'Six Months', '06/07/2013', '2', '3');
	    Application__c application= getApplication(appId);
	    System.assertEquals('Testing Property1',application.Property_Address__c);
	    
	    //test updatePersonalDetails
	    updatePersonalDetails(new String[]{'MR', 'testing','testing', '10/10/1990','testing','nsw',
	                                       'testing','4324242','34242', 'dev@exr.com.au', 'testing',
	                                       '08320482','testing','testing','3122'}, appId);
	    application= getApplication(appId);   
	    System.assertEquals('dev@exr.com.au',application.Email__c);      
	    
	    //test updatePersonalDetails
	    updatePersonalDetails(new String[]{'MR', 'testing','testing', '10/10/1990','testing','nsw',
	                                       'testing','4324242','34242', 'dev@exr.com.au', 'testing',
	                                       '08320482','testing','testing','3122'}, appId);
	    application= getApplication(appId);   
	    System.assertEquals('dev@exr.com.au',application.Email__c);   
	    
	    //test update Emergency Contact 
	    updateEmergencyContact(new String[]{'testing', 'testing','testing', '0853028','testing','nsw',
	                                       '2331'}, appId);
	    application= getApplication(appId);   
	    System.assertEquals('0853028',application.Emergency_phone_No__c);     
	    
	    //test update payment details
	    updatePaymentDetails(new String[]{'800', 'Per Week','3200', '3200','6400'}, appId);
	    application= getApplication(appId);   
	    System.assertEquals(6400,application.Sub_ToTal__c);      
	    
	    //test UntilityConnection 
	    updateUtilityConnection(true, appId);
	    application= getApplication(appId);   
	    System.assertEquals(true, application.Utility_Connection__c);  
	    
	    //test updateApplicationHistory 
	    updateApplicationHistory(new String[]{'testing', 'testing','04208443','800','testing',
	                                       'testing','testing','testing', 'testing', 
	                                       '08320482','800','testing','testing'}, true, false,appId);
	    application= getApplication(appId);   
	    System.assertEquals(true,application.Current_Bond_full_returned__c); 
	    System.assertEquals(false,application.Perious_Bond_Full_returned__c);    
	    System.assertEquals('04208443',application.Current_Agent_Phone__c);   
	    
	    //test updateEmploymentDetails
	    updateEmploymentDetails(new String[]{'Testing', 'Testing','Testing', '0123456789',
	                                      'Testing', '3000', 'Per Week'}, appId);
	    application= getApplication(appId);   
	    System.assertEquals(3000,application.Net_Income__c);   
	    
	    //test updateOtherinform
	    updateOtherInfor('Testing',true, 'Testing', false, appId);
	    application= getApplication(appId);   
	    System.assertEquals(true, application.Pets__c); 
	    System.assertEquals(false, application.Smoke__c);    
	    
	    //test updateOtherOccupier 
	    updateOtherOccupier(new String[]{'testing', '043242','testing','832321300','testing',
	                                       '34224242','testing','54354353', 'testing', 
	                                       '08320482'},appId);
	    application= getApplication(appId);   
	    System.assertEquals('08320482',application.Contact_Details5__c);    
	    
	     //test updateReferees 
	    updateReferees(new String[]{'testing', '043242','testing','832321300','testing',
	                                       '34224242','testing','54354353'},appId);
	    application= getApplication(appId);   
	    System.assertEquals('54354353',application.Reference2_Phone__c);                  
	}
	
	@isTest
	public static void addDocumentsTest()
	{
		Application__c app = new Application__c();
		insert app;
		
		String testAttachmentId = addDocument('test.pdf', 'Testing', '', app.Id);
		
		system.assertNotEquals(null, testAttachmentId);
		system.assertEquals(1, [Select count() from Attachment Where ParentId = :app.Id]);
		
		addDocument('test.pdf', 'Testing', testAttachmentId,app.Id);
		system.assertNotEquals(null, testAttachmentId);
		system.assertEquals(1, [Select count() from Attachment Where ParentId = :app.Id]);
	}
	
	@isTest(seeAllData=true)
	public static void sendAcknowledgementEmail()
	{
		Application__c app = new Application__c(Email__c = 'dev@exr.com.au');
		insert app;
		
		system.assertEquals(true, ackowledgementBody(app.Id).Contains(app.Id));
		sendAcknowledgementEmail(app.Id);
	}
	
	@isTest 
	public static void parseTest()
	{
		system.assertEquals(null, parse(''));
		system.assertEquals(null, parse('df12'));
		system.assertEquals(12, parse('12'));
	}
	
	@isTest
	public static void noticeTovcateTest()
	{
		noticeToVacate('Testing address', 'Testing', '0412345678',
    					'dev@exr.com.au','09/12/2013', 'Testing');
        system.assertEquals(1, [select count() from Case]);
        system.assertEquals(2, [select count() from Task]); 
	}
	
	@isTest 
	public static void createVacatingCaseTest()
	{
		createVacatingCase('testing', 'Testing');
		system.assertEquals(1, [select count() from Case]);
		
		getOwnerId();
	}
	
	@isTest 
	public static void getContactTest()
	{
		getContact('dev@exr.com.au', 'Testing', '0412345678');
		system.assertEquals(1, [Select count() From Contact]);
		
		getContact('dev@exr.com.au', 'Testing', '0412345678');
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
	
}