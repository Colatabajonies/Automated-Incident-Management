import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SelectedMapPicker extends NavigationMixin(LightningElement)
{
    // data;
    selectedData;
    accountUrl;
    contactUrl;
    assetUrl;
    incidentUrl;
    productUrl;

    @api
    showSelectedItem(value)
    {
        this.selectedData = value;
        if(value != undefined)
        {
        if(value.assetId)
        {
        this.generateNavigationUrl(value.assetId, 'Asset');
        }
        if(value.accountId)
        {
        this.generateNavigationUrl(value.accountId, 'Account');
        }
        if(value.contactId)
        {
        this.generateNavigationUrl(this.selectedData.contactId, 'Contact');
        }
        if(value.productId)
        {
        this.generateNavigationUrl(this.selectedData.productId, 'Product2');
        }
        if(value.incidentId)
        {
        this.generateNavigationUrl(this.selectedData.incidentId, 'Incident');
        }
    }
    }

    // @api 
    // get selectedData(){
    //     return this.data;
    // }

    // set selectedData(value){
    //     console.log(value);
    //     this.data = value;
    //     if(value.assetId)
    //     {
    //     //this.generateNavigationUrl(value.assetId, 'Asset');
    //     }
    //     if(value.accountId)
    //     {
    //     //this.generateNavigationUrl(value.accountId, 'Account');
    //     }
    //     // if(value.contactId)
    //     // {
    //     // this.generateNavigationUrl(this.selectedData.contactId, 'Contact');
    //     // }
    //     // if(value.productId)
    //     // {
    //     // this.generateNavigationUrl(this.selectedData.productId, 'Product2');
    //     // }
    //     // if(value.incidentId)
    //     // {
    //     // this.generateNavigationUrl(this.selectedData.incidentId, 'Incident');
    //     // }
    // }

    // get accountUrl()
    // {
    //     this.generateNavigationUrl(this.data.accountId, 'Account');
    //     return this.accountUrl;
    // }

    handleClick(event){
        event.preventDefault();
        event.stopPropagation();
        console.log(event);
        let id;
        if(event.target.dataset.object == 'Account')
        {
            id = this.selectedData.accountId;
        }
        else if(event.target.dataset.object == 'Asset')
        {
            id = this.selectedData.assetId;
        }
        else if(event.target.dataset.object == 'Contact')
        {
            id = this.selectedData.contactId;
        }
        else if(event.target.dataset.object == 'Product')
        {
            id = this.selectedData.productId;
        }
        else if(event.target.dataset.object == 'Incident')
        {
            id = this.selectedData.incidentId;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                actionName: 'view'
            }
        });
    }

    generateNavigationUrl(id, objectType)
    {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                actionName: 'view',
            },
        }).then((url) => {
            console.log(url);
            if(objectType == 'Asset'){
                this.assetUrl = url;
            }
            else if(objectType == 'Account'){
                this.accountUrl = url;
            }
            else if(objectType == 'Contact'){
                this.contactUrl = url;
            }
            else if(objectType == 'Incident'){
                this.incidentUrl = url;
            }
            else if(objectType == 'Product2'){
                this.productUrl = url;
            }
            
        });
    }
}