public with sharing class GeoMapController {

  private enum SupportedObject {ACCOUNT, CONTACT, PRODUCT2, ASSET, INCIDENT}

  @AuraEnabled(cacheable=true scope='global')
  public static List<OutputWrapper> getAssets(List<Id> inputIds) {
    try {
      if (inputIds != null) {
        SupportedObject sObjectType = SupportedObject.valueOf(String.valueOf(inputIds.get(0)?.getSObjectType()));
        switch on sObjectType {
          when INCIDENT
          {
            return getAssetRecordsForIncidentType(inputIds);
          }
          when ACCOUNT {
            return getAssetRecordsForObjectTypes(inputIds, SupportedObject.ACCOUNT, 'AccountId');
          }
          when CONTACT {
            return getAssetRecordsForObjectTypes(inputIds, SupportedObject.CONTACT, 'ContactId');
          }
          when PRODUCT2 {
            return getAssetRecordsForObjectTypes(inputIds, SupportedObject.PRODUCT2, 'Product2Id');
          }
          when ASSET {
            return getAssetRecordsForObjectTypes(inputIds, SupportedObject.ASSET, 'Id');
          }
          when else {
            return null;
          }
        }
      }
      return null;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static List<OutputWrapper> getAssetRecordsForObjectTypes(List<Id> inputIds, SupportedObject objectType, String filteredSObjectField) {
    List<OutputWrapper> response = new List<OutputWrapper>();
    if(!String.isBlank(filteredSObjectField))
    {
    String query = 'SELECT Id,    Name,    Latitude,    Longitude,    Status,    AccountId,    Account.Name,    ContactId,    Contact.Name,    Product2Id,    Product2.Name,    Product2.Family  FROM Asset  WHERE ' + String.escapeSingleQuotes(filteredSObjectField) + ' IN :inputIds';
    SObjectAccessDecision decision = Security.stripInaccessible(System.AccessType.READABLE, Database.query(query));
            for (Asset asset : (List<Asset>) decision.getRecords()) {
              OutputWrapper output = new OutputWrapper();
              output.relatedObjectType = objectType.name();
              output.assetId = asset.Id;
              output.assetName = asset?.Name;
              output.assetLatitude = asset?.Latitude?.toPlainString();
              output.assetLongitude = asset?.Longitude?.toPlainString();
              output.assetStatus = asset?.Status;
              output.accountId = asset?.AccountId;
              output.accountName = asset?.Account?.Name;
              output.contactId = asset?.ContactId;
              output.contactName = asset?.Contact?.Name;
              output.productId = asset?.Product2Id;
              output.productName = asset?.Product2?.Name;
              output.productFamily = asset?.Product2?.Family;
              response.add(output);
            }
            return response;
          }
          return null;
  }

  private static List<OutputWrapper> getAssetRecordsForIncidentType(List<Id> inputIds) {
    List<OutputWrapper> response = new List<OutputWrapper>();
    SObjectAccessDecision decision = Security.stripInaccessible(System.AccessType.READABLE, [
      SELECT
        Id,
        AssetId,
        Asset.Name,
        Asset.Latitude,
        Asset.Longitude,
        Asset.Status,
        Asset.AccountId,
        Asset.Account.Name,
        Asset.ContactId,
        Asset.Contact.Name,
        Asset.Product2Id,
        Asset.Product2.Name,
        Asset.Product2.Family,
        IncidentId,
        Incident.IncidentNumber,
        Incident.Status
      FROM IncidentRelatedItem
      WHERE IncidentId IN :inputIds
    ]);
          for (IncidentRelatedItem incidentRelatedItem : (List<IncidentRelatedItem>) decision.getRecords()) {
            OutputWrapper output = new OutputWrapper();
            output.relatedObjectType = 'Incident';
            output.assetId = incidentRelatedItem.AssetId;
            output.assetName = incidentRelatedItem.Asset?.Name;
            output.assetStatus = incidentRelatedItem.Asset?.Status;
            output.incidentId = incidentRelatedItem.IncidentId;
            output.incidentNumber = incidentRelatedItem.Incident
              ?.IncidentNumber;
            output.incidentStatus = incidentRelatedItem.Incident
              ?.Status;
            output.assetLatitude = incidentRelatedItem.Asset
              ?.Latitude
              ?.toPlainString();
            output.assetLongitude = incidentRelatedItem.Asset
              ?.Longitude
              ?.toPlainString();
            output.accountId = incidentRelatedItem.Asset?.AccountId;
            output.accountName = incidentRelatedItem.Asset?.Account?.Name;
            output.contactId = incidentRelatedItem.Asset?.ContactId;
            output.contactName = incidentRelatedItem.Asset?.Contact?.Name;
            output.productId = incidentRelatedItem.Asset?.Product2Id;
            output.productName = incidentRelatedItem.Asset?.Product2?.Name;
            output.productFamily = incidentRelatedItem.Asset?.Product2?.Family;
            response.add(output);
          }
          return response;
  }

  class OutputWrapper {
    @AuraEnabled
    public String relatedObjectType { get; set; }
    @AuraEnabled
    public String assetId { get; set; }
    @AuraEnabled
    public String assetName { get; set; }
    @AuraEnabled
    public String assetStatus { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public String contactId { get; set; }
    @AuraEnabled
    public String contactName { get; set; }
    @AuraEnabled
    public String incidentId { get; set; }
    @AuraEnabled
    public String incidentNumber { get; set; }
    @AuraEnabled
    public String incidentStatus { get; set; }
    @AuraEnabled
    public String assetLatitude { get; set; }
    @AuraEnabled
    public String assetLongitude { get; set; }
    @AuraEnabled
    public String productId { get; set; }
    @AuraEnabled
    public String productName { get; set; }
    @AuraEnabled
    public String productFamily { get; set; }
  }
}