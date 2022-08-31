import { LightningElement, api, wire, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import getTileData from '@salesforce/apex/AIM_DatatableHelper.getTileData';

export default class Aim_TilePicker extends LightningElement 
{
    @api tileSize;
    @api lstItems;
    @api multiSelect;
    @api selectedItems;
    @api selectedItem;
    
    @track tileItems;
    @track inputType;
    @track tileSizeClass;
    @track isError = true;
    @track error = "No records to display";


    @wire(getTileData, {lstInput: '$lstItems'})
    wiredItems({ error, data })
    {
        if (data) {
            //alert(data);
            this.inputType = this.multiSelect ? 'checkbox' : 'radio';
            this.tileSizeClass = 'slds-visual-picker slds-visual-picker_' + this.tileSize;
            this.tileItems = data;
            this.isError = false;
        } else if (error) {
            alert('error!');
            this.isError = true;
            this.error = error.body.exceptionType + ' - ' + error.body.message;
            this.selectedItems = null;
            this.selectedItem = null;
        }
    }

    handleCheckBoxChange(event)
    {
        //alert(event.target.value);
        //alert(event.target.checked);
        
        this.selectedItem = null;
        if (!this.multiSelect)
        {
            this.selectedItems = [];
            if (event.target.checked)
            {
                this.selectedItems.push(event.target.value);
                this.selectedItem = event.target.value;    
            }
            this.selectedItems.push(event.target.value);
        }
        else
        {
            if (event.target.checked)
            {
                //we are adding selection
                this.selectedItems.push(event.target.value);
            }
            else if (this.selectedItems.includes(event.target.value))
            {
                this.selectedItems.splice(this.selectedItems.indexOf(event.target.value), 1);
            }

        }

        if (this.selectedItems.length > 0)
        {
            this.selectedItem = this.selectedItems[0];
        }
    }
}