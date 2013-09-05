trigger T_BU_Case on Case (before update)  
{
	for(Case caseTrigger: trigger.new)
	{   
		/* 
		 When the case status is equalt to repair
		 tenant proceed this case as repair case 
		*/
		if(caseTrigger.Type == C_Constant.REPAIR)
		{
			C_RepairHandler handler = new C_RepairHandler(caseTrigger);
			handler.handlerRepair();
		}
		
		if (caseTrigger.Type == C_Constant.ROUTINE_INSPECTION)
		{
			C_RoutineInspectionHandler inspection = new C_RoutineInspectionHandler(caseTrigger);
			inspection.handleInspection(); 
		}
		
		if(caseTrigger.Type == C_Constant.BOND)
		{
			C_BondHandler handler = new C_BondHandler(caseTrigger);
			handler.handleBond();
		}
	}
}