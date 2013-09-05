trigger TT_BU_Property on Property__c (before update) 
{
	for(Property__c property: trigger.new)
	{
		if(property.Property_Status__c == C_Constant.FOR_RENT
		   || property.Property_Status__c == C_Constant.FOR_SALE)
		 {
		 	 if(property.Picture_Id__c == null)
		 	 {
		 	 	List<Attachment> attachments = [select Id
					     						from Attachment
				         						where ParentId = :property.Id
				         						limit 1];
				         						
 			     if(attachments.size() > 0)
 			     {
 			     	property.Picture_Id__c = attachments[0].Id;
 			     }
		 	 }
		 }
	}
}