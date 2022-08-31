global with sharing class AIM_DatatableHelper
{
    @AuraEnabled(cacheable=true)
    public static String getColumnString(List<sObject> tableData, String fieldList) 
    {
        System.debug('calling colstring function');
        if (tableData == null || tableData.size() == 0)
        {
            return null;
        }

        string objAPIName = tableData[0].getSObjectType().getDescribe().getName();
        string openRecordField = '';
        fieldList = fieldList.remove(' ');
        
        string result = '[';
        SObjectType myObjType = Schema.getGlobalDescribe().get(objAPIName);
        Map<String,Schema.SObjectField> mfields = myObjType.getDescribe().fields.getMap();
        
        for (string currentField : fieldList.split(','))
        {
            if (string.isBlank(currentField))
            {
                continue;
            }
            string targetField = currentField;
            if (currentField.contains('.'))
            {
                targetField = currentField.split('\\.')[0].replace('__r','__c');
            }
            system.debug('Checking for field:' + targetField);
            for (Schema.SObjectField sField : mfields.values()) 
            {
                schema.DescribeFieldResult dField = sField.getDescribe(); 
                String fieldLabel = dField.getLabel();
                String fieldAPIName = dField.getName();      
                string fieldType = String.ValueOf(dField.getType()).tolowercase();
                
                /*if (currentField.contains('.'))
                {
                    fieldLabel += '.' + currentField.split('\\.')[1];
                    fieldType = 'string';
                }*/
                
                //Handle all the types of fields
                if (fieldType == 'id')fieldType = 'string';
                
                if (targetField.toLowerCase() == fieldAPIName.toLowerCase() || (currentField.contains('.') && !currentField.contains('__c') && targetField + 'id' == fieldAPIName.toLowerCase()))
                {
                    system.debug('Adding Field to datagrid:' + fieldLabel);
                    //we need to add the string to this
                    result += '{"label": "' + fieldLabel  + '", "fieldName": "' + fieldAPIName + '", "sortable": true, "type": "' + fieldType.replace('datetime', 'date') + '"' + (fieldType == 'datetime' ? ', "typeAttributes":{"year":"numeric", "month":"numeric", "weekday":"short", "day":"numeric", "hour":"2-digit", "minute":"2-digit"}' : '') + (fieldType == 'url' ? ', "typeAttributes":{"label":{"fieldName":"name"}}' : '') + '},';
                    break;
                }
            }
        }
        result = result.removeEnd(',') + ']';
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<tileItem> getTileData(List<string> lstInput) 
    {
        Integer len = 5;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
        system.debug('Random Number-' + randomNumber);

        List<tileItem> objItems = new List<tileItem>();
        integer counter = 1;
        TimeZone tz = UserInfo.getTimeZone();
        
        for (String currentVal : lstInput)
            {
                tileItem newItem = new tileItem();
                newItem.TileHTML = currentVal.contains('<') ? currentVal : '<span class="slds-text-heading_medium">' + currentVal + '</span>'; //<span class="slds-text-title"></span>
                newItem.InputID = 'visual-picker-' + String.valueOf(counter) + randomNumber;
                newItem.InputValue = 'visual-picker-' + String.valueOf(counter);
                newItem.RandomNumber = randomNumber;
                newItem.Checked = false;
                newItem.Id = currentVal.contains('|') ? currentVal.split('\\|')[1] : currentVal;
                objItems.add(newItem);
                counter++;
            }
        return objItems;
    }


    global class tileItem
    {
        @AuraEnabled
        global String Id;
        @AuraEnabled
        global String TileHTML;
        @AuraEnabled
        global String InputID;
        @AuraEnabled
        global String InputValue;
        @AuraEnabled
        global Boolean Checked;
        @AuraEnabled
        global String RandomNumber;
    } 
}