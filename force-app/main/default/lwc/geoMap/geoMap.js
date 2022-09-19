import { LightningElement, api, wire, track } from 'lwc';
import getAssets from '@salesforce/apex/GeoMapController.getAssets'

export default class GeoMap extends LightningElement {
    @api flexipageRegionWidth;
    @api recordId;
    @api inputRecords;
    @api inputIds;
    @track mapMarkers;
    @track productOptions;
    @track productFamilyOptions;
    @track statusOptions;
    selectedMarkerValue = '';
    selectedMarkerData;
    result;
    productValue = 'All';
    productFamilyValue = 'All';
    statusValue = 'All';
    listView = 'visible';
    showList;


    handleChange(event) {
        if(event.target.dataset.name == 'product')
        {
            this.productValue = event.detail.value;
        }
        else if(event.target.dataset.name == 'productFamily')
        {
            this.productFamilyValue = event.detail.value;
        }
        else if(event.target.dataset.name == 'status')
        {
            this.statusValue = event.detail.value;
        }
        //this.selectedMarkerValue='';
        this.selectedMarkerData = undefined;
        this.template.querySelector('c-selected-map-picker').showSelectedItem(this.selectedMarkerData);
        this.recompute();
    }

    connectedCallback() {
        if (this.recordId != undefined) {
            this.inputIds = [this.recordId];
        }
        else if (this.inputRecords != undefined) {
            this.inputIds = this.inputRecords.map((record) => record.Id)
        }
        console.log(this.inputIds);
    }

    @wire(getAssets, { inputIds: '$inputIds' })
    wiredAssets({ error, data }) {
        if (data) {
            this.result = data;
            console.log(this.result);
            this.error = undefined;
            this.generateMapInput(data);
        } else if (error) {
            this.error = error;
            this.assets = undefined;
        }
    }

    generateMapInput(data) {
        this.mapMarkers = [];
        this.productOptions = [{ label: 'All', value: 'All' }];
        this.productFamilyOptions =[{ label: 'All', value: 'All' }];
        this.statusOptions = [{ label: 'All', value: 'All' }];
        let productSet = new Set(['All']);
        let productFamilySet = new Set(['All']);
        let statusSet = new Set(['All']);
        this.listView = 'Hide';
        this.showList = false;
        
        /*if(data.length > 10)
        {
            this.listView = 'Hide';
            this.showList = false;
        }
        else
        {
            this.listView = 'visible';
            this.showList = true;
        } */
        for (let record of data) {
            let desc = '';
            if (record.accountName != undefined) {
                desc += `<b>Account:</b>  ${record.accountName} <br/>`;
            }
            if (record.contactName != undefined) {
                desc += `<b>Contact:</b>  ${record.contactName} <br/>`;
            }
            if (record.incidentNumber != undefined) {
                desc += `<b>Incident:</b>  ${record.incidentNumber} <br/>`;
            }
            if (record.productName != undefined) {
                desc += `<b>Product:</b>  ${record.productName} <br/>`;
            }
            let mapRow = {
                location: ({
                    Latitude: record.assetLatitude,
                    Longitude: record.assetLongitude
                }),
                value: record.assetId,
                icon: 'standard:asset_object',
                description: `${desc}`,
                title: record.assetName
            };
            this.mapMarkers.push(mapRow);
            if (record.productId && !productSet.has(record.productId)) {
                let productOption = { label: record.productName, value: record.productId };
                this.productOptions.push(productOption);
                productSet.add(record.productId);
            }
            if (record.productFamily && !productFamilySet.has(record.productFamily)) {
                let productFamilyOption = { label: record.productFamily, value: record.productFamily };
                this.productFamilyOptions.push(productFamilyOption);
                productFamilySet.add(record.productFamily);
            }
        
            if (record.assetStatus && !statusSet.has(record.assetStatus)) {
                let statusOption = { label: record.assetStatus, value: record.assetStatus };
                this.statusOptions.push(statusOption);
                statusSet.add(record.assetStatus);
            }

        }
        //     this.mapMarkers = data.map(function(record) {
        //         let desc = '';
        //         if(record.accountName != undefined)
        //         {
        //             desc += `<b>Account:</b>  ${record.accountName} <br/>`;
        //         }
        //         if(record.contactName != undefined)
        //         {
        //             desc += `<b>Contact:</b>  ${record.contactName} <br/>`;
        //         }
        //         if(record.incidentNumber != undefined)
        //         {
        //             desc += `<b>Incident:</b>  ${record.incidentNumber} <br/>`;
        //         }
        //         if(record.productName != undefined)
        //         {
        //             desc += `<b>Product:</b>  ${record.productName} <br/>`;
        //         }
        //         return { location: ({ 
        //             Latitude: record.assetLatitude,
        //             Longitude: record.assetLongitude
        //             }),
        //         value: record.assetId,
        //         icon: 'standard:asset_object',
        //         description: `${desc}`,
        //         title: record.assetName
        // }});
    }

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
        let selected = this.selectedMarkerValue;
        let selectedData;
        this.result.forEach(function (record) {
            if (record.assetId == selected) {
                selectedData = record;
            }
        });
        this.selectedMarkerData = selectedData;
        console.log(this.template.querySelector('c-selected-map-picker'));
        this.template.querySelector('c-selected-map-picker').showSelectedItem(this.selectedMarkerData);
    }

    recompute()
    {
        this.mapMarkers = [];
        // this.productOptions = [{ label: 'All', value: 'All' }];
        // this.productFamilyOptions =[{ label: 'All', value: 'All' }];
        // this.statusOptions = [{ label: 'All', value: 'All' }];
        // let productSet = new Set(['All']);
        // let productFamilySet = new Set(['All']);
        // let statusSet = new Set(['All']);
        let count = 0;
        for (let record of this.result) {
            if((this.productValue == 'All' || record.productId == this.productValue) && (this.productFamilyValue == 'All' || record.productFamily == this.productFamilyValue) && (this.statusValue == 'All' || record.assetStatus == this.statusValue))
            {
            let desc = '';
            if (record.accountName != undefined) {
                desc += `<b>Account:</b>  ${record.accountName} <br/>`;
            }
            if (record.contactName != undefined) {
                desc += `<b>Contact:</b>  ${record.contactName} <br/>`;
            }
            if (record.incidentNumber != undefined) {
                desc += `<b>Incident:</b>  ${record.incidentNumber} <br/>`;
            }
            if (record.productName != undefined) {
                desc += `<b>Product:</b>  ${record.productName} <br/>`;
            }
            let mapRow = {
                location: ({
                    Latitude: record.assetLatitude,
                    Longitude: record.assetLongitude
                }),
                value: record.assetId,
                icon: 'standard:asset_object',
                description: `${desc}`,
                title: record.assetName
            };
            this.mapMarkers.push(mapRow);
            count++;
            // if (record.productId && !productSet.has(record.productId)) {
            //     let productOption = { label: record.productName, value: record.productId };
            //     this.productOptions.push(productOption);
            //     productSet.add(record.productId);
            // }
            // if (record.productFamily && !productFamilySet.has(record.productFamily)) {
            //     let productFamilyOption = { label: record.productFamily, value: record.productFamily };
            //     this.productFamilyOptions.push(productFamilyOption);
            //     productFamilySet.add(record.productFamily);
            // }
        
            // if (record.assetStatus && !statusSet.has(record.assetStatus)) {
            //     let statusOption = { label: record.assetStatus, value: record.assetStatus };
            //     this.statusOptions.push(statusOption);
            //     statusSet.add(record.assetStatus);
            // }
        }
        
    }
    if(count > 10)
        {
            this.listView = 'Hide';
            this.showList = false;
        }
        else
        {
            this.listView = 'visible';
            this.showList = true;
        }
    this.listView = 'Hide';
    this.showList = false;
}

handleListToggle(event)
{
    this.showList = event.target.checked;
    if(this.showList)
    {
        this.listView = 'visible';
    }
    else{
        this.listView = 'hidden';
    }
}
}