trigger T_Arrears on Arrears__c (after insert) 
{
	for(Arrears__c arrear: Trigger.new)
	{
		C_ArrearsHandler handler = new C_ArrearsHandler(arrear);
		handler.determineAction();
	}
}