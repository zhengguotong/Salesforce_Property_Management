public with sharing class C_Email
{
	public static OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'rentals@exr.com.au'];
	
	public static void sendSignleEMail(String[] toAddress,String Subject, String body)
	{
		Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAddress);
        mail.setOrgWideEmailAddressId(owea[0].Id);
        mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
        mail.setSubject(Subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	}
	
	public static void sendPainTextEmail(String[] toAddress,String Subject, String body)
	{
		Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
        
        mail.setOrgWideEmailAddressId(owea[0].Id);         
        mail.setOrgWideEmailAddressId(owea[0].Id);
        mail.setToAddresses(toAddress);
        mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
        mail.setSubject(Subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	}
	
	public static void sendSingleAttachemetEmail(String[] toAddress,String Subject, String body,
												Messaging.EmailFileAttachment[] efa)
	{
		Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
        
        mail.setOrgWideEmailAddressId(owea[0].Id);       
		mail.setBccAddresses(toAddress);
		mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
		mail.setSubject(Subject);
		mail.setPlainTextBody(body);
		
		//when attachement is not null then 
		//add this attachment to this email 
		if(efa != null)
		{
			   mail.setFileAttachments(efa);
		}
		
		 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	}
	
	public static void sendBccEMail(String[] toAddress,String Subject, String body)
	{
		Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
        
        mail.setOrgWideEmailAddressId(owea[0].Id);
        mail.setBccAddresses(toAddress);
        mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
        mail.setSubject(Subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	}
	
	public static void sendMassEmail(List<Messaging.SingleEmailMessage> massEmails)
    {
        List<Messaging.Email> allMails = new List<Messaging.Email>();
            
        for( Integer j = 0; j < massEmails.size(); j++ )
        {
            allMails.add(massEmails.get(j));
        }
       
       try
       {
       	    Messaging.SendEmailResult[] results = Messaging.sendEmail( allMails );
       }
       catch(EmailException e)
       {
       		system.debug('Email Exception' + e.getMessage());
       }
           
    }
   
    public static void sendTempleteEmail(String targetId, String templateId, String whatId)
    {
    	Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
        
        mail.setOrgWideEmailAddressId(owea[0].Id);
        mail.setTargetObjectId(targetId);
        mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
        mail.setTemplateId(templateId);
        mail.setWhatId(whatId);
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
    }
    
    public static void sendTempleteEmail(String targetId, String templateId)
    {
    	Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
                
        mail.setOrgWideEmailAddressId(owea[0].Id);        
        mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
        mail.setTargetObjectId(targetId);
        mail.setTemplateId(templateId);
        mail.setSaveAsActivity(true);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
    }
    
     public static void sendAttachmentEmail(String[] toAddress,String subject,
       		     string body,Messaging.EmailFileAttachment efa)
    {
    	Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
        
        mail.setOrgWideEmailAddressId(owea[0].Id);
        mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
        mail.setToAddresses(toAddress);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
    }
    
    public static void sendBccMassEmail(List<String[]> addresses,String Subject, 
                                  String body,Messaging.EmailFileAttachment efa)
    {
    	integer bccCount = 0;
    	String[] bccAddress  = new String[]{};
    	List<Messaging.Email> allMails = new List<Messaging.Email>();
    	 
    	for(integer i = 0; i < addresses.size(); i++)
    	{
    		 bccAddress.add(addresses[i][0]);
    		 bccCount++;
    		 
    		 if(i == addresses.size() - 1 || bccCount == 20 )
    		 {
    		 	Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
                
                mail.setOrgWideEmailAddressId(owea[0].Id);
        		mail.setBccAddresses(bccAddress);
        		mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
        		mail.setSubject(Subject);
        		mail.setHtmlBody(body);
        		
        		//when attachement is not null then 
        		//add this attachment to this email 
        		if(efa != null)
        		{
        			   mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        		}
        		
        		allMails.add(mail);
        
        		bccCount = 0;
        		bccAddress.clear();
    		 }
    	}
    	
    	//Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
    }
    
    @IsTest 
    static void sendSignleEMailTest()
    {
    	List<String> toAddress = new String[]{'dev@exr.com.au'};
    	C_Email.sendSignleEMail(toAddress, 'Testing', 'Testing');
    	
    	sendPainTextEmail(toAddress, 'Testing', 'Testing');
    }
    
    @isTest 
    static void  sendSingleAttachemetEmailTest()
    {
    	//test when attachment is empty
    	C_Email.sendSingleAttachemetEmail(new String[]{'dev@exr.com.au'}, 'Testing', 'Testing',null);
    	
    	//test when attachment is not empty
    	Case testCase = new Case(Subject = 'Test');
    	insert testCase;
    	
    	Messaging.EmailFileAttachment[] efas = new Messaging.EmailFileAttachment[]{};
    	
    	Blob testBlob = Blob.valueof('Test paf');
    	
    	Attachment attachment = new Attachment();
    	attachment.Name = 'Test.pdf';
    	attachment.Body = testBlob;
    	attachment.ParentId = testCase.Id;
    	insert attachment;
    	
    	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	 	efa.setFileName(attachment.Name);
     	efa.setBody(attachment.Body);
     	
     	efas.add(efa);
     	
    	C_Email.sendSingleAttachemetEmail(new String[]{'dev@exr.com.au'},'Testing',
    	                          					'Testing',efas);
    }
    
    @IsTest 
    static void sendBccEMailTest()
    {
    	List<String> toAddress = new String[]{'dev@exr.com.au'};
    	C_Email.sendBccEMail(toAddress, 'Testing', 'Testing');
    }
    
    @IsTest 
    static void sendMassEmaiTest()
    {
    	List<Messaging.SingleEmailMessage> massEmails = new List<Messaging.SingleEmailMessage>();
    	C_Email.sendMassEmail(massEmails);
    }
    
    @IsTest(SeeAllData=true)
    static void sendTempleteEmailTest()
    {
    	
    	EmailTemplate template = [Select Id From EmailTemplate 
    							  limit 1];
    	
    	Lead lead = new Lead(LastName ='Test',
    	  				     MobilePhone = '0405795363',
    	  				   	 Email = 'dev@exr.com.au',
    	  				   	 Company = 'Testing');
    	insert lead;
    	  
    	 C_Email.sendTempleteEmail(lead.Id, template.Id);
    	  
    	 Case testCase = new Case();
    	  				   
    	 C_Email.sendTempleteEmail(lead.Id, template.Id, testCase.Id);
    }
    
    @isTest(seeAllData=true) 
    public static void sendAttachmentEmail()
    {
    	Case testCase = new Case(Subject = 'Test');
    	insert testCase;
    	
    	Blob testBlob = Blob.valueof('Test paf');
    	
    	Attachment attachment = new Attachment();
    	attachment.Name = 'Test.pdf';
    	attachment.Body = testBlob;
    	attachment.ParentId = testCase.Id;
    	insert attachment;
    	
    	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	 	efa.setFileName(attachment.Name);
     	efa.setBody(attachment.Body);
     	
    	C_Email.sendAttachmentEmail(new String[]{'dev@exr.com.au'},'Testing',
    	                          					'Testing',efa);
    }
    
    @isTest(seeAllData=true) 
    static void sendBccMassEmailTest() 
    {
    	List<String[]> toAddresses = new List<String[]>();
    	
    	String[] toAddress = new String[]{'dev@exr.com'};
    	
    	toAddresses.add(toAddress);
    	toAddresses.add(toAddress);
    	toAddresses.add(toAddress);
    	
    	Case testCase = new Case(Subject = 'Test');
    	insert testCase;
    	
        Blob testBlob = Blob.valueof('Test paf');
    	
    	Attachment attachment = new Attachment();
    	attachment.Name = 'Test.pdf';
    	attachment.Body = testBlob;
    	attachment.ParentId = testCase.Id;
    	insert attachment;
    	
    	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	    efa.setFileName(attachment.Name);
	    efa.setBody(attachment.Body); 
    	
    	C_Email.sendBccMassEmail(toAddresses, 'Testing', 'Testing', efa);
    }
}