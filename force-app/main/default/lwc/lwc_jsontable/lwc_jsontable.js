import { LightningElement, api, track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import saveJsonData from '@salesforce/apex/jsonDataController.saveJsonData';
import fetchAddress from '@salesforce/apex/jsonDataController.fetchRelatedAddress'; // fetchRelatedAddress
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
export default class Lwc_jsontable extends LightningElement {
    @api jsonData; // JSON string passed from parent or record field
    @api recordId;//='a49ce000000Hl7NAAS';//'a49ce000000HncDAAS';
    @api outputjson;
    @track shipToOptions=[];
    @track billToOptions=[];
    @track payerOptions=[];
    @track shiptocustomernumber;
    @track billtocustomernumber;
    @track payercustomernumber;
    @track tabs = [];
    @track summarydetail;
    @track items;
    @track soldto;
    @track shipto;
    @track billto;
    @track payer;
    @track draftValues = {};
    @track draft={};
    @track selectedsoldtoid;
    @track selectedRecordId;  // do not change as this will fetch information for selected address
    @track selectedsoldtomaster='';
    @track selectedshipto;
    @track selectedbillto;
    @track selectedpayer;
    @track orderdetail=[];
    @track newsoldto=[];
    @track newshipto=[];
    @track newbillto=[];
    @track newpayer=[];
    erpcustomernumber;
    soldtofulladdress;
    soldtocustomername;
    shiptofulladdress;
    shiptocustomername;
    billtofulladdress;
    billtocustomername;
    payerfulladdress;
    payercustomername;
    shiptofilterlogic;
    billtofilterlogic;
    soldtofilterlogic;
    payerfilterlogic;
    activetabContent = '';
    originalJson = null;
    divbutton=false;
    soldtofilter;
    FIELDS = ['ERP_Address__c.Master_Address__c','ERP_Address__c.Name', 'ERP_Address__c.ERP_Sales_Org__c', 'ERP_Address__c.fxAddressFull__c', 'ERP_Address__c.fxERPName_full__c','ERP_Address__c.fxCustomerName_Master__c','ERP_Address__c.fxCustomerNumber_Target__c'];
    EntryFIELDS = ['Order_Entry_Data__c.json_data__c'];
    
    connectedCallback() {
        // Parse JSON data into objects and initialize tabs
      //  this.originalJson = JSON.parse(this.jsonData);
       this.fetchjsondata();
           /* this.generateTabs(this.originalJson);
            console.log('tab data',JSON.stringify(this.tabs));
            this.soldtofilter =['0100560277','0100692510','0100560276'];
            this.dyanmicfilter(); */
        
        }
  isValidJsonString(jsonString) {
    
    try {
        // Attempt to parse the string into JSON
        const parsed = JSON.parse(jsonString);
        
        // Ensure the parsed result is either an object or an array (valid JSON structure)
        return (typeof parsed === 'object' && parsed !== null);
    } catch (e) {
        // If parsing fails, it's not a valid JSON string
        return false;
    }
    }
    checkIfStringifiedJson(nestedJson) {
        // Loop through the nested JSON object (or array)
        const fieldsToParse = ['soldTo', 'shipTo', 'billTo', 'payer'];
        for (const key in nestedJson) {
            if (nestedJson.hasOwnProperty(key)) {
                const value = nestedJson[key];
                
                // Check if the value is a string
                if (typeof value === 'string' && fieldsToParse.includes(key)) {
                    // Check if it's a stringified JSON
                    if (this.isValidJsonString(value)) {
                        nestedJson[key]= JSON.parse(nestedJson[key]);
                    } else {
                        console.log(`The value at "${key}" is a string but not a valid stringified JSON.`);
                       return null;
                    }
                }else if(value == undefined && fieldsToParse.includes(key)){
                    nestedJson[key]= [];
                } else {
                   // console.log(`The value at "${key}" is not a string.`);
                }
            }
        }
        return nestedJson;
    }
        fetchjsondata() {
            saveJsonData({ recId: this.recordId})
            .then(result => {
              this.originalJson =  this.checkIfStringifiedJson(JSON.parse(result)); //JSON.parse(result); //
               this.generateTabs(this.originalJson);
               this.soldtofilter = this.originalJson['soldTo'].map(item => item.customerNumber);
                this.dyanmicfilter(); 
                this.saveData();
            })
            .catch(error => {
                console.log(error);
                this.originalJson = undefined;
            })
            console.log('on fetch this.soldtofilter ',JSON.stringify(this.soldtofilter ));
        }
        fetchaddressforsoldto(){
            fetchAddress({ recId: this.selectedsoldtomaster})
            .then(result => {
                result.forEach((obj) => {

                    let varlabel=(obj['fxCustomerNumber_Target__c'] !=undefined?obj['fxCustomerNumber_Target__c']:'')+'--['+(obj['ERP_Sales_Org__c'] !=undefined ?obj['ERP_Sales_Org__c']:'')+'] '+(obj['fxERPName_full__c']!=undefined?obj['fxERPName_full__c']:'')+'('+obj['fxAddressFull__c']+')['+(obj['fxECOM_Target_VAT__c'] != undefined?obj['fxECOM_Target_VAT__c']:'')+']';
                   // console.log('varlabel',varlabel);
                    if (obj['Address_Type__c']=='Ship To') {
                        this.shipToOptions.push({label: varlabel, value: obj['fxCustomerNumber_Target__c'],addressFull:obj['fxAddressFull__c'],customerNameFull:obj['fxERPName_full__c']});
                       // console.log('shipto',JSON.stringify(this.shipToOptions));
                    }else if (obj['Address_Type__c']=='Bill To') {
                        this.billToOptions.push({label: varlabel, value: obj['fxCustomerNumber_Target__c'],addressFull:obj['fxAddressFull__c'],customerNameFull:obj['fxERPName_full__c']});
                      //  console.log('billto',JSON.stringify(this.billToOptions));
                    }else if (obj['Address_Type__c']=='Payer') {
                        this.payerOptions.push({label: varlabel, value: obj['fxCustomerNumber_Target__c'],addressFull:obj['fxAddressFull__c'],customerNameFull:obj['fxERPName_full__c']});
                       // console.log('payer',JSON.stringify(this.payerOptions));
                    }
                });
                if(this.shipToOptions.length==1){
                  //  console.log('this.shipToOptions',JSON.stringify(this.shipToOptions));
                    this.shiptocustomernumber=this.shipToOptions[0]['value'];
                        let shipto = {};
                        shipto['customerNumber'] = this.shiptocustomernumber;
                        shipto['addressFull'] =this.shipToOptions[0] !=undefined? this.shipToOptions[0]['addressFull']:'';
                        shipto['customerNameFull'] =this.shipToOptions[0] !=undefined? this.shipToOptions[0]['customerNameFull']:'';
                        shipto['source'] ='Salesforce';
                        let arr=[];
                        arr = [...arr, shipto];
                        this.newshipto=arr;
                }
                if(this.billToOptions.length==1){
                    this.billtocustomernumber=this.billToOptions[0]['value'];
                    let billto = {};
                    billto['customerNumber'] = this.billtocustomernumber;
                    billto['addressFull'] =this.billToOptions[0] !=undefined? this.billToOptions[0]['addressFull']:'';
                    billto['customerNameFull'] =this.billToOptions[0] !=undefined? this.billToOptions[0]['customerNameFull']:'';
                    billto['source'] ='Salesforce';
                    let arr=[];
                    arr = [...arr, billto];
                   this.newbillto=arr;
                }
                if(this.payerOptions.length==1){
                    this.payercustomernumber=this.payerOptions[0]['value'];
                        let payer = {};
                        payer['customerNumber'] = this.payercustomernumber;
                        payer['addressFull'] =this.payerOptions[0] !=undefined? this.payerOptions[0]['addressFull']:'';
                        payer['customerNameFull'] =this.payerOptions[0] !=undefined? this.payerOptions[0]['customerNameFull']:'';
                        payer['source'] ='Salesforce';
                        let arr=[];
                        arr = [...arr, payer];
                        this.newpayer=arr;
                }
                this.saveData();
            })
            .catch(error => {
                console.log(error);

            })
        }
 
    handleChange(event){
         // console.log('event label',event.target.label);
          // console.log('event',event.detail.value);
           if(event.target.label=='Ship To'){
            this.erpcustomernumber=event.detail.value;
            this.shiptocustomernumber=event.detail.value;
             this.prparearrayofaddress('shipto');
           }else if(event.target.label=='Bill To'){
            this.erpcustomernumber=event.detail.value;
            this.billtocustomernumber=event.detail.value;
              this.prparearrayofaddress('billto');
           }else if(event.target.label=='Payer'){
            this.erpcustomernumber=event.detail.value;
            this.payercustomernumber=event.detail.value;
            this.prparearrayofaddress('payer');
          //  console.log('payer selected');
            
           }
           this.saveData();
             }    
 prparearrayofaddress(addresstype){
        if(addresstype=='soldto'){
            let soldto = {};
            soldto['customerNumber'] = this.erpcustomernumber;
            soldto['addressFull'] =this.soldtofulladdress;
            soldto['customerNameFull'] =this.soldtocustomername;
            soldto['source'] ='Salesforce';
            let arr=[];
            arr = [...arr, soldto];
            this.newsoldto =arr;
            

        } else if(addresstype=='shipto'){
            let shipto = {};
            //console.log('shipToOptions==',JSON.stringify(this.shipToOptions));
            shipto['customerNumber'] = this.erpcustomernumber;
            let selectedshipto;
            if(this.erpcustomernumber !=undefined){
                selectedshipto=  this.shipToOptions.filter((option) =>
                    option.value == this.erpcustomernumber)
            }
           // console.log('selectedshipto',JSON.stringify(selectedshipto));
            shipto['addressFull'] =selectedshipto !=undefined? selectedshipto[0]['addressFull']:'';
            shipto['customerNameFull'] =selectedshipto !=undefined? selectedshipto[0]['customerNameFull']:'';
            shipto['source'] ='Salesforce';
            console.log('shipto',JSON.stringify(shipto));
            let arr=[];
            arr = [...arr, shipto];
           this.newshipto=arr;
        }else if(addresstype=='billto'){
            let billto = {};
            billto['customerNumber'] = this.erpcustomernumber;
            let selectedbillto;
            if(this.erpcustomernumber !=undefined){
                selectedbillto=  this.billToOptions.filter((option) =>
                    option.value === this.erpcustomernumber)
            }
            billto['addressFull'] =selectedbillto !=undefined? selectedbillto[0]['addressFull']:'';
            billto['customerNameFull'] =selectedbillto !=undefined? selectedbillto[0]['customerNameFull']:'';
            billto['source'] ='Salesforce';
            let arr=[];
            arr = [...arr, billto];
           // console.log('billto',JSON.stringify(billto));
           this.newbillto=arr;
        }else if(addresstype=='payer'){
            let payer = {};
            payer['customerNumber'] = this.erpcustomernumber;
            let selectedpayer;
            if(this.erpcustomernumber !=undefined){
                selectedpayer=  this.payerOptions.filter((option) =>
                    option.value === this.erpcustomernumber)
            }
            payer['addressFull'] =selectedpayer !=undefined? selectedpayer[0]['addressFull']:'';
            payer['customerNameFull'] =selectedpayer !=undefined? selectedpayer[0]['customerNameFull']:'';
            payer['source'] ='Salesforce';
            let arr=[];
            arr = [...arr, payer];
           // console.log('payer',JSON.stringify(payer));
           this.newpayer=arr;
        }
 }
      @wire(getRecord, { recordId: '$selectedRecordId', fields: '$FIELDS'  })
         wiredRecord({ error, data }) {
           // console.log('wire called');
                if (data) {
                    
                    if(this.selectedRecordId==this.selectedsoldtoid){
                        this.selectedsoldtomaster=data.fields.Master_Address__c.value;
                        this.soldtofulladdress=data.fields.fxAddressFull__c.value;
                        this.soldtocustomername=data.fields.fxCustomerName_Master__c.value;
                        this.erpcustomernumber=data.fields.fxCustomerNumber_Target__c.value;
                        this.prparearrayofaddress('soldto');
                        if(this.selectedsoldtomaster != undefined){
                            this.shipToOptions=[];
                            this.billToOptions=[];
                            this.payerOptions=[];
                           this.fetchaddressforsoldto();
                        }
                       // console.log('sold to data===>',JSON.stringify(data));
                        
                    }else if(this.selectedRecordId==this.selectedshiptoid){
                        this.shiptofulladdress=data.fields.fxAddressFull__c.value;
                        this.shiptocustomername=data.fields.fxCustomerName_Master__c.value;
                        this.erpcustomernumber=data.fields.fxCustomerNumber_Target__c.value;
                        this.prparearrayofaddress('shipto');
                     //   console.log('ship to data===>',JSON.stringify(data));
                    }else if(this.selectedRecordId==this.selectedbilltoid){
                        this.billtofulladdress=data.fields.fxAddressFull__c.value;
                        this.billtocustomername=data.fields.fxCustomerName_Master__c.value;
                        this.erpcustomernumber=data.fields.fxCustomerNumber_Target__c.value;
                        this.prparearrayofaddress('billto');
                      //  console.log('bill to data===>',JSON.stringify(data));
                    }
                     else if(this.selectedRecordId==this.selectedpayerid){
                        this.payerfulladdress=data.fields.fxAddressFull__c.value;
                        this.payercustomername=data.fields.fxCustomerName_Master__c.value;
                      //  console.log('payer to data===>',JSON.stringify(data));
                      this.erpcustomernumber=data.fields.fxCustomerNumber_Target__c.value;
                        this.prparearrayofaddress('payer');
                    }
                     this.dyanmicfilter();
                     this.saveData();

                }else if (error) {
                    console.log('error');
                    this.selectedsoldtomaster;
                    this.soldtofulladdress;
                    this.soldtocustomername;
                }
            }
    generateTabs(data) {
        // Create tabs for each top-level key
     //   console.log('before rendering data',JSON.stringify(data));
        this.tabs=[];
        this.orderdetail=[];
        this.payer=[];
        this.items=[];
        this.billto=[];
        this.shipto=[];
        this.summarydetail=[];
        this.soldto=[];
        Object.keys(data).forEach((key) => {
           if(Array.isArray(data[key]) && key.toUpperCase()=='PAYER'.toUpperCase()){
            this.payer={
                label: key,
                data: this.flattenNode(data[key], key),
                columns: this.generateColumns(data[key]),
            };
           }else if(Array.isArray(data[key]) && key.toUpperCase()=='BILLTO'.toUpperCase()){
                    this.billto={
                        label: key,
                        data: this.flattenNode(data[key], key),
                        columns: this.generateColumns(data[key]),
                    };
           }else if(Array.isArray(data[key]) && key.toUpperCase()=='SOLDTO'.toUpperCase()){
                    this.soldto={
                        label: key,
                        data: this.flattenNode(data[key], key),
                        columns: this.generateColumns(data[key]),
                    };
           }
           else if(Array.isArray(data[key]) && key.toUpperCase()=='SHIPTO'.toUpperCase()){
                    this.shipto={
                        label: key,
                        data: this.flattenNode(data[key], key),
                        columns: this.generateColumns(data[key]),
                    };
           }else if(Array.isArray(data[key]) && key.toUpperCase()=='ITEMS'.toUpperCase()){
            this.items={
                label: key,
                data: this.flattenNode(data[key], key),
                columns: this.generateColumns(data[key]),
            };
           } else{
            let obj={};
            obj.Name=key;
            obj.Value=data[key];
            obj.id=`orderdetail-${key}`;
            this.orderdetail.push(obj);
            }
          //  this.draftValues[key] = [];
        }); 
        if(this.orderdetail.length>0){
            this.summarydetail={
                label: "orderdetail",
                data: this.orderdetail,
                columns: [{
                    label: "Name",
                    fieldName: "Name",
                    editable: false,
                    type: 'text',
                },{
                    label: "Value",
                    fieldName: "Value",
                    editable: true,
                    type: 'text',
                }],
            };
        }
        /*console.log("summarydetail",JSON.stringify(this.summarydetail));
        console.log("billto",JSON.stringify(this.billto));
        console.log("soldto",JSON.stringify(this.soldto));
        console.log("payer",JSON.stringify(this.payer));*/
    }
    
    
   dyanmicfilter(){
    this.soldtofilterlogic = {
        criteria: [
            {
                fieldPath: 'Address_Type__c',
                operator: 'eq',
                value: 'Sold To',
            },
            {
                fieldPath: 'fxCustomerNumber_Target__c',
                operator: 'ne',
                value: '',
            }
        ],
        filterLogic: '1 AND 2'
    };
if(this.soldtofilter !=undefined && this.soldtofilter.length>0 && !this.soldtofilterlogic.filterLogic.includes("AND 3")){
    this.soldtofilterlogic.criteria.push( {
        fieldPath: 'fxCustomerNumber_Target__c',
        operator: 'in',
        value: this.soldtofilter,
    });
    this.soldtofilterlogic.filterLogic=this.soldtofilterlogic.filterLogic+' AND 3';
} 
// console.log('this.soldtofilterlogic',JSON.stringify(this.soldtofilterlogic));
    this.shiptofilterlogic = {
        criteria: [
            {
                fieldPath: 'Master_Address__c',
                operator: 'eq',
                value: this.selectedsoldtomaster ==undefined ?'':this.selectedsoldtomaster,
            },
            {
                fieldPath: 'Address_Type__c',
                operator: 'eq',
                value: 'ship To',
            },
            {
                fieldPath: 'Master_Address__c',
                operator: 'ne',
                value: '',
            }
        ],
        filterLogic: '1 AND 2 AND 3'
    };
    this.billtofilterlogic = {
        criteria: [
            {
                fieldPath: 'Master_Address__c',
                operator: 'in',
                value: this.selectedsoldtomaster ==undefined ?'':this.selectedsoldtomaster,
            },
            {
                fieldPath: 'Address_Type__c',
                operator: 'eq',
                value: 'Bill To',
            },
            {
                fieldPath: 'Master_Address__c',
                operator: 'ne',
                value: '',
            }
        ],
        filterLogic: '1 AND 2 AND 3'
    };
    this.payerfilterlogic = {
        criteria: [
            {
                fieldPath: 'Master_Address__c',
                operator: 'in',
                value: this.selectedsoldtomaster ==undefined ?'':this.selectedsoldtomaster,
            },
            {
                fieldPath: 'Address_Type__c',
                operator: 'eq',
                value: 'Payer',
            },
            {
                fieldPath: 'Master_Address__c',
                operator: 'ne',
                value: '',
            }
        ],
        filterLogic: '1 AND 2 AND 3'
    };
   }
  displayinfo = {
        primaryField: 'Name',
        additionalFields: ['fxAddressFull__c']
    }
  
  matchinginfo = {
        primaryField: { fieldPath: 'fxERPName_full__c' },
        additionalFields: [ { fieldPath: 'fxAddressFull__c' } ]
    }
    handlesoldtochange(event){
        this.selectedsoldtoid = event.detail.recordId;
        this.selectedRecordId=event.detail.recordId;
      //------------------------------  
       this.selectedsoldtomaster=null;
       this.soldtofulladdress=null;
       this.soldtocustomername=null;
       //---------------------------
       this.selectedshiptoid=null;
       this.selectedbilltoid=null;
       this.selectedpayerid=null;
       //------------------
       this.shiptofulladdress=null;
       this.shiptocustomername=null;
       this.billtofulladdress=null;
       this.billtocustomername=null;
       this.payerfulladdress=null;
       this.payercustomername=null;
       //-------------------
       this.erpcustomernumber=null;
       this.newsoldto=[];
       this.newshipto=[];
       this.newbillto=[];
       this.newpayer=[];
       //---------------------------
       this.shiptocustomernumber=null;
       this.billtocustomernumber=null;
        this.payercustomernumber=null;
        if(this.selectedRecordId ==undefined){
            this.saveData();
        }
        
    }
    handleshiptochange(event){
        this.selectedRecordId=event.detail.recordId;
        this.selectedshiptoid=this.selectedRecordId;
        this.shiptofulladdress=null;
        this.shiptocustomername=null;
        this.erpcustomernumber=null;
        this.newshipto=[];
    }
    handlebilltochange(event){
        this.selectedRecordId=event.detail.recordId;
        this.selectedbilltoid=event.detail.recordId;
       this.billtofulladdress=null;
       this.billtocustomername=null;
       this.erpcustomernumber=null;
       this.newbillto=[];
    }
    handlepayerchange(event){
        this.selectedRecordId=event.detail.recordId;
        this.selectedpayerid=event.detail.recordId;
       this.payerfulladdress=null;
       this.payercustomername=null;
       this.erpcustomernumber=null;
       this.newpayer=[];
    }
    flattenNode(node, parentKey) {
        if (Array.isArray(node)) {
            return node.map((item, index) => {
                // Check for a specific condition on the item
                const newItem = {
                    id: `${parentKey}-${index}`,
                    ...item
                };
    
                // Add new properties conditionally
                if (newItem.source !=undefined && newItem.source.toUpperCase() === 'OPENAI') {
                    // Example of adding a new property based on condition
                    newItem.fxFinalCustomerName = newItem.name1 +' '+newItem.name2 +' '+newItem.name3;
                    newItem.fxFinalCustomerAddress=newItem.streetNumber+' '+newItem.city+' '+newItem.state+' '+newItem.country+' '+newItem.zipCode;
                }else if(newItem.source !=undefined && newItem.source.toUpperCase() === 'SALESFORCE'){
                    newItem.fxFinalCustomerName =newItem.customerNameFull;
                    newItem.fxFinalCustomerAddress=newItem.addressFull;
                }else{
                    newItem.fxFinalCustomerName ='';
                    newItem.fxFinalCustomerAddress='';
                }
             
                return newItem;
            });
        }
        return [node]; // If it's an object, wrap it into an array for the table
    }


    generateColumns(node) {
        if (Array.isArray(node) && node.length > 0) {
            return Object.keys(node[0]).map((key) => ({
                label: key,
                fieldName: key,
                editable: true,
                type: typeof node[0][key] === 'number' ? 'number' : 'text',
            }));
        } else if (typeof node === 'object') {
            return Object.keys(node).map((key) => ({
                label: key,
                fieldName: key,
                editable: true,
                type: typeof node[key] === 'number' ? 'number' : 'text',
            }));
        }
        return [];
    }
    handleactivetab(event){
        // console.log('event.target.value', event.target.value);
         this.activetabContent = event.target.value;
    }
    handleSave(event) {
      if(this.activetabContent=='summary'){
            this.draftValues=event.detail.draftValues;
            let editedJson= this.buildeditedjsonorderdetail();
            this.generateTabs(editedJson);
            this.draft={};
    }else if(this.activetabContent=='items'){
            this.draftValues=event.detail.draftValues;
            let editedJson= this.buildEditedJson();
             this.generateTabs(editedJson);
             this.draft={};
    }
    this.saveData();
       
    }

    saveData() {
       // console.log('tab', JSON.stringify(this.tabs));
        let outputjson={...this.originalJson};
            outputjson['soldTo']=this.newsoldto;
            outputjson['shipTo']=this.newshipto;
            outputjson['billTo']=this.newbillto;
            outputjson['payer']=this.newpayer;   
            this.outputjson=outputjson; const selectedEvent = new FlowAttributeChangeEvent('outputjson', JSON.stringify(this.outputjson));
            this.dispatchEvent(selectedEvent);                  
      /*  const editedJson = this.buildEditedJson();

       saveJsonData({
            jsonBefore: JSON.stringify(this.originalJson),
            jsonAfter: JSON.stringify(editedJson),
        })
            .then(() => {
                this.showToast('Success', 'Data saved successfully.', 'success');
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
            }); */
    }
    buildeditedjsonorderdetail(){
        const editedJson = { ...this.originalJson };
       // console.log('before JSON.stringify(editedJson)',JSON.stringify(editedJson));
        const updatedValues = this.draftValues;
            updatedValues.forEach((draft) => {
                const id = draft.id;
                const key = id.split('-').pop();
                editedJson[key]=draft['Value'];
            }); 
           // console.log('after JSON.stringify(editedJson)',JSON.stringify(editedJson));
            this.originalJson=editedJson;
        return editedJson;
        
    }
    buildEditedJson() {
        const editedJson = { ...this.originalJson };
       // console.log('before JSON.stringify(editedJson)',JSON.stringify(editedJson)); 
         const tabKey = this.activetabContent;
            const updatedValues = this.draftValues;
            updatedValues.forEach((draft) => {
                const id = draft.id;
                const index = parseInt(id.split('-').pop(), 10);
                delete draft.id;
                Object.assign(editedJson[tabKey][index], draft);
            });
       // console.log('JSON.stringify(editedJson)',JSON.stringify(editedJson));    
        this.originalJson=editedJson;
        return editedJson;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }
}