import { LightningElement, api, wire, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import getColumnString from '@salesforce/apex/AIM_DatatableHelper.getColumnString';

export default class aim_Datatable extends LightningElement 
{

    @api tableData = [];
    @api availableActions = [];
    @api fieldList;
    @api selectedRows;
    @api firstSelected;
    @api maxSelection;

    @track isError = true;
    @track error = "No records to display";
    @track columns;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    
    @track preSelectedRows = [];
    
    @wire(getColumnString, {tableData: '$tableData', fieldList: '$fieldList'})
    wiredColumns({ error, data })
    {
        //alert('Calling Get Columns');
        if (data) 
        {
            this.columns = JSON.parse(data);
            //alert(this.tableData);
            this.objData = this.tableData;
            if (this.objData.length > 0)
            {
                this.isError = false;
                this.preSelectedRows = [];
                if (this.selectedRows != null)
                {
                    for (var i=0; i< this.selectedRows.length; i++)
                    {
                        //alert('Pushing: ' + this.selectedRows[i].FirstName);
                        this.preSelectedRows.push(this.selectedRows[i].Id);
                        if (i==0)
                        {
                            this.firstSelected = this.selectedRows[0];
                        }
                    }
                }
            }
            else
            {
                this.isError = true;
                this.selectedRows = [];
                this.firstSelected = null;
            }
        } 
        else if (error) 
        {
            //alert('error!');
            this.isError = true;
            this.error = error.body.exceptionType + ' - ' + error.body.message;
            this.selectedRows = null;
            this.firstSelected = null;
        }
    }

    getSelectedName(event) {
        
        const theSelectedRows = event.detail.selectedRows;
        this.selectedRows = [];
        this.firstSelected = null;
        // Display that fieldName of the selected rows
        for (let i = 0; i < theSelectedRows.length; i++)
        {
            if (i == 0)
            {
                this.selectedRows = [];
                this.firstSelected = theSelectedRows[0];
            }
           this.selectedRows.push(theSelectedRows[i]);
            //alert("You selected: " + theSelectedRows[i].name);
        }
    }

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.objData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.objData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleGoNext() {
        /*// check if NEXT is allowed on this screen
        if (this.availableActions.find(action => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }*/
    }
}