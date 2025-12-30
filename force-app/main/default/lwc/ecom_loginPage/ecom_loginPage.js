import { LightningElement, api } from 'lwc';
import {NavigationMixin } from 'lightning/navigation';
import isGuestUser from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';

//Apex
//import loginUser from '@salesforce/apex/ECOM_LoginController.loginUser';

//labels
import ECOM_LBL_ACCOUNT_LOGIN from '@salesforce/label/c.ECOM_AccountLogin';

//static resources
import sres_ECOM_CartIcons from '@salesforce/resourceUrl/ssrc_ECOM_Theme';

export default class Ecom_loginPage extends NavigationMixin(LightningElement) {

    
    @api pageToRedirectLoggedInUser = '/dashboard';
    @api isAutoRedirectToDashboardIfLoggedIn ;
    @api createAccountPage='SelfRegister';

    displayLoginPage = false;

    storeBasePath = basePath;

    labels = {
        ECOM_LBL_ACCOUNT_LOGIN
    }

    constructor() {
        super();
    }

    images = {
        loginpagelogo : sres_ECOM_CartIcons + '/img/revvity-logo-loginpage.svg'
    }

    get userPageStyling(){

        let styling = 'ecom-background-color';

        if(isGuestUser){
            styling = styling + ' ';
        } 

        return styling;
    }

    connectedCallback(){

        if(!isGuestUser){
            console.log('basepath' , this.storeBasePath);//Remove after DEV
            console.log('basepath' , window.location.origin);//Remove after DEV
            const dashboardPath = window.location.origin +  this.pageToRedirectLoggedInUser;
            console.log('dashboardPath', dashboardPath);//Remove after DEV
            console.log('this.isAutoRedirectToDashboardIfLoggedIn', this.isAutoRedirectToDashboardIfLoggedIn);//Remove after DEV
            if((window.location.href.indexOf('builder') == -1 && window.location.href.indexOf('commeditor') == -1) && this.isAutoRedirectToDashboardIfLoggedIn){
                window.location.replace(dashboardPath); 
            }
            this.displayLoginPage = true;
        } else {
            this.displayLoginPage = true;
        }
        
    }

    // handleLogin(){
        
    //     loginUser().then(result => {
    //         console.log('result:: ', result);//Remove after DEV
    //     })
    // }

    redirectToPage(pageUrl){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
                attributes: {
                    url: pageUrl
                }
        });
    }
}